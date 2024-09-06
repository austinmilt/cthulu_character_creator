import 'package:cthulu_character_creator/model/game_system.dart';

class Game {
  Game({required this.gameSystem});

  final GameSystem gameSystem;

  Map<String, dynamic> toJson() {
    return {'gameSystem': gameSystem.name};
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(gameSystem: GameSystem.fromName(json['gameSystem']));
  }
}
