// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return GameState(
    json['error_code'] as int,
    json['player_id'] as String,
  )..game = json['game'] == null
      ? null
      : Game.fromJson(json['game'] as Map<String, dynamic>);
}

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'error_code': instance.errorCode,
      'game': instance.game?.toJson(),
      'player_id': instance.playerId,
    };

Game _$GameFromJson(Map<String, dynamic> json) {
  return Game(
    json['id'] as String,
    (json['camels'] as List)
        ?.map(
            (e) => e == null ? null : Camel.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['players'] as List)
        ?.map((e) =>
            e == null ? null : Player.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['circuit'] as List)
        ?.map((e) => (e as List)?.map((e) => e as int)?.toList())
        ?.toList(),
    (json['round_cards'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : RoundMarketCard.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
    json['player_turn'] as int,
    json['game_started'] as bool,
    json['game_ended'] as bool,
  );
}

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'id': instance.id,
      'camels': instance.camels?.map((e) => e?.toJson())?.toList(),
      'players': instance.players?.map((e) => e?.toJson())?.toList(),
      'circuit': instance.circuit,
      'round_cards': instance.roundCards
          ?.map((e) => e?.map((e) => e?.toJson())?.toList())
          ?.toList(),
      'player_turn': instance.playerTurn,
      'game_started': instance.gameStarted,
      'game_ended': instance.gameEnded,
    };

RoundMarketCard _$RoundMarketCardFromJson(Map<String, dynamic> json) {
  return RoundMarketCard(
    json['points'] as int,
    json['player_id'] as int,
  );
}

Map<String, dynamic> _$RoundMarketCardToJson(RoundMarketCard instance) =>
    <String, dynamic>{
      'points': instance.points,
      'player_id': instance.playerId,
    };

Player _$PlayerFromJson(Map<String, dynamic> json) {
  return Player(
    json['id'] as String,
    json['points'] as int,
  );
}

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'points': instance.points,
    };

Camel _$CamelFromJson(Map<String, dynamic> json) {
  return Camel(
    json['id'] as int,
  );
}

Map<String, dynamic> _$CamelToJson(Camel instance) => <String, dynamic>{
      'id': instance.id,
    };

GameRequest _$GameRequestFromJson(Map<String, dynamic> json) {
  return GameRequest(
    gameId: json['game_id'] as String,
    newGame: json['new_game'] as bool,
    newPlayer: json['new_player'] as bool,
    startGame: json['start_game'] as bool,
    throwDice: json['throw_dice'] as bool,
    playerId: json['player_id'] as String,
    getCamelRoundCard: json['get_camel_round_card'] as int,
  );
}

Map<String, dynamic> _$GameRequestToJson(GameRequest instance) =>
    <String, dynamic>{
      'game_id': instance.gameId,
      'new_game': instance.newGame,
      'new_player': instance.newPlayer,
      'start_game': instance.startGame,
      'throw_dice': instance.throwDice,
      'player_id': instance.playerId,
      'get_camel_round_card': instance.getCamelRoundCard,
    };
