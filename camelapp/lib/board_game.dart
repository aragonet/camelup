import 'dart:convert';

import 'package:camelapp/models/models.dart';
import 'package:camelapp/open_painter.dart';
import 'package:camelapp/players_info.dart';
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

  final _cardPosition = [
    Position(74.7, 37),
    Position(62.4, 71.5),
    Position(70.5, 58.6),
    Position(70.5, 15),
    Position(62.4, 3),
  ];
  final _cardRotation = [1.58, 2.6, 2.24, 0.9, 0.5];

  @override
  Widget build(BuildContext context) {
    SizeUtil.size = MediaQuery.of(context).size;
    return ListView(
      children: <Widget>[
        Stack(children: <Widget>[
          Image.asset(
            'assets/board.jpg',
            width: SizeUtil.getX(100),
            height: SizeUtil.getY(100),
            fit: BoxFit.cover,
          ),
          ...buildCamels(),
          buildPyramid(),
          ...buildRoundCards(),
          ...buildDices(),
          buildGameOver()
        ]),
        PlayersInfo(gameState: this.gameState, playerId: this.playerId),
      ],
    );
  }

  List<Widget> buildCamels() {
    var camels = <Widget>[];

    for (var i = 0; i < this.gameState.game.circuit.length; i++) {
      var box = this.gameState.game.circuit[i];
      for (var j = 0; j < box.length; j++) {
        var camelId = box[j];
        camels
            .add(buildCamel(camelId - 1, box: i, height: j, total: box.length));
      }
    }

    return camels;
  }

  Widget buildCamel(int camelId, {int box, int height, int total}) {
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

  List<Widget> buildRoundCards() {
    var cards = <Widget>[];
    for (var i = 0; i < this.gameState.game.roundCards.length; i++) {
      var camelCards = this.gameState.game.roundCards[i];
      for (var j = 0; j < camelCards.length; j++) {
        var card = camelCards[j];
        if (card.playerId == 0) {
          cards.add(buildRoundCard(i, card.points));
          break;
        }
      }
    }
    return cards;
  }

  Widget buildRoundCard(int camelId, int value) {
    var position = _cardPosition[camelId];
    var angle = _cardRotation[camelId];
    return Positioned(
      left: SizeUtil.getX(position.x),
      top: SizeUtil.getY(position.y),
      child: Transform.rotate(
        angle: angle,
        child: InkWell(
          onTap: () {
            var camel = camelId + 1;
            print("Get card camel $camelId $camel");
            channel.sink.add(jsonEncode(GameRequest(
              gameId: this.gameState.game.id,
              playerId: this.playerId,
              getCamelRoundCard: camel,
            )));
          },
          child: Container(
            width: SizeUtil.getX(8),
            height: SizeUtil.getY(24),
            child: Center(
              child: Text(
                "$value",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildDices() {
    var ds = <Widget>[];
    for (var dice in this.gameState.game.thrownDices) {
      ds.add(buildDice(dice.camelId - 1, dice.number));
    }
    return ds;
  }

  Widget buildDice(int camelId, int value) {
    var _dicePosition = [
      Position(68.5, 43.5),
      Position(62, 60),
      Position(67, 54),
      Position(66.5, 33.5),
      Position(62, 27),
    ];
    var position = _dicePosition[camelId];
    return Positioned(
      left: SizeUtil.getX(position.x),
      top: SizeUtil.getY(position.y),
      child: Text(
        "$value",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 30,
          color: Color(0xff293749),
        ),
      ),
    );
  }

  Widget buildGameOver() {
    if (!this.gameState.game.gameEnded) {
      return SizedBox();
    }
    return Positioned(
      top: SizeUtil.getY(0),
      bottom: SizeUtil.getY(0),
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white54,
        child: Center(
          child: Text(
            "Fi del joc",
            style: TextStyle(fontSize: 64),
          ),
        ),
      ),
    );
  }
}

Color getCamelColor(int camelId) {
  switch (camelId) {
    case 0:
      return Colors.orange;
    case 1:
      return Colors.white;
    case 2:
      return Colors.yellow;
    case 3:
      return Colors.green;
    default:
      return Colors.blue;
  }
}
