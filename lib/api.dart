import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:cthulu_character_creator/views/character_creator/form_data.dart';

abstract interface class Api {
  Future<Form> getForm(String gameId);
  Future<void> submitForm(FormResponseData submission);

  /// Initializes a new game, reserving its name in the database and doing any
  /// setup for its game system.
  ///
  /// Throws [ApiError] if the game already exists.
  Future<void> createGame(String gameName, GameSystem system);
}

class ApiError implements Exception {
  ApiError.gameExists(String gameName) : message = 'Game $gameName already exists';

  final String message;
}
