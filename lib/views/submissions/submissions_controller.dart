import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:flutter/material.dart';

class SubmissionsController with ChangeNotifier {
  SubmissionsController(this._api);

  final Api _api;

  late String _gameId;
  String get gameId => _gameId;

  late List<FormResponseSummary> _summaries;
  // copy the list to preven the user from editing the private variable contens
  List<FormResponseSummary> get summaries => _summaries.toList();

  Future<void> load(String gameId, String auth) async {
    List<FormResponseSummary>? response = await _api.getSubmissionSummaries(gameId, auth);
    if (response != null) {
      _summaries = response;
      _gameId = gameId;
    }
  }
}
