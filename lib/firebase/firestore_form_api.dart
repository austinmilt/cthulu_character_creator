import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/firebase/serdes.dart';
import 'package:cthulu_character_creator/firebase/model/game.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:cthulu_character_creator/views/character_creator/form_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// https://firebase.google.com/codelabs/firebase-get-to-know-flutter#4

class FirestoreFormApi implements Api {
  FirestoreFormApi(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Form> getForm(String gameId) async {
    final snapshot = await _gameRef(gameId).get();
    final List<Map<String, dynamic>> formJson = snapshot.get(_keys.game_.form);
    return serdes.form.fromJson(formJson);
  }

  @override
  Future<void> submitForm(FormResponseData submission) async {
    await _gameRef(submission.gameId)
        .collection(_keys.game_.responses)
        .doc(_formResponseKey(submission))
        .set(serdes.formResponse.toJson(submission));
  }

  String _formResponseKey(FormResponseData submission) {
    var bytes = utf8.encode(submission.email);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> createGame(String gameId, GameSystem system) async {
    final bool gameExists = (await _gameRef(gameId).get()).exists;
    if (gameExists) {
      throw ApiError.gameExists(gameId);
    }
    final Game game = Game(gameSystem: system);
    await _gameRef(gameId).set(game.toJson());
  }

  DocumentReference _gameRef(String gameId) {
    return _firestore.collection(_keys.games).doc(gameId);
  }
}

const _keys = (
  games: 'games',
  game_: (
    form: 'form',
    responses: 'responses',
  ),
);
