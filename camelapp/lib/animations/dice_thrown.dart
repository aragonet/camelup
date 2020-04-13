import 'package:camelapp/board_game.dart';
import 'package:camelapp/dice.dart';
import 'package:camelapp/models/models.dart';
import 'package:camelapp/size_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DiceThrown extends StatefulWidget {
  final int value, camelId;
  DiceThrown({this.value, this.camelId});

  @override
  _DriceThrownState createState() => _DriceThrownState();
}

class _DriceThrownState extends State<DiceThrown>
    with SingleTickerProviderStateMixin {
  AnimationController _animationCtrl;
  Animation _curve, _sizeCurve;

  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _curve = CurvedAnimation(parent: _animationCtrl, curve: Curves.ease);
    // _sizeCurve = CurvedAnimation(parent: _animationCtrl, curve: Curves.ease);
    _animationCtrl.forward();
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var position = dicePosition[this.widget.camelId];
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          SizeUtil.getX(position.x * _curve.value),
          SizeUtil.getY(position.y * _curve.value),
        ),
        child: Transform.scale(
            scale: _animationCtrl.value > 0.5 ? 0.5 : 1 - _animationCtrl.value,
            child: child),
      ),
      child: DiceWidget(value: this.widget.value, camelId: this.widget.camelId),
    );
  }
}
