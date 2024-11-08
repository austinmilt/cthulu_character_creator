import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/game.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:cthulu_character_creator/model/form_response.dart';

abstract interface class Api {
  /// Loads the form for game [gameId], returning [null] if it does not exist.
  Future<C4Form?> getForm(String gameId);

  /// Saves the [form] for game [gameId] using [authSecret].
  Future<void>? saveForm(String gameId, C4Form form, String authSecret);

  /// Loads the form submission for [gameId] with id [submissionId], returning [null] if it does not exist.
  Future<FormResponse?> getSubmission(String gameId, String submissionId);

  /// Checks that [submission] is valid for [gameId], such as checking
  /// for unique responses, and returns a list of user-friendly validation
  /// error messages, which could be empty.
  Future<List<String>> validateSubmission(String gameId, C4Form form, FormResponse submission);

  /// Upserts the response and returns its key and auth secret (for editing).
  Future<({String id, String editAuthSecret})> submitForm(String gameId, FormResponse submission);

  /// Initializes a new game, reserving its name in the database and doing any
  /// setup for its game system.
  ///
  /// Throws [ApiError] if the game already exists.
  Future<Game> createGame(String gameName, GameSystem system);

  /// Gets the count of remaining slots for each field in the [form]. Fields
  /// with unlimited capacity and free-form answers will be excluded from the result.
  /// Returns a map like Map<field_key, Map<field_option, slots_remaining>>>
  Future<Map<String, Map<String, int>>> getSlotsRemaining(String gameId, C4Form form);

  /// Gets summaries of responses submitted for the game [gameId].
  /// Throws an [ApiError] if the user is not authorized to view these responses.
  Future<List<FormResponseSummary>?> getSubmissionSummaries(String gameId, String auth);
}

class ApiError implements Exception {
  ApiError.gameExists(String gameName) : message = 'Game $gameName already exists';
  ApiError.unauthorized(String gameName) : message = 'Not authorized on game $gameName';

  final String message;
}
