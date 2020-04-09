import 'package:camelapp/board_game.dart';
import 'package:camelapp/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayersInfo extends StatelessWidget {
  final GameState gameState;
  final String playerId;
  PlayersInfo({this.gameState, this.playerId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff3e1c9),
      child: Column(
        children: <Widget>[
          buildYourTurnHint(),
          ...buildPlayerDetails(),
          // Row(
          //   children: <Widget>[
          //     Expanded(
          //       child: Container(
          //           color: Color(0xfff3e1c9), child: buildPlayer(0, 0)),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget buildYourTurnHint() {
    var playerIndex = 0;
    for (var i = 0; i < this.gameState.game.players.length; i++) {
      if (this.gameState.game.players[i].id == this.playerId) {
        playerIndex = i + 1;
        break;
      }
    }
    if (this.gameState.game.playerTurn != playerIndex) {
      return SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(0xffffd700),
        borderRadius: new BorderRadius.only(
          bottomLeft: const Radius.circular(17.0),
          bottomRight: const Radius.circular(17.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 40),
        child: Text("Es el teu torn"),
      ),
    );
  }

  List<Widget> buildPlayerDetails() {
    var ps = <Widget>[];

    for (var i = 0; i < this.gameState.game.players.length; i++) {
      var player = this.gameState.game.players[i];

      var cards = <RoundCardCompleteDetails>[];
      var player_index = i + 1;
      for (var j = 0; j < this.gameState.game.roundCards.length; j++) {
        var camelCards = this.gameState.game.roundCards[j];
        for (var card in camelCards) {
          if (card.playerId == player_index) {
            cards.add(RoundCardCompleteDetails(
              card.points,
              j,
            ));
          }
        }
      }

      ps.add(Row(children: <Widget>[buildPlayer(i, player.points, cards)]));
    }

    return ps;
  }

  Widget buildPlayer(
      int playerId, int points, List<RoundCardCompleteDetails> cards) {
    var cardsW = <Widget>[];
    for (var card in cards) {
      cardsW.add(Container(
        width: 30,
        height: 35,
        decoration: BoxDecoration(
          color: getCamelColor(card.camelId),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),
        child: Center(
            child: Text("${card.points}", style: TextStyle(fontSize: 24))),
      ));
    }
    return Wrap(
      spacing: 14,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Container(
          height: 50,
          width: 10,
          color: getPlayerColor(playerId),
        ),
        Text("$points pt", style: TextStyle(fontSize: 24)),
        ...cardsW,
      ],
    );
  }

  Color getPlayerColor(int player_id) {
    switch (player_id) {
      case 0:
        return Colors.indigo;
      case 1:
        return Colors.pink;
      case 2:
        return Colors.teal;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.amber;
      case 6:
        return Colors.red;
      case 7:
        return Colors.cyan;
    }
  }
}

class RoundCardCompleteDetails {
  int points;
  int camelId;
  RoundCardCompleteDetails(this.points, this.camelId);
}
