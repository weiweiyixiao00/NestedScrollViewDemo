import 'dart:async' show Timer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import './exposure_detector.dart';
import './exposure_detector_controller.dart';

Iterable<Layer> _getLayerChain(Layer start) {
  final List<Layer> layerChain = <Layer>[];
  for (Layer layer = start; layer != null; layer = layer.parent as Layer) {
    layerChain.add(layer);
  }
  return layerChain.reversed;
}

Matrix4 _accumulateTransforms(Iterable<Layer> layerChain) {

  final Matrix4 transform = Matrix4.identity();
  if (layerChain.isNotEmpty) {
    Layer parent = layerChain.first;
    for (final Layer child in layerChain.skip(1)) {
      (parent as ContainerLayer).applyTransform(child, transform);
      parent = child;
    }
  }
  return transform;
}

Rect _localRectToGlobal(Layer layer, Rect localRect) {
  final Iterable<Layer> layerChain = _getLayerChain(layer);

  assert(layerChain.isNotEmpty);
  assert(layerChain.first is TransformLayer);
  final Matrix4 transform = _accumulateTransforms(layerChain.skip(1));
  return MatrixUtils.transformRect(transform, localRect);
}

class ExposureTimeLayer {
  final int time;
  VisibilityInfo? info;
  ExposureDetectorLayer layer;
  ExposureTimeLayer(this.time, this.layer, {this.info});
}

class ExposureDetectorLayer extends ContainerLayer {
  ExposureDetectorLayer(
      {required this.key,
      required this.widgetSize,
      required this.paintOffset,
      required this.onExposureChanged})
      : _layerOffset = Offset.zero;
  static Timer? _timer;

  static final _updated = <Key, ExposureDetectorLayer>{};
  static final _updatedKeys = <Key>{};

  final Key key;

  final Size widgetSize;

  Offset _layerOffset;

  final Offset paintOffset;

  final ExposureCallback onExposureChanged;

  static List<Key> toRemove = [];

  static final _exposureTime = <Key, ExposureTimeLayer>{};
  static final _lastVisibility = <Key, VisibilityInfo>{};

  static bool filter = false;
  static void setScheduleUpdate() {
    // final bool isFirstUpdate = _updated.isEmpty;
    // print('setScheduleUpdate...');
    final updateInterval = ExposureDetectorController.instance.updateInterval;
    // if (updateInterval == Duration.zero) {
    //   if (isFirstUpdate) {
    //     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //       _processCallbacks();
    //     });
    //   }
    // } else
    if (_timer == null) {
      _timer = Timer(updateInterval, _handleTimer);
    } else {
      assert(_timer!.isActive);
    }
    // _exposureTime.forEach((key, exposureLayer) {
    //   if (_updated[key] == null) {
    //     _updated[key] = exposureLayer.layer;
    //   }
    // });
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   _processCallbacks();
    // });
  }

  void _scheduleUpdate() {
    // final bool isFirstUpdate = _updated.isEmpty;
    _updatedKeys.add(key);
    setScheduleUpdate();
    // print('是否第一次$isFirstUpdate');
    // final updateInterval = ExposureDetectorController.instance.updateInterval;
    // if (updateInterval == Duration.zero) {
      // if (isFirstUpdate) {
        // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        //   _processCallbacks();
        // });
      // }
    // } else if (_timer == null) {
    //   _timer = Timer(updateInterval, _handleTimer);
    // } else {
    //   assert(_timer.isActive);
    // }
  }

  static void _handleTimer() {
    _timer = null;
    _exposureTime.forEach((key, exposureLayer) {
      // if (_updated[key] == null) {
      //   _updated[key] = exposureLayer.layer;
      // }
      if (!_updatedKeys.contains(key)) {
        _updatedKeys.add(key);
      }
    });

    /// 确保在两次绘制中计算完
    if (SchedulerBinding.instance != null) {
      SchedulerBinding.instance!.scheduleTask<void>(_preCallBacks, Priority.touch);
    }
  }

  /// 计算组件的矩形
  Rect _computeWidgetBounds() {
    final Rect r = _localRectToGlobal(this, Offset.zero & widgetSize);
    return r.shift(paintOffset + _layerOffset);
  }

  /// 计算两个两个矩形相交
  Rect _computeClipRect() {
    assert(RendererBinding.instance?.renderView != null);
    Rect clipRect = Offset.zero & RendererBinding.instance!.renderView.size;

    ContainerLayer? parentLayer = parent;
    while (parentLayer != null) {
      Rect? curClipRect;
      if (parentLayer is ClipRectLayer) {
        curClipRect = parentLayer.clipRect?? null ;
      } else if (parentLayer is ClipRRectLayer) {
        curClipRect = parentLayer.clipRRect!.outerRect;
      } else if (parentLayer is ClipPathLayer) {
        curClipRect = parentLayer.clipPath!.getBounds();
      }

      if (curClipRect != null) {
        curClipRect = _localRectToGlobal(parentLayer, curClipRect);
        clipRect = clipRect.intersect(curClipRect);
      }

      parentLayer = parentLayer.parent;
    }

    return clipRect;
  }

