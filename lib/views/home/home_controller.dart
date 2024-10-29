import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/model/game.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:flutter/material.dart';

class HomeController with ChangeNotifier {
  HomeController(this._api);

  final Api _api;

  Future<Game> createGame(String gameName, GameSystem system) async {
    return _api.createGame(gameName, system);
  }
}
