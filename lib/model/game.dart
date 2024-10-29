import 'package:cthulu_character_creator/model/game_system.dart';

class Game {
  Game({
    required this.id,
    required this.gameSystem,
    required this.auth,
  });

  final String id;
  final GameSystem gameSystem;
  final String auth;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameSystem': gameSystem.name,
      'auth': auth,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(id: json['id'], gameSystem: GameSystem.fromName(json['gameSystem']), auth: json['auth']);
  }
}
