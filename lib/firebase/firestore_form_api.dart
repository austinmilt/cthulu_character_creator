import 'dart:math';

import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/field.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/response.dart';
import 'package:cthulu_character_creator/fields/email/field.dart';
import 'package:cthulu_character_creator/fields/email/response.dart';
import 'package:cthulu_character_creator/fields/single_select/field.dart';
import 'package:cthulu_character_creator/fields/single_select/response.dart';
import 'package:cthulu_character_creator/fields/text/field.dart';
import 'package:cthulu_character_creator/fields/text/response.dart';
import 'package:cthulu_character_creator/fields/text_area/field.dart';
import 'package:cthulu_character_creator/fields/text_area/response.dart';
import 'package:cthulu_character_creator/firebase/random_words.dart';
import 'package:cthulu_character_creator/firebase/serdes.dart';
import 'package:cthulu_character_creator/firebase/game.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// https://firebase.google.com/codelabs/firebase-get-to-know-flutter#4

class FirestoreFormApi implements Api {
  FirestoreFormApi(this._firestore, this._logger);

  final FirebaseFirestore _firestore;
  final Logger _logger;

  @override
  Future<Form> getForm(String gameId) async {
    final snapshot = await _gameRef(gameId).get();
    final List<Map<String, dynamic>> formJson =
        (snapshot.get(_keys.game_.form) as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    return serdes.form.fromJson(formJson);
  }

  @override
  Future<String> submitForm(String gameId, FormResponse submission) async {
    // TODO validate the user is using the correct edit passphrase (URL)
    final bool isEdit = submission.id != null;
    submission.id ??= _formResponseKey();
    await _responseRef(gameId, submission.id!).set(serdes.formResponse.toJson(submission));
    return submission.id!;
  }

  String _formResponseKey() {
    return myRandomPhrase();
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

  @override
  Future<List<String>> validateSubmission(String gameId, Form form, FormResponse submission) async {
    final CollectionReference responsesRef = _responsesRef(gameId);
    final List<Future<String?>> validationFutures = [];
    for (FormField fieldWrapper in form) {
      if (fieldWrapper.isCocSkillset) {
        final CoCSkillsetFormField field = fieldWrapper.cocSkillsetRequired;
        final CocSkillsetResponse? response = submission.fields[field.key]?.cocSkillset;
        validationFutures.add(_validateCocSkillset(field, response));
      } else if (fieldWrapper.isEmail) {
        final EmailFormField field = fieldWrapper.emailRequired;
        final EmailResponse? response = submission.fields[field.key]?.email;
        validationFutures.add(_validateEmail(field, response, responsesRef));
      } else if (fieldWrapper.isSingleSelect) {
        final SingleSelectFormField field = fieldWrapper.singleSelectRequired;
        final SingleSelectResponse? response = submission.fields[field.key]?.singleSelect;
        validationFutures.add(_validateSingleSelect(field, response, responsesRef));
      } else if (fieldWrapper.isText) {
        final TextFormField field = fieldWrapper.textRequired;
        final TextResponse? response = submission.fields[field.key]?.text;
        validationFutures.add(_validateText(field, response, responsesRef));
      } else if (fieldWrapper.isTextArea) {
        final TextAreaFormField field = fieldWrapper.textAreaRequired;
        final TextAreaResponse? response = submission.fields[field.key]?.textArea;
        validationFutures.add(_validateTextArea(field, response, responsesRef));
      } else if (fieldWrapper.isInfo) {
        // skip known non-response fields
      } else {
        throw UnimplementedError("BUG: Unknown how to handle $fieldWrapper");
      }
    }
    final List<String?> validations = await Future.wait(validationFutures);
    return validations.whereType<String>().toList();
  }

  Future<String?> _validateCocSkillset(CoCSkillsetFormField field, CocSkillsetResponse? response) async {
    // TODO need a better validation?
    if (field.required && (response == null) || (response!.isEmpty)) {
      return "${field.key}: Skillset cannot be empty";
    }
    return null;
  }

  Future<String?> _validateEmail(
    EmailFormField field,
    EmailResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && (response == null) || (response!.trim().isEmpty)) {
      return "${field.key}: Email is required";
    }
    if (field.slots != null) {
      // TODO could create a race condition since it's not atomic (likewise elsewhere)
      final AggregateQuerySnapshot queryResult =
          await responses.where("fields.${field.key}.email", isEqualTo: response).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  Future<String?> _validateSingleSelect(
    SingleSelectFormField field,
    SingleSelectResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && (response == null) || (response!.trim().isEmpty)) {
      return "${field.key}: Selection is required";
    }
    if (field.slots != null) {
      final AggregateQuerySnapshot queryResult =
          await responses.where("fields.${field.key}.singleSelect", isEqualTo: response).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  Future<String?> _validateText(
    TextFormField field,
    TextResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && (response == null) || (response!.trim().isEmpty)) {
      return "${field.key}: Response is required";
    }
    if (field.slots != null) {
      final AggregateQuerySnapshot queryResult =
          await responses.where("fields.${field.key}.text", isEqualTo: response).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  Future<String?> _validateTextArea(
    TextAreaFormField field,
    TextAreaResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && (response == null) || (response!.trim().isEmpty)) {
      return "${field.key}: Response is required";
    }
    if (field.slots != null) {
      final AggregateQuerySnapshot queryResult =
          await responses.where("fields.${field.key}.textArea", isEqualTo: response).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  DocumentReference _responseRef(String gameId, String submissionId) {
    return _responsesRef(gameId).doc(submissionId);
  }

  CollectionReference _responsesRef(String gameId) {
    return _gameRef(gameId).collection(_keys.game_.responses);
  }

  DocumentReference _gameRef(String gameId) {
    return _firestore.collection(_keys.games).doc(gameId);
  }
}

final _rand = Random.secure();

const _keys = (
  games: 'games',
  game_: (
    form: 'form',
    responses: 'responses',
  ),
);
