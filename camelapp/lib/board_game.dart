import 'dart:convert';

import 'package:camelapp/models/models.dart';
import 'package:camelapp/open_painter.dart';
import 'package:camelapp/size_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BoardGame extends StatelessWidget {
  final GameState gameState;
  final WebSocketChannel channel;
  final String playerId;
  BoardGame({this.gameState, this.channel, this.playerId});
  final _boxPosition = [
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
        ...buildCamels(),
        //buildCamel(0, box: 0, height: 1)
        buildPyramid(),
      ],
    );
  }

  List<Widget> buildCamels() {
    var camels = <Widget>[];

    for (var i = 0; i < this.gameState.game.circuit.length; i++) {
      var box = this.gameState.game.circuit[i];
      for (var j = 0; j < box.length; j++) {
        var camelId = box[j];
        camels.add(buildCamel(camelId, box: i, height: j, total: box.length));
      }
    }

    return camels;
  }

  Widget buildCamel(int camelId, {int box, int height, int total}) {
    print("$box $_boxPosition");
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

  Widget buildPyramid() {
    return Positioned(
      top: SizeUtil.getY(32),
      left: SizeUtil.getX(18),
      child: GestureDetector(
        onTap: () {
          channel.sink.add(jsonEncode(GameRequest(
            gameId: this.gameState.game.id,
            throwDice: true,
            playerId: this.playerId,
          )));
        },
        child: Container(
          color: Colors.brown,
          width: SizeUtil.getX(17.5),
          height: SizeUtil.getY(35),
        ),
      ),
    );
  }
}
