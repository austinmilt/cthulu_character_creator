import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/model/form_response.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:cthulu_character_creator/model/form.dart';

class FormBuilderController with ChangeNotifier {
  FormBuilderController(this._api) {
    _responseController = _MockResponseController(this);
  }

  final Api _api;
  late final _MockResponseController _responseController;

  ResponseController get responseController => _responseController;

  late String _gameId;
  String get gameId => _gameId;

  late String _edithAuthSecret;
  String get editAuthSecret => _edithAuthSecret;

  List<C4FormField?> _form = [];
  List<C4FormField?> get partialForm => _form.toList();

  bool _editing = true;
  bool get editing => _editing;
  set editing(bool newValue) {
    _editing = newValue;
    notifyListeners();
  }

  final Map<int, FieldBuilderController> _fieldControllers = {};

  Future<void> load(String gameId, String authSecret) async {
    _form = await _api.getForm(gameId) ?? [];
    _gameId = gameId;
    _edithAuthSecret = authSecret;
  }

  Future<void> save() async {
    await _api.saveForm(gameId, _form.nonNulls.toList(), _edithAuthSecret);
  }

  void addField(C4FormField field) {
    _form.add(field);
    notifyListeners();
  }

  void removeField(int index) {
    final C4FormField? field = _getField(index);
    if (field == null) {
      throw StateError('Tried to remove a field (index=$index) that doesnt exist');
    }
    _form.removeAt(index);
    _fieldControllers.remove(index)?.dispose();
    notifyListeners();
  }

  FieldBuilderController getFieldController(int index) {
    final C4FormField? field = _getField(index);
    if (field == null) {
      throw StateError('Tried to get a controller for a field (index=$index) that doesnt exist yet');
    }
    FieldBuilderController? result = _fieldControllers[index];
    if (result == null) {
      result = FieldBuilderController._(field, _editing);
      result.addListener(() {
        _form[index] = result!._spec;
        notifyListeners();
      });
      _fieldControllers[index] = result;
    }
    result.editing = _editing;
    return result;
  }

  C4FormField? _getField(int index) {
    return (_form.length > index) ? _form[index] : null;
  }
}

class FieldBuilderController with ChangeNotifier {
  FieldBuilderController._(this._spec, this.editing);

  C4FormField _spec;
  C4FormField get spec => _spec;
  set spec(C4FormField newValue) {
    _spec = newValue;
    notifyListeners();
  }

  bool editing;
}

/// Implementation of the response controller that mocks context for previewing
/// the form.
class _MockResponseController with ChangeNotifier implements ResponseController {
  _MockResponseController(this._builderController);

  final FormBuilderController _builderController;

  @override
  bool get canEditResponse => true;

  @override
  C4Form get form => _builderController.partialForm.where((t) => t != null).map<C4FormField>((e) => e!).toList();

  @override
  String get gameId => _builderController.gameId;

  @override
  Future<void> load(String gameId, String? responseId, String? editAuthSecret) async {}

  @override
  int? slotsRemaining(String fieldKey, String fieldOption) => 1;

  @override
  FormResponse? get submission => null;

  @override
  Future<void> submit(FormResponse submission) async {}

  @override
  bool get submitting => false;

  @override
  bool get validating => false;

  @override
  Future<List<String>> validationSubmission(FormResponse submission) async => [];

  @override
  C4FormField? getField(int fieldIndex) {
    return _builderController._form[fieldIndex];
  }

  @override
  FieldResponseController getFieldController(int fieldIndex) {
    final C4FormField spec = getField(fieldIndex)!;
    return FieldResponseController(spec, true, null);
  }
}
