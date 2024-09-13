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
import 'package:cthulu_character_creator/firebase/crypto.dart';
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
    _logger.debug("Getting form for game $gameId");
    final snapshot = await _gameRef(gameId).get();
    final List<Map<String, dynamic>> formJson =
        (snapshot.get(_keys.game_.form) as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    final Form result = serdes.form.fromJson(formJson);
    _logger.debug("Got form for game $gameId: $result");
    return result;
  }

  @override
  Future<({String id, String editAuthSecret})> submitForm(String gameId, FormResponse submission) async {
    final bool userIsAuthorizedToSubmit = await _userHasAuthorityToSubmit(gameId, submission);
    if (!userIsAuthorizedToSubmit) {
      _logger.warn("User not authorized to submit for game $gameId and submission $submission");
      throw ApiError.unauthorized(gameId);
    }
    submission.id ??= _formResponseKey();
    submission.editAuthSecret ??= _editAuthSecret();
    _logger.debug("Submitting response for game $gameId: $submission");
    await _responseRef(gameId, submission.id!).set(serdes.formResponse.toJson(submission));
    _logger.debug("Done submitting response ${submission.id} for game $gameId");
    return (id: submission.id!, editAuthSecret: submission.editAuthSecret!);
  }

  String _formResponseKey() {
    return myRandomPhrase();
  }

  // insecure to let the client set the secret but this aint Fort Knox
  String _editAuthSecret() {
    return myRandomAlpha(10);
  }

  Future<bool> _userHasAuthorityToSubmit(String gameId, FormResponse submission) async {
    final bool isEdit = submission.id != null;
    if (isEdit) {
      final String id = submission.id!;
      final String? authSecret = submission.editAuthSecret;
      if (authSecret == null) return false;

      // We want to check that if the response exists that the user has the right
      // secret to edit it. We check that by looking to see if there is an instance
      // of a response with that ID with a secret different than what was given, which
      // indicates the user does not have the right secret and is not authorized.
      final AggregateQuerySnapshot isAuthorizedQuery = await _responsesRef(gameId)
          .where(Filter.and(
            Filter(_keys.game_.responses_.id, isEqualTo: id),
            Filter(_keys.game_.responses_.editAuthSecret, isNotEqualTo: authSecret),
          ))
          .limit(1)
          .count()
          .get();

      return (isAuthorizedQuery.count == null) || (isAuthorizedQuery.count == 0);
    }
    return true;
  }

  @override
  Future<void> createGame(String gameId, GameSystem system) async {
    _logger.debug("Want to create game $gameId");
    final DocumentReference gameDoc = _gameRef(gameId);
    final bool gameExists = (await gameDoc.get()).exists;
    if (gameExists) {
      _logger.warn("Game $gameId already exists");
      throw ApiError.gameExists(gameId);
    }
    final Game game = Game(gameSystem: system);
    await gameDoc.set(game.toJson());
    _logger.debug("Created game $gameId with system ${system.name}");
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
        validationFutures.add(_validateEmail(submission.id, field, response, responsesRef));
      } else if (fieldWrapper.isSingleSelect) {
        final SingleSelectFormField field = fieldWrapper.singleSelectRequired;
        final SingleSelectResponse? response = submission.fields[field.key]?.singleSelect;
        validationFutures.add(_validateSingleSelect(submission.id, field, response, responsesRef));
      } else if (fieldWrapper.isText) {
        final TextFormField field = fieldWrapper.textRequired;
        final TextResponse? response = submission.fields[field.key]?.text;
        validationFutures.add(_validateText(submission.id, field, response, responsesRef));
      } else if (fieldWrapper.isTextArea) {
        final TextAreaFormField field = fieldWrapper.textAreaRequired;
        final TextAreaResponse? response = submission.fields[field.key]?.textArea;
        validationFutures.add(_validateTextArea(submission.id, field, response, responsesRef));
      } else if (fieldWrapper.isInfo) {
        // skip known non-response fields
      } else {
        throw UnimplementedError("BUG: Unknown how to handle $fieldWrapper");
      }
    }
    final List<String?> validations = await Future.wait(validationFutures);
    final List<String> nonEmptyValidations = validations.whereType<String>().toList();
    _logger.debug("Validation results: $nonEmptyValidations");
    return nonEmptyValidations;
  }

  Future<String?> _validateCocSkillset(CoCSkillsetFormField field, CocSkillsetResponse? response) async {
    if (field.required && (response == null) || (response!.isEmpty)) {
      _logger.debug("Received an invalid skillset");
      return "${field.key}: Skillset cannot be empty";
    }
    return null;
  }

  Future<String?> _validateEmail(
    String? submissionId,
    EmailFormField field,
    EmailResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid email");
      return "${field.key}: Email is required";
    }
    if (field.slots != null) {
      final String emailKey =
          '${_keys.game_.responses_.fields}.${field.key}.${_keys.game_.responses_.fields_.key_.email}';
      final String idKey = _keys.game_.responses_.id;
      final Filter takenFilter = Filter.and(
        Filter(idKey, isNotEqualTo: submissionId),
        Filter(emailKey, isEqualTo: response),
      );
      // TODO could create a race condition since it's not atomic (likewise elsewhere)
      final AggregateQuerySnapshot queryResult = await responses.where(takenFilter).limit(field.slots!).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        _logger.debug("Received an email that was already taken ($slotsTaken/${field.slots} slots)");
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  Future<String?> _validateSingleSelect(
    String? submissionId,
    SingleSelectFormField field,
    SingleSelectResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid singleSelect");
      return "${field.key}: Selection is required";
    }
    if (field.slots != null) {
      final String singleSelectKey =
          '${_keys.game_.responses_.fields}.${field.key}.${_keys.game_.responses_.fields_.key_.singleSelect}';
      final String idKey = _keys.game_.responses_.id;
      final Filter takenFilter = Filter.and(
        Filter(idKey, isNotEqualTo: submissionId),
        Filter(singleSelectKey, isEqualTo: response),
      );
      final AggregateQuerySnapshot queryResult = await responses.where(takenFilter).limit(field.slots!).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        _logger.debug("Received a singleSelect that was already taken ($slotsTaken/${field.slots} slots)");
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  Future<String?> _validateText(
    String? submissionId,
    TextFormField field,
    TextResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid text");
      return "${field.key}: Response is required";
    }
    if (field.slots != null) {
      final String textKey =
          '${_keys.game_.responses_.fields}.${field.key}.${_keys.game_.responses_.fields_.key_.text}';
      final String idKey = _keys.game_.responses_.id;
      final Filter takenFilter = Filter.and(
        Filter(idKey, isNotEqualTo: submissionId),
        Filter(textKey, isEqualTo: response),
      );
      final AggregateQuerySnapshot queryResult = await responses.where(takenFilter).limit(field.slots!).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        _logger.debug("Received a text that was already taken ($slotsTaken/${field.slots} slots)");
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  Future<String?> _validateTextArea(
    String? submissionId,
    TextAreaFormField field,
    TextAreaResponse? response,
    CollectionReference responses,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid textArea");
      return "${field.key}: Response is required";
    }
    if (field.slots != null) {
      final String textAreaKey =
          '${_keys.game_.responses_.fields}.${field.key}.${_keys.game_.responses_.fields_.key_.textArea}';
      final String idKey = _keys.game_.responses_.id;
      final Filter takenFilter = Filter.and(
        Filter(idKey, isNotEqualTo: submissionId),
        Filter(textAreaKey, isEqualTo: response),
      );
      final AggregateQuerySnapshot queryResult = await responses.where(takenFilter).limit(field.slots!).count().get();
      final int slotsTaken = queryResult.count ?? 0;
      if (slotsTaken >= field.slots!) {
        _logger.debug("Received a textArea that was already taken ($slotsTaken/${field.slots} slots)");
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

const _keys = (
  games: 'games',
  game_: (
    form: 'form',
    responses: 'responses',
    responses_: (
      id: 'id',
      editAuthSecret: 'editAuthSecret',
      fields: 'fields',
      fields_: (
        key_: (
          email: 'email',
          singleSelect: 'singleSelect',
          text: 'text',
          textArea: 'textArea',
        ),
      ),
    )
  ),
);
