library pull_to_refresh;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

part 'src/helpers/positioned_indicator_container.dart';
part 'src/custom_refresh_indicator.dart';
part 'src/controller.dart';

class PullToRefreshIndicator extends StatefulWidget {
  final Widget child;
  final OnRefresh handleRefresh;
  final IndicatorController? controller;
  // 下拉刷新文字样式
  final TextStyle? textStyle;
  // 下拉刷新自定义icon，需传package name
  final String? packageName;
  // 下拉刷新 GIF
  final String? loadingGIF;
  // 下拉刷新 PNG
  final String? loadingPNG;

  PullToRefreshIndicator({
    Key? key,
    required this.child,
    required this.handleRefresh,
    this.controller,
    this.textStyle,
    this.packageName,
    this.loadingGIF,
    this.loadingPNG,
  })  : assert(child != null),
        assert(handleRefresh != null),
        super(key: key);

  @override
  _PullToRefreshIndicatorState createState() => _PullToRefreshIndicatorState();
}

class _PullToRefreshIndicatorState extends State<PullToRefreshIndicator>
    with SingleTickerProviderStateMixin {
  // 刷新中的最小高度
  static const _indicatorSize = 50.0;

  // 是否正在刷新中
  bool _renderCompleteState = false;

  static const _textStyle = TextStyle(
    fontSize: 10,
    height: 1.2,
    color: Color.fromRGBO(153, 153, 153, 1),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      offsetToArmed: _indicatorSize,
      onRefresh: widget.handleRefresh,
      child: widget.child,
      controller: widget.controller,
      completeStateDuration: const Duration(seconds: 1),
      builder: (
        BuildContext context,
        Widget child,
        IndicatorController controller,
      ) {
        return Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? _) {
                if (controller.didStateChange(to: IndicatorState.complete)) {
                  // 当刷新状态为完成时，重置状态为 true
                  _renderCompleteState = true;
                } else if (controller.didStateChange(to: IndicatorState.idle)) {
                  // 当刷新状态为空闲时，重置状态为 false
                  _renderCompleteState = false;
                }
                final containerHeight = controller.value * _indicatorSize;

                final _refreshText = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    widget.packageName == null
                        ? new Image.asset(
                            controller.isLoading || controller.isComplete
                                ? 'assets/loading_pull.webp'
                                : 'assets/loading_pull.png',
                            package: 'pull_to_refresh',
                            width: 35.0,
                          )
                        : new Image.asset(
                            (controller.isLoading || controller.isComplete
                                ? widget.loadingGIF
                                : widget.loadingPNG)!,
                            package: widget.packageName,
                            width: 35.0,
                          ),
                    Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        controller.isDragging
                            ? '下拉刷新'
                            : controller.isArmed
                                ? '松开立即刷新'
                                : controller.isComplete ? '加载完成' : '加载中',
                        style: widget.textStyle == null
                            ? _textStyle
                            : widget.textStyle,
                      ),
                    ),
                  ],
                );

                return Container(
                  alignment: Alignment.center,
                  height: containerHeight,
                  child: OverflowBox(
                    maxHeight: 40,
                    minHeight: 40,
                    maxWidth: 140,
                    minWidth: 140,
                    alignment: Alignment.center,
                    child: widget.packageName == null
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            alignment: Alignment.center,
                            child: controller.isIdle ? null : _refreshText,
                          )
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            alignment: Alignment.center,
                            child: controller.isIdle ||
                                    controller.value <= 0.0 ||
                                    (ScrollDirection.reverse ==
                                            controller.scrollingDirection &&
                                        controller.value <= 0.0) ||
                                    ScrollDirection.reverse ==
                                        controller.scrollingDirection
                                ? null
                                : _refreshText,
                          ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0.0, controller.value * _indicatorSize),
                  child: child,
                );
              },
              animation: controller,
            ),
          ],
        );
      },
    );
  }
}
