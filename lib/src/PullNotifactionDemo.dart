import 'dart:developer';

import 'package:NestedScrollViewDemo/src/widget/exposure-master/lib/exposure.dart';
import 'package:NestedScrollViewDemo/src/widget/keep_alive.dart';
import 'package:NestedScrollViewDemo/src/widget/uplus_pull_refresh/pullToRefresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'  hide NestedScrollView;
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart' ;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'widget/custom_pull_refresh/lib/custom_refresh_page.dart';
import 'widget/refresh_notification/lib/pull_to_refresh_notification.dart';

class TabTitle {
  final String title;
  final int index;
  const TabTitle(this.title, this.index);
}

class PullNotifactionDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PullNotifactionDemoState();

}

enum RefreshMode {
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done,
}

class PullNotifactionDemoState extends State<PullNotifactionDemo> with SingleTickerProviderStateMixin{
List<TabTitle> tabList = [
      new TabTitle('推荐', 10),
      new TabTitle('热点', 0),
      new TabTitle('社会', 1),
      new TabTitle('娱乐', 2),
      new TabTitle('体育', 3),
      new TabTitle('美文', 4),
      new TabTitle('科技', 5),
      new TabTitle('财经', 6),
      new TabTitle('时尚', 7)
    ];
  late TabController mController;
  bool isPullDown = false;
  RefreshMode pullStatus = RefreshMode.drag;
  ScrollController _scrollController = new ScrollController(keepScrollOffset: true, initialScrollOffset: 0);
  final GlobalKey<PullToRefreshNotificationState> key = GlobalKey<PullToRefreshNotificationState>();

  @override
  void initState() {
    super.initState();
    mController = TabController(length: tabList.length, vsync: this);
    _scrollController.addListener(() {
      // print(_scrollController.offset.toString());
    });

    WidgetsBinding.instance!.addPostFrameCallback(_afterScrollViewLayout);
  }

  _afterScrollViewLayout(_) {
    print('________-绘制完成————————————');
    // Future.delayed(Duration(milliseconds: 100), () {
    //   _scrollController.jumpTo(100);
    // });
  }

  Future<bool> onRefresh() async{
    print('onRefresh');
    return Future<bool>.delayed(const Duration(seconds: 2), () {
      // _scrollController.animateTo(100, duration: Duration(milliseconds: 300), curve: Curves.linear);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PullNotifactionDemo', style: TextStyle(color: Colors.black),),
      ),
      body: SafeArea(
        // child: _buildNestedScrollView(context)
        // child: Listener(
        //   onPointerDown: (PointerEvent event) {
        //     print("用户手指按下：${event.delta.distance}");
        //   },
        //   onPointerMove: (PointerEvent event) {
        //     // if (event.delta.direction > 0 && _scrollController.offset > 0) {
        //     //   _scrollController.animateTo(100, duration: Duration(milliseconds: int.parse(_scrollController.offset.round().toString())), curve: Curves.linear);
        //     // }
        //     // print("用户手指移动：${event.delta.direction}");
        //     if (event.delta.direction > 0 && !isPullDown) {
        //       this.setState(() {
        //         isPullDown = true;
        //       });
        //     } else if (event.delta.direction < 0 && isPullDown) {
        //       this.setState(() {
        //         isPullDown = false;
        //       });
        //     }
        //     if (isPullDown && _scrollController.offset <= 20) {
        //       this.setState(() {
        //         pullStatus = RefreshMode.armed;
        //       });
        //     }
        //   },
        //   onPointerUp: (PointerEvent event) {
        //     print("用户手指抬起：${event.delta.direction}");
        //     if (_scrollController.offset <= 100) {
        //       if (isPullDown && _scrollController.offset > 20) {
        //         _scrollController.animateTo(100, duration: Duration(milliseconds: 200), curve: Curves.linear);
        //         this.setState(() {
        //           pullStatus = RefreshMode.drag;
        //         });
        //       } else if (isPullDown && _scrollController.offset <= 20) {
        //         this.setState(() {
        //           pullStatus = RefreshMode.refresh;
        //         });
        //         this.onRefresh();
        //       }
        //     }
        //   },
        //   child: _buildNestedScrollView(context),
        // ),

        // child: GestureDetector(
        //   child:  _buildNestedScrollView(context),
        //   onPanDown: (DragDownDetails e) {
        //     print("用户手指按下：${e.globalPosition}");
        //   },
        //   onVerticalDragUpdate: (DragUpdateDetails e) {
        //     print("用户手指移动：${e.globalPosition}");
        //   },
        //   onPanEnd: (DragEndDetails e){
        //     //打印滑动结束时在x、y轴上的速度
        //     print('手抬起${e.velocity}');
        //   },
        // ),

        child: PullToRefreshNotification(
          color: Colors.blue,
          pullBackOnRefresh: false,
          maxDragOffset: 100,
          onRefresh: onRefresh,
          pullBackDuration: const Duration(milliseconds: 500),
          key: key,
          armedDragUpCancel: false,
          notificationPredicate: (notifation) {
            //该属性包含当前ViewPort及滚动位置等信息
            ScrollMetrics scrollMetrics = notifation.metrics;
            if (scrollMetrics.minScrollExtent == 0) {
              return true;
            } else {
              return false;
            }
          },
          child: _buildNestedScrollView(context)
        ),

        // child: RefreshIndicator2(
        //   notificationPredicate: (notifation) {
        //     if (notifation is OverscrollNotification) {
        //         return notifation.depth == 2;
        //       }
        //       return notifation.depth == 0;
        //   },
        //   onRefresh: () {
        //     return Future.delayed(Duration(seconds: 2), () {
        //       return true;
        //     });
        //   },
        //   child: _buildNestedScrollView(context)
        // ),
      ),
    );
  }

