import 'package:cthulu_character_creator/api.dart';
import 'package:flutter/material.dart';
import 'package:cthulu_character_creator/model/form.dart' as m;

class FormBuilderController with ChangeNotifier {
  FormBuilderController(this._api);

  final Api _api;

  late String _gameId;
  String get gameId => _gameId;

  List<m.FormField?> _form = [];

  Future<void> load(String gameId) async {
    _form = await _api.getForm(gameId) ?? [];
    _gameId = gameId;
  }

  m.FormField? getField(int index) {
    return (_form.length > index) ? _form[index] : null;
  }

  void setField(int index, m.FormField field) {
    if (_form.length <= index) {
      for (int i = 0; i < index; i++) {
        _form[i] = null;
      }
    }
    _form[index] = field;
    notifyListeners();
  }
}
