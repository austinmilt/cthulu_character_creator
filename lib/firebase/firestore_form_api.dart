import 'dart:math';

import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/firebase/serdes.dart';
import 'package:cthulu_character_creator/firebase/game.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:word_generator/word_generator.dart';

// https://firebase.google.com/codelabs/firebase-get-to-know-flutter#4

class FirestoreFormApi implements Api {
  FirestoreFormApi(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<Form> getForm(String gameId) async {
    final snapshot = await _gameRef(gameId).get();
    final List<Map<String, dynamic>> formJson =
        (snapshot.get(_keys.game_.form) as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    return serdes.form.fromJson(formJson);
  }

  @override
  Future<String> submitForm(String gameId, FormResponse submission) async {
    submission.id ??= _formResponseKey(submission);
    await _gameRef(gameId)
        .collection(_keys.game_.responses)
        .doc(submission.id)
        .set(serdes.formResponse.toJson(submission));

    return submission.id!;
  }

  String _formResponseKey(FormResponse submission) {
    final List<String> possessiveOptions = ["my", "your", "their", "her", "his"];
    final String possessive = possessiveOptions[_rand.nextInt(possessiveOptions.length)];
    final String verb = _specialVerb();
    final String noun = _wordGenerator.randomNoun();
    // TODO check that the key is unique before returning
    return '$possessive-$verb-$noun';
  }

  String _specialVerb() {
    String candidate = "";
    while (!candidate.endsWith('ing') && !candidate.endsWith("ed")) {
      candidate = _wordGenerator.randomVerb();
    }
    return candidate;
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

final _wordGenerator = WordGenerator();
final _rand = Random.secure();

const _keys = (
  games: 'games',
  game_: (
    form: 'form',
    responses: 'responses',
  ),
);
