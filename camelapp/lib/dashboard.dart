import 'dart:convert';
import 'package:camelapp/game_pool.dart';
import 'package:camelapp/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  WebSocketChannel channel;
  String myPlayer;

  @override
  void initState() {
    super.initState();

    stablishConnection();
  }

  stablishConnection() {
    channel = HtmlWebSocketChannel.connect('ws://localhost:3000');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              String message = snapshot.data;
              GameState gameState = GameState.fromJson(jsonDecode(message));
              if (gameState.playerId != "") {
                setState(() {
                  myPlayer = gameState.playerId;
                });
              }
              return GamePool(
                channel: channel,
                gameState: gameState,
                player: myPlayer,
              );
            }
            return Center(
              child: RaisedButton(
                child: Text(
                  "Començar una partida",
                  style: TextStyle(
                      fontSize: 24,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () {
                  var d = jsonEncode(GameRequest(newGame: true));
                  print("CREATE NEW GAME $d");
                  channel.sink.add(d);
                },
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
