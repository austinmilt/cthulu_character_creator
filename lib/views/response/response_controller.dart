import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:flutter/material.dart';
import 'package:cthulu_character_creator/model/form.dart' as m;

class ResponseController with ChangeNotifier {
  ResponseController(this._api);

  final Api _api;

  late String _gameId;
  String get gameId => _gameId;

  late m.Form _form;
  m.Form get form => _form;

  FormResponse? _submission;
  FormResponse? get submission => _submission;

  late String _submissionId;
  String get submissionId => _submissionId;

  late String _editAuthSecret;
  String get editAuthSecret => _editAuthSecret;

  late Map<String, Map<String, int>> _slotsRemaining;

  bool _submitting = false;
  bool get submitting => _submitting;

  bool _validating = true;
  bool get validating => _validating;

  bool _canEditResponse = false;
  bool get canEditResponse => _canEditResponse;

  Future<void> load(String gameId, String? responseId, String? editAuthSecret) async {
    final List<Future> futures = [];
    futures.add(_api.getForm(gameId).then((f) async {
      if (f != null) {
        _form = f;
        _slotsRemaining = await _api.getSlotsRemaining(gameId, f);
      }
    }));
    if (responseId != null) {
      futures.add(_api.getSubmission(gameId, responseId).then((s) => _submission = s));
    }

    final bool newSubmission = (responseId == null) && (editAuthSecret == null);
    final bool editingSubmission = (responseId != null) && (editAuthSecret != null);
    _canEditResponse = newSubmission || editingSubmission;

    await Future.wait(futures);
  }

  Future<void> submit(FormResponse submission) async {
    _submitting = true;
    notifyListeners();

    try {
      final response = await _api.submitForm(_gameId, submission);
      _submission = submission;
      _editAuthSecret = response.editAuthSecret;
      _submissionId = response.id;
      _canEditResponse = true;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<List<String>> validationSubmission(FormResponse submission) async {
    _validating = true;
    notifyListeners();

    try {
      return _api.validateSubmission(_gameId, _form, submission);
    } finally {
      _validating = false;
      notifyListeners();
    }
  }

  int? slotsRemaining(String fieldKey, String fieldOption) {
    return _slotsRemaining[fieldKey]?[fieldOption];
  }
}
