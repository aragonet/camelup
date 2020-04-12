import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:camelapp/game_pool.dart';
import 'package:camelapp/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  WebSocketChannel channel;
  String myPlayer;
  TextEditingController _gameCtrl;
  GamePool _defaultGame;

  @override
  void initState() {
    super.initState();
    var uri = Uri.parse(window.location.href);
    channel = HtmlWebSocketChannel.connect('ws://${uri.host}:8001');

    _gameCtrl = TextEditingController();

    _defaultGame = GamePool(
      channel: channel,
      gameState: GameState.fromJson(jsonDecode("""
                  {"error_code":0,
                  "game":
                    {"id":"m",
                    "camels":[{"id":1},{"id":2},{"id":3},{"id":4},{"id":5}],
                    "players":[{"id":"6tSv","points":0},{"id":"","points":0}],
                    "circuit":[[2,3,4,5],[],[1],[],[],[],[],[],[],[],[],[],[],[],[],[],[]],
                    "thrown_dices":[],
                    "round_cards":[
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}]
                    ],
                    "player_turn":2,
                    "game_started":true,
                    "game_ended":false
                    },
                  "player_id":"6tSv"
                }""")),
      player: "6tSv",
    );

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _defaultGame = GamePool(
          channel: channel,
          gameState: GameState.fromJson(jsonDecode("""
                  {"error_code":0,
                  "game":
                    {"id":"m",
                    "camels":[{"id":1},{"id":2},{"id":3},{"id":4},{"id":5}],
                    "players":[{"id":"6tSv","points":0},{"id":"","points":0}],
                    "circuit":[[2,3,4,5],[],[],[1],[],[],[],[],[],[],[],[],[],[],[],[],[]],
                    "thrown_dices":[],
                    "round_cards":[
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}],
                      [{"points":5,"player_id":0},{"points":3,"player_id":0},{"points":2,"player_id":0}]
                    ],
                    "player_turn":1,
                    "game_started":true,
                    "game_ended":false
                    },
                  "player_id":"6tSv"
                }""")),
          player: "6tSv",
        );
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    _gameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            //return _defaultGame;
            if (snapshot.hasData) {
              print(snapshot.data);
              String message = snapshot.data;
              GameState gameState = GameState.fromJson(jsonDecode(message));
              if (gameState.playerId != "") {
                myPlayer = gameState.playerId;
              }

              if (gameState.game.id != "") {
                return GamePool(
                  channel: channel,
                  gameState: gameState,
                  player: myPlayer,
                );
              }
            }
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RaisedButton(
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
                  SizedBox(height: 56),
                  Container(
                    width: 300,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Flexible(
                          child: TextField(
                            decoration:
                                InputDecoration(hintText: "Id de partida"),
                            controller: _gameCtrl,
                          ),
                        ),
                        OutlineButton(
                          onPressed: () {
                            print(_gameCtrl.text);
                            channel.sink.add(jsonEncode(GameRequest(
                              gameId: _gameCtrl.text,
                              newPlayer: true,
                            )));
                          },
                          child: Text("Unirse"),
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
