import 'dart:async';
import 'dart:typed_data';

import 'package:camelapp/dashboard.dart';
import 'package:camelapp/open_painter.dart';
import 'package:camelapp/size_util.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camelup',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Dashboard(),
      //home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MyCanvas(),
      ),
    );
  }
}

class MyCanvas extends StatefulWidget {
  @override
  _MyCanvasState createState() => _MyCanvasState();
}

class _MyCanvasState extends State<MyCanvas> {
  ui.Image image;
  bool _isImageLoaded;

  @override
  void initState() {
    super.initState();
    _isImageLoaded = false;
    init();
  }

  Future<Null> init() async {
    final ByteData data = await rootBundle.load('assets/board.jpg');
    image = await loadImage(new Uint8List.view(data.buffer));
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        _isImageLoaded = true;
      });
      print("IMAGE LOADED");
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    SizeUtil.size = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Image.asset(
          'assets/board.jpg',
          width: SizeUtil.getX(100),
          height: SizeUtil.getY(100),
          fit: BoxFit.cover,
        ),
        Positioned(
          top: SizeUtil.getY(32),
          left: SizeUtil.getX(18),
          child: GestureDetector(
            onTap: () {
              print("DO SOMETHING");
            },
            child: Container(
              color: Colors.brown,
              width: SizeUtil.getX(17.5),
              height: SizeUtil.getY(35),
            ),
          ),
        ),
        //...buildCamels(),
        buildCamel(1, box: 16, height: 0, total: 1),
      ],
    );
  }

  Widget buildCamel(int camelId, {int box, int height, int total}) {
    var _boxPosition = [
      Position(49, 46),
      Position(49, 67),
      Position(49, 88),
      Position(37.5, 88),
      Position(26, 88),
      Position(14, 88),
      Position(1.5, 88),
      Position(1.5, 67),
      Position(1.5, 46),
      Position(1.5, 25),
      Position(1.5, 4),
      Position(14, 4),
      Position(26, 4),
      Position(37.5, 4),
      Position(49, 4),
      Position(49, 23),
      Position(49, 44)
    ];
    var position = _boxPosition[box];
    return Positioned(
      left: SizeUtil.getX(position.x),
      top: SizeUtil.getY(position.y - (height * 3) + total),
      child: Container(
          width: SizeUtil.getX(8),
          height: SizeUtil.getY(5),
          color: getCamelColor(camelId)),
    );
  }

  Color getCamelColor(int camelId) {
    switch (camelId) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.white;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