  static void _preCallBacks() {
    for (final key in _updatedKeys) {
      final layer = _updated[key];
      if (layer != null) {
        layer._processCallbacks();
      }
    }
    _updatedKeys.clear();
  }

  /// instances.
  void _processCallbacks() {
    VisibilityInfo info;
    int nowTime = new DateTime.now().millisecondsSinceEpoch;
    // List<Key> toReserveList = [];

      if (!attached) {
        _updated.remove(key);
        info = VisibilityInfo(
          key: key
        );
      } else {
        final widgetBounds = _computeWidgetBounds();
        info = VisibilityInfo.fromRects(
            key: key,
            widgetBounds: widgetBounds,
            clipRect: _computeClipRect());
      }
      final oldInfo = _lastVisibility[key];
      // print('首次上报:${info.visibleFraction.toString()}');
      // print('首次上报visibleBounds:${info.visibleBounds.isEmpty}');
      final visible = !info.visibleBounds.isEmpty && info.visibleFraction == 1;

      if (oldInfo == null) {
        if (!visible) {
          // oldInfo 为空，则说明上次为不可见，而当本次依旧是不可见时，不处理
          return;
        }
      }
      bool isFirstReport = !filter; // 首次上报
      // 符合上报的条件
      bool canReport = (isFirstReport || (filter && oldInfo == null )) && visible;
      var prevLayer = _exposureTime[key];
      if (visible) {
        _lastVisibility[key] = info;
        if (canReport) {
          if (prevLayer != null && prevLayer.time > 0) {
            if ((nowTime - prevLayer.time) > ExposureDetectorController.instance.exposureTime) {
              filter = true;
              onExposureChanged(info);
            } else {
              _exposureTime[key]?.layer = this;
              setScheduleUpdate();
            }
          } else { // 首次加载
            _exposureTime[key] = ExposureTimeLayer(nowTime, this);
            filter = true;
            onExposureChanged(info);
            // setScheduleUpdate();
          }
        }
      } else {
          _lastVisibility.remove(key);
          setScheduleUpdate();
      }

      // if (info.visibleFraction > 0.5) {
      //   print('上一次显示比例:${ _exposureTime[layer.key]?.info?.visibleFraction.toString()}');
      //   // if (_exposureTime[layer.key] != null) {
      //   //   _exposureTime[layer.key].info = info;
      //   //   layer.onExposureChanged(info);
      //   //   toRemove.add(layer.key);
      //   // } else {
      //   //   _exposureTime[layer.key] = ExposureTimeLayer(nowTime, layer, info: info);
      //   //   toReserveList.add(layer.key);
      //   //   setScheduleUpdate();
      //   // }
      //   if (_exposureTime[layer.key] != null &&
      //       _exposureTime[layer.key].time > 0) {
      //     if (nowTime - _exposureTime[layer.key].time > ExposureDetectorController.instance.exposureTime) {
      //       _exposureTime[layer.key].info = info;
      //       layer.onExposureChanged(info);
      //       // if (info.visibleFraction == 1) {
      //         // toRemove.add(layer.key);
      //       // }
      //     } else {
      //       setScheduleUpdate();
      //       toReserveList.add(layer.key);
      //       _exposureTime[layer.key].layer = layer;
      //     }
      //   } else {
      //     _exposureTime[layer.key] = ExposureTimeLayer(nowTime, layer, info: info);

      //     toReserveList.add(layer.key);
      //     setScheduleUpdate();
      //   }
      // }

      // _exposureTime.removeWhere((key, _) => !toReserveList.contains(key));

    // toRemove.forEach((key) {
    //   ExposureDetectorController.instance.forget(key);
    // });
    // toRemove.clear();
    // _updated.clear();
  }

  static void forget(Key key) {
    if (_updated[key] != null) {
      // _updated[key].filter = true;
      _updated.remove(key);
    }

    if (_updated.isEmpty) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// See [Layer.addToScene].
  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    // if (!filter) {
      _layerOffset = layerOffset;
    // print('addToScene-----');
      _scheduleUpdate();
    // }
    super.addToScene(builder, layerOffset);
  }

  /// See [AbstractNode.attach].
  @override
  void attach(Object owner) {
     _updated[key] = this;
    super.attach(owner);
    // if (!filter) {
    // print('attach-----');
      _scheduleUpdate();
    // }
  }

  /// See [AbstractNode.detach].
  @override
  void detach() {
    super.detach();

    // The Layer might no longer be visible.  We'll figure out whether it gets
    // re-attached later.
    // if (!filter) {
    // print('detach-----');
      _scheduleUpdate();
    // }
  }
}
