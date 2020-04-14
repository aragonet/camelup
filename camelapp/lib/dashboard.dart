import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:camelapp/animations/dice_thrown.dart';
import 'package:camelapp/animations/your_turn.dart';
import 'package:camelapp/game_pool.dart';
import 'package:camelapp/models/models.dart';
import 'package:camelapp/size_util.dart';
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
  GamePool _oldGame;
  List<Widget> _stepAnimations;

  @override
  void initState() {
    super.initState();
    var uri = Uri.parse(window.location.href);
    channel = HtmlWebSocketChannel.connect('ws://${uri.host}:8001');

    channel.stream.listen((data) {
      _oldGame = _defaultGame;
      print(data);
      String message = data;
      GameState gameState = GameState.fromJson(jsonDecode(message));
      if (gameState.playerId != "") {
        myPlayer = gameState.playerId;
      }

      if (_defaultGame == null) {
        _defaultGame = GamePool(
          channel: channel,
          gameState: gameState,
          player: myPlayer,
        );
      } else {
        checkAnimations(GamePool(
          channel: channel,
          gameState: gameState,
          player: myPlayer,
        ));
      }

      setState(() {});
    });

    _gameCtrl = TextEditingController();
    _stepAnimations = [];
  }

  @override
  void dispose() {
    channel.sink.close();
    _gameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeUtil.size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(child: buildContent()),
    );
  }

  Widget buildContent() {
    if (this._defaultGame != null &&
        this._defaultGame.gameState.game.id != "") {
      return Stack(
        children: <Widget>[
          _defaultGame,
          ..._stepAnimations,
        ],
      );
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
                    decoration: InputDecoration(hintText: "Id de partida"),
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
  }

  bool isYourTurn(Game game, String playerId) {
    var playerIndex = 0;
    for (var i = 0; i < game.players.length; i++) {
      print("P ${game.players[i].id} $playerId");
      if (game.players[i].id == playerId) {
        playerIndex = i + 1;
        break;
      }
    }
    print("${game.playerTurn} $playerIndex");
    return game.playerTurn == playerIndex;
  }

  void checkAnimations(GamePool newGame) {
    var animations = [];
    if (newGame.gameState.game.thrownDices.length > 0 &&
        newGame.gameState.game.thrownDices.length !=
            _defaultGame.gameState.game.thrownDices.length) {
      print(
          "Show new dice ${jsonEncode(newGame.gameState.game.thrownDices.last)}");
      var d = newGame.gameState.game.thrownDices.last;
      animations.add(DiceThrown(value: d.number, camelId: d.camelId - 1));
    }

    for (var i = 0; i < animations.length; i++) {
      Future.delayed(Duration(seconds: 3 * i), () {
        print("Animation $i");
        setState(() {
          _stepAnimations = [animations[i]];
        });
      });
    }

    print("WAIT ${4 * animations.length}");
    Future.delayed(Duration(seconds: 3 * animations.length), () {
      print("A");
      setState(() {
        _defaultGame = newGame;
      });
    });

    if (isYourTurn(newGame.gameState.game, this.myPlayer) &&
        !newGame.gameState.game.gameEnded) {
      Future.delayed(Duration(seconds: 3 * (animations.length + 1)), () {
        setState(() {
          _stepAnimations = [
            Positioned(
              top: 0,
              bottom: SizeUtil.getY(100),
              left: 0,
              right: 0,
              child: Container(
                child: Center(
                  child: YourTurnAnimation(),
                ),
              ),
            )
          ];
        });
      });
    }

    Future.delayed(Duration(seconds: 1 + (3 * (1 + animations.length))), () {
      setState(() {
        _stepAnimations = [];
      });
    });
  }
}
