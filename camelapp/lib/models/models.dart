import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class GameState {
  int errorCode;
  Game game;
  String playerId;

  GameState(this.errorCode, this.playerId);

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  Map<String, dynamic> toJson() => _$GameStateToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Game {
  String id;
  List<Camel> camels;
  List<Player> players;
  List<List<int>> circuit;
  List<List<RoundMarketCard>> roundCards;
  int playerTurn;
  bool gameStarted;
  bool gameEnded;

  Game(this.id, this.camels, this.players, this.circuit, this.roundCards,
      this.playerTurn, this.gameStarted, this.gameEnded);

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class RoundMarketCard {
  int points;
  int playerId;

  RoundMarketCard(this.points, this.playerId);

  factory RoundMarketCard.fromJson(Map<String, dynamic> json) =>
      _$RoundMarketCardFromJson(json);

  Map<String, dynamic> toJson() => _$RoundMarketCardToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Player {
  String id;
  int points;

  Player(this.id, this.points);

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Camel {
  int id;

  Camel(this.id);

  factory Camel.fromJson(Map<String, dynamic> json) => _$CamelFromJson(json);

  Map<String, dynamic> toJson() => _$CamelToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class GameRequest {
  String gameId;
  bool newGame;
  bool newPlayer;
  bool startGame;
  bool throwDice;
  String playerId;
  int getCamelRoundCard;

  GameRequest(
      {this.gameId = "",
      this.newGame = false,
      this.newPlayer = false,
      this.startGame = false,
      this.throwDice = false,
      this.playerId = "",
      this.getCamelRoundCard = 0});

  factory GameRequest.fromJson(Map<String, dynamic> json) =>
      _$GameRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GameRequestToJson(this);
}
