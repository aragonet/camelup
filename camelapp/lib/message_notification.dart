import 'package:camelapp/size_util.dart';
import 'package:flutter/cupertino.dart';

class MessageNotification extends StatefulWidget {
  @override
  _MessageNotificationState createState() => _MessageNotificationState();
}

class _MessageNotificationState extends State<MessageNotification>
    with SingleTickerProviderStateMixin {
  AnimationController _animationCtrl;
  Animation _curve;
  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _curve = CurvedAnimation(parent: _animationCtrl, curve: Curves.easeInBack);
    _animationCtrl.forward();
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _curve.value * SizeUtil.getY(60)),
        child: Transform.scale(scale: 1 - _curve.value, child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffffd700),
          borderRadius: new BorderRadius.all(const Radius.circular(17.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40),
          child: Text(
            "Es el teu torn",
            style: TextStyle(fontSize: 56),
          ),
        ),
      ),
    );
  }
}
