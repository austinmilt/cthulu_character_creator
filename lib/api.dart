import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:cthulu_character_creator/model/form_data.dart';

abstract interface class Api {
  Future<Form> getForm(String gameId);

  /// Checks that [submission] is valid for [gameId], such as checking
  /// for unique responses, and returns a list of user-friendly validation
  /// error messages, which could be empty.
  Future<List<String>> validateSubmission(String gameId, Form form, FormResponse submission);

  /// Upserts the response and returns its key and auth secret (for editing).
  Future<({String id, String editAuthSecret})> submitForm(String gameId, FormResponse submission);

  /// Initializes a new game, reserving its name in the database and doing any
  /// setup for its game system.
  ///
  /// Throws [ApiError] if the game already exists.
  Future<void> createGame(String gameName, GameSystem system);
}

class ApiError implements Exception {
  ApiError.gameExists(String gameName) : message = 'Game $gameName already exists';
  ApiError.unauthorized(String gameName) : message = 'Not authorized on game $gameName';

  final String message;
}
