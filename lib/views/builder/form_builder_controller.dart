import 'package:cthulu_character_creator/api.dart';
import 'package:flutter/material.dart';
import 'package:cthulu_character_creator/model/form.dart' as m;

class FormBuilderController with ChangeNotifier {
  FormBuilderController(this._api);

  final Api _api;

  late String _gameId;
  String get gameId => _gameId;

  m.Form _form = [];
  m.Form get form => _form.toList();

  Future<void> load(String gameId) async {
    _form = await _api.getForm(gameId) ?? [];
    _gameId = gameId;
  }
}
