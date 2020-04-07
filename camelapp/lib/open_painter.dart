import 'package:camelapp/size_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OpenPainter extends CustomPainter {
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

    var circleCenter = Offset(SizeUtil.getX(11.8), SizeUtil.getY(19));
    paint.color = Colors.blue;
    canvas.drawCircle(circleCenter, SizeUtil.getAxisBoth(10), paint);
    // paint.color = Colors.yellow;
    // canvas.drawCircle(circleCenter, SizeUtil.getX(10), paint);
    // paint.color = Colors.green;
    // canvas.drawCircle(circleCenter, 3, paint);
    // paint.color = Colors.white;
    // canvas.drawCircle(circleCenter, 2, paint);

    canvas.save();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
