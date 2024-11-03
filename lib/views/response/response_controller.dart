import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/model/form_response.dart';
import 'package:flutter/material.dart';
import 'package:cthulu_character_creator/model/form.dart';

abstract interface class ResponseController with ChangeNotifier {
  String get gameId;
  C4Form get form;
  FormResponse? get submission;
  bool get submitting;
  bool get validating;
  bool get canEditResponse;
  Future<void> load(String gameId, String? responseId, String? editAuthSecret);
  Future<void> submit(FormResponse submission);
  Future<List<String>> validationSubmission(FormResponse submission);
  int? slotsRemaining(String fieldKey, String fieldOption);
  C4FormField? getField(int fieldIndex);
  FieldResponseController getFieldController(int fieldIndex);
}

class MainResponseController with ChangeNotifier implements ResponseController {
  MainResponseController(this._api);

  final Api _api;

  late String _gameId;
  @override
  String get gameId => _gameId;

  late C4Form _form;
  @override
  C4Form get form => _form;

  FormResponse? _submission;
  @override
  FormResponse? get submission => _submission;

  late Map<String, Map<String, int>> _slotsRemaining;

  bool _submitting = false;
  @override
  bool get submitting => _submitting;

  bool _validating = true;
  @override
  bool get validating => _validating;

  bool _canEditResponse = false;
  @override
  bool get canEditResponse => _canEditResponse;

  @override
  Future<void> load(String gameId, String? responseId, String? editAuthSecret) async {
    final List<Future> futures = [];
    futures.add(_api.getForm(gameId).then((f) async {
      if (f != null) {
        _form = f;
        _slotsRemaining = await _api.getSlotsRemaining(gameId, f);
      }
    }));
    if (responseId != null) {
      futures.add(_api.getSubmission(gameId, responseId).then((s) {
        _submission = (s == null)
            ? null
            : FormResponse(
                id: s.id ?? responseId,
                editAuthSecret: s.editAuthSecret ?? editAuthSecret,
                fields: s.fields,
              );
      }));
    }

    final bool newSubmission = (responseId == null) && (editAuthSecret == null);
    final bool editingSubmission = (responseId != null) && (editAuthSecret != null);
    _canEditResponse = newSubmission || editingSubmission;

    await Future.wait(futures);
    _gameId = gameId;
  }

  @override
  Future<void> submit(FormResponse submission) async {
    _submitting = true;
    notifyListeners();

    try {
      final FormResponse submissionWithAuth = FormResponse(
        id: submission.id ?? _submission?.id,
        editAuthSecret: submission.editAuthSecret ?? _submission?.editAuthSecret,
        fields: submission.fields,
      );
      final response = await _api.submitForm(_gameId, submissionWithAuth);
      _submission = FormResponse(
        id: response.id,
        editAuthSecret: response.editAuthSecret,
        fields: submission.fields,
      );
      _canEditResponse = true;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  @override
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

  @override
  int? slotsRemaining(String fieldKey, String fieldOption) {
    return _slotsRemaining[fieldKey]?[fieldOption];
  }

  @override
  C4FormField? getField(int fieldIndex) {
    return _form[fieldIndex];
  }

  @override
  FieldResponseController getFieldController(int fieldIndex) {
    final C4FormField spec = getField(fieldIndex)!;
    final String? key = spec.key();
    final result = FieldResponseController(spec, _canEditResponse, _submission?.fields[key], _slotsRemaining[key]);
    if (key != null) {
      result.addListener(() {
        final FormFieldResponse? fieldResponse = result.response;
        if (fieldResponse != null) {
          _submission ??= FormResponse(
            id: null,
            editAuthSecret: submission?.editAuthSecret,
            fields: {},
          );
          _submission!.fields[key] = fieldResponse;
        }
      });
    }
    return result;
  }
}

class FieldResponseController with ChangeNotifier {
  FieldResponseController(this.spec, this.canEdit, [this._response, this._slotsRemaining]);

  final C4FormField spec;

  final bool canEdit;

  final Map<String, int>? _slotsRemaining;
  int? getSlotsRemaining(String value) {
    return _slotsRemaining?[value];
  }

  FormFieldResponse? _response;
  FormFieldResponse? get response => _response;
  set response(FormFieldResponse? newResponse) {
    _response = newResponse;
    notifyListeners();
  }
}
