import 'dart:convert';

import 'package:camelapp/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GamePool extends StatefulWidget {
  final WebSocketChannel channel;
  final GameState gameState;
  final String player;

  GamePool({this.channel, this.gameState, this.player});

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
    return Container(
      child: Text("${this.widget.gameState.playerId}"),
    );
  }
}
