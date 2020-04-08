import 'package:camelapp/size_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class OpenPainter extends CustomPainter {
  ui.Image image;
  OpenPainter({this.image});
  var boxPosition = [Position(49, 47), Position(49, 67), Position(49, 88)];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width > 1.0 && size.height > 1.0) {
      print(">1.9");
      SizeUtil.size = size;
    }
    print("W: ${SizeUtil.getX(100)}");
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green
      ..isAntiAlias = true;

    // var circleCenter = Offset(SizeUtil.getX(11.8), SizeUtil.getY(19));

    // paint.color = Colors.yellow;
    // canvas.drawCircle(circleCenter, SizeUtil.getX(10), paint);
    // paint.color = Colors.green;
    // canvas.drawCircle(circleCenter, 3, paint);
    // paint.color = Colors.white;
    // canvas.drawCircle(circleCenter, 2, paint);

    var circleCenter = Offset(SizeUtil.getX(0), SizeUtil.getY(0));
    var circleEnd = Offset(SizeUtil.getX(100), SizeUtil.getY(100));
    print(" $image");
    // canvas.drawImage(image, circleCenter, paint);
    paintImage(
        canvas: canvas,
        rect: Rect.fromPoints(circleCenter, circleEnd),
        image: image,
        fit: BoxFit.cover);

    paint.color = Colors.blue;
    canvas.drawRect(buildCamel(boxPosition[0], 0, 1), paint);
    paint.color = Colors.yellow;
    canvas.drawRect(buildCamel(boxPosition[1], 0, 1), paint);
    paint.color = Colors.green;
    canvas.drawRect(buildCamel(boxPosition[2], 0, 1), paint);
    // paint.color = Colors.orange;
    // canvas.drawRect(buildCamel(boxPosition[2], 1, 3), paint);
    // paint.color = Colors.white;
    // canvas.drawRect(buildCamel(boxPosition[2], 2, 3), paint);

    canvas.save();
    canvas.restore();
  }

  Rect buildCamel(Position p, double h, double camels) {
    var y = p.y;
    y += (camels);
    return Rect.fromPoints(
        Offset(SizeUtil.getX(p.x), SizeUtil.getY(y - (h * 3))),
        Offset(SizeUtil.getX(8 + p.x), SizeUtil.getY(5 + y - (h * 3))));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class Position {
  final double x;
  final double y;
  Position(this.x, this.y);
}
