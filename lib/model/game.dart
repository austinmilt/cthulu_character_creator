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
}
