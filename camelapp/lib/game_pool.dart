import 'dart:convert';

import 'package:camelapp/board_game.dart';
import 'package:camelapp/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GamePool extends StatefulWidget {
  final WebSocketChannel channel;
  final GameState gameState, oldGame;
  final String player;

  GamePool({this.channel, this.gameState, this.player, this.oldGame});

  @override
  _GamePoolState createState() => _GamePoolState();
}

class _GamePoolState extends State<GamePool> {
  @override
  void initState() {
    super.initState();

    if (this.widget.player == null) {
      this.widget.channel.sink.add(
            jsonEncode(
              GameRequest(
                gameId: this.widget.gameState.game.id,
                newPlayer: true,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.widget.gameState.game.playerTurn == 0) {
      return buildGamePool();
    }

    return BoardGame(
      gameState: this.widget.gameState,
      channel: this.widget.channel,
      playerId: this.widget.player,
    );
  }

  Widget buildGamePool() {
    var players = buildPlayers();
    return Center(
      child: Container(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Partida", style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                SelectableText(this.widget.gameState.game.id,
                    style: TextStyle(fontSize: 32))
              ],
            ),
            ...players,
            buildStartButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> buildPlayers() {
    var players = <Widget>[];

    var count = 0;
    for (var player in this.widget.gameState.game.players) {
      count++;
      var label = "Jugador $count";
      print(jsonEncode(player));
      if (player.id != "") {
        label = "Tú";
      }

      players.add(Text(label));
    }
    return players;
  }

  Widget buildStartButton() {
    if (this.widget.gameState.game.players.length > 1 &&
        this.widget.gameState.game.players[0].id == this.widget.player) {
      return RaisedButton(
        onPressed: () {
          this.widget.channel.sink.add(jsonEncode(GameRequest(
                gameId: this.widget.gameState.game.id,
                startGame: true,
                playerId: this.widget.player,
              )));
        },
        child: Text("Som-hi"),
        color: Theme.of(context).primaryColor,
      );
    }
    return SizedBox();
  }
}