   Widget buildPulltoRefreshHeader(PullToRefreshScrollNotificationInfo? info) {

     var offset = info?.dragOffset ?? 0.0;
     var mode = info?.mode;
     String tipText = '下拉刷新';
     if (mode == RefreshIndicatorMode.refresh) {
       offset = 100;
       tipText = '加载中...';
     } else if (mode == RefreshIndicatorMode.done) {
       tipText = '加载完成';
     }
    //  Widget refreshWidget = Container();
    //  //it should more than 18, so that RefreshProgressIndicator can be shown fully
    //  if (info?.refreshWidget != null &&
    //      offset > 18.0 &&
    //      mode != RefreshIndicatorMode.error) {
    //    refreshWidget = info!.refreshWidget!;
    //  }

     late Widget child;
    //  if (mode == RefreshIndicatorMode.error) {
    //    child = GestureDetector(
    //        onTap: () {
    //          // refreshNotification;
    //          info?.pullToRefreshNotificationState.show();
    //        },
    //        child: Container(
    //          color: Colors.grey,
    //          alignment: Alignment.bottomCenter,
    //          height: offset,
    //          width: double.infinity,
    //          //padding: EdgeInsets.only(top: offset),
    //          child: Container(
    //            padding: EdgeInsets.only(left: 5.0),
    //            alignment: Alignment.center,
    //            child: Text(
    //              mode.toString() + "  click to retry",
    //              style: TextStyle(fontSize: 12.0, inherit: false),
    //            ),
    //          ),
    //        ));
    //  } else {
       child = Container(
         color: Colors.blue,
         alignment: Alignment.center,
         height: offset,
         width: double.infinity,
         //padding: EdgeInsets.only(top: offset),
         child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitWave(color: Colors.white, type: SpinKitWaveType.start, size: 22,),
              Text(tipText, style: TextStyle(color: Colors.white, fontSize: 12),),
            ],
         ),
       );
    //  }
     return SliverToBoxAdapter(
       child: child,
     );
   }

   Widget _buildHeader(BuildContext context) {
     String tipText = '下拉刷新';
     if (pullStatus == RefreshMode.refresh) {
       tipText = '加载中...';
     } else if (pullStatus == RefreshMode.done) {
       tipText = '加载完成';
     } else if (pullStatus == RefreshMode.armed) {
       tipText = '松手刷新';
     }
     return SliverToBoxAdapter(
       child: Transform.translate(
        offset: Offset(0, 0),
        child: Container(
          color: Colors.blue,
          height: 100,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitWave(color: Colors.white, type: SpinKitWaveType.start, size: 22,),
              Text(tipText, style: TextStyle(color: Colors.white, fontSize: 12),),
            ],
          ),
        ),
      ),
     );
   }

  Widget _buildNestedScrollView(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      physics: ScrollPhysics(parent: PageScrollPhysics()),
      headerSliverBuilder: (BuildContext context, bool? innerBoxIsScrolled) {
        return <Widget>[
          PullToRefreshContainer(buildPulltoRefreshHeader),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Container(
                  height: 500,
                  width: double.infinity,
                  color: Colors.red,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text('我是头部占位'),
                  alignment: Alignment.center,
                )
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.yellow,
                  margin: EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  child: Text('我是黄色占位'),
                )
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Container(
                  height: 500,
                  width: double.infinity,
                  color: Colors.red,
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text('我是头部占位1'),
                  alignment: Alignment.center,
                )
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.yellow,
                  margin: EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  child: Text('我是黄色占位1'),
                )
              ],
            ),
          ),
          ///停留在顶部的TabBar
          SliverPersistentHeader(
            delegate: StickyGoodsListNavDelegate(
              child: Container(
                color: new Color(0xfff4f5f6),
                height: 38.0,
                child: TabBar(
                  isScrollable: true,
                  //是否可以滚动
                  controller: mController,
                  labelColor: Colors.red,
                  unselectedLabelColor: Color(0xff666666),
                  labelStyle: TextStyle(fontSize: 16.0),
                  tabs: tabList.map((item) {
                    return Tab(
                      text: item.title,
                    );
                  }).toList(),
                ),
              ), stickCallBack: () {

              }
            ),
            pinned: true,
          ),
        ];
      },
      body: _buildTabView(context),
    );
  }

  Widget _buildTabView(BuildContext context) {
    return TabBarView(
      controller: mController,
      children: tabList.map((item) {
        return NestedScrollViewInnerScrollPositionKeyWidget(
          Key('${item.index}'),
          KeepAliveWidget(
            Stack(children: <Widget>[
              EasyRefresh(
                enableControlFinishRefresh: false,
                onLoad: () async {
                  print('加载更多');
                },
                child:
                StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: 20 + mController.index * 5,
                  itemBuilder: (context, index){
                    // print('gridview-itemnBuilder-----$index');
                    return ExposureDetector(
                      key: Key('column_scroll_$index'),
                      child: Container(
                        alignment: Alignment.center,
                        height: 450 + ((index % 2) == 0 ? (index * 15).toDouble() : 0.0),
                        child: Text(
                          index.toString(),
                          style: TextStyle(fontSize: 24),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.lightGreen,
                            border: Border(
                                bottom: BorderSide(color: Colors.white, width: 10))),
                      ),
                      onExposure: (visibilityInfo) {
                        print('第$index 块曝光,展示比例为${visibilityInfo.visibleFraction}');
                      },
                    );
                  },
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
              )
            ],)
          )
        );
      }).toList()
    );
  }

}

class StickyGoodsListNavDelegate extends SliverPersistentHeaderDelegate {
  final dynamic child;
  final Function stickCallBack;

  StickyGoodsListNavDelegate({required this.child, required this.stickCallBack});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // print('sticky头部:shrinkOffset=${shrinkOffset.toString()} ');
    // if (shrinkOffset > 0) {
    //   this.stickCallBack(true);
    // } else if (shrinkOffset == 0){
    //   this.stickCallBack(false);
    // }
    // this.stickCallBack(shrinkOffset > 0);
    // print('剩余高度:${this.maxExtent - shrinkOffset}');
    return this.child;
  }

  @override
  double get maxExtent => 38;

  @override
  double get minExtent => 38;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}