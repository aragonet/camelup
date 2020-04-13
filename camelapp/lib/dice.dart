import 'package:camelapp/main.dart';
import 'package:camelapp/size_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final int value, camelId;
  DiceWidget({this.value, this.camelId});

  final double _width = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(SizeUtil.getX(1))),
        color: getCamelColor(camelId) == Colors.white
            ? Colors.white70
            : (getCamelColor(camelId) as MaterialColor)[600],
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: Offset(2.0, 2.0),
          )
        ],
      ),
      width: SizeUtil.getX(_width),
      height: SizeUtil.getX(_width),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(SizeUtil.getX(4))),
            color: getCamelColor(camelId),
          ),
          child: buildDiceSpots(value)),
    );
  }

  Widget buildDiceSpots(int value) {
    switch (value) {
      case 1:
        return Stack(
          children: <Widget>[buildDice1Value()],
        );
      case 2:
        return Stack(
          children: <Widget>[...buildDice2Values()],
        );
      default:
        return Stack(
          children: <Widget>[...buildDice2Values(), buildDice1Value()],
        );
    }
  }

  Widget buildDice1Value() {
    var radius = SizeUtil.getX(2);

    return Positioned(
      top: SizeUtil.getX(_width / 2) - (radius / 2),
      left: SizeUtil.getX(_width / 2) - (radius / 2),
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          color: Colors.black,
        ),
      ),
    );
  }

  List<Widget> buildDice2Values() {
    var radius = SizeUtil.getX(2);

    return [
      Positioned(
        top: SizeUtil.getX(_width - (_width / 4)) - (radius / 2),
        left: SizeUtil.getX(_width / 4) - (radius / 2),
        child: Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            color: Colors.black,
          ),
        ),
      ),
      Positioned(
        top: SizeUtil.getX(_width - (_width / 4)) - (radius / 2),
        left: SizeUtil.getX(_width / 4) - (radius / 2),
        child: Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            color: Colors.black,
          ),
        ),
      ),
    ];
  }
}
