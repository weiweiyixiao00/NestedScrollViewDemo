import 'dart:async';

import 'package:NestedScrollViewDemo/src/CustomScrollDemo.dart';
import 'package:NestedScrollViewDemo/src/NestedScrollViewDemo.dart';
import 'package:NestedScrollViewDemo/src/NestedRefresh.dart';
import 'package:NestedScrollViewDemo/src/PullNotifactionDemo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        "NestedScrollViewDemo": (_) => NestedScrollViewDemo(),
        "CustomScrollViewDemo": (_) => HomePage(),
        "EasyRefreshDemo": (_) => EasyRefreshDemo(),
        "PullNotifactionDemo": (_) => PullNotifactionDemo(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _countDown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // this._startTimer();
  }

  void _startTimer() {
     _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
        _countDown--;
        print('${_countDown}s');
        ///到5秒后停止
        if (_countDown < 0) {
          _timer!.cancel();
          setState(() {
            _countDown = -1;
          });
          return;
        }
        int s = _countDown % 60;
        // String second = this._toStrNumber(s);
        setState(() {
          _countDown = _countDown;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: () => Navigator.of(context).pushNamed("NestedScrollViewDemo"),
              child: Text('NestedScrollViewDemo',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pushNamed("CustomScrollViewDemo"),
              child: Text('CustomScrollViewDemo',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pushNamed("EasyRefreshDemo"),
              child: Text('EasyRefreshDemo',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () => Navigator.of(context).pushNamed("PullNotifactionDemo"),
              child: Text('PullNotifactionDemo',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
