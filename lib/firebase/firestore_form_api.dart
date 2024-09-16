import 'dart:convert';

import 'package:crypto/crypto.dart';
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
  Future<FormResponse?> getSubmission(String gameId, String submissionId) async {
    _logger.debug("Getting response for game $gameId with id $submissionId");
    final snapshot = await _responseRef(gameId, submissionId).get();
    final Map<String, dynamic>? json = snapshot.get(_keys.game_.response_.fields);
    if (json == null) {
      _logger.debug("Response $gameId $submissionId does not exist");
      return null;
    }
    final FormResponse result = serdes.formResponse.fromJson({_keys.game_.response_.fields: json});
    _logger.debug("Got response for game $gameId: $result");
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
    _logger.debug("Updating indexes for game $gameId: ${submission.id}");
    await _updateIndexes(gameId, submission);
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
            Filter(_keys.game_.response_.id, isEqualTo: id),
            Filter(_keys.game_.response_.editAuthSecret, isNotEqualTo: authSecret),
          ))
          .limit(1)
          .count()
          .get();

      return (isAuthorizedQuery.count == null) || (isAuthorizedQuery.count == 0);
    }
    return true;
  }

  Future<void> _updateIndexes(String gameId, FormResponse submission) async {
    final _Index index = _Index.prepare(_firestore, gameId);
    // dont need to load when updating
    await index.update(submission);
  }

  @override
  Future<Game> createGame(String gameId, GameSystem system) async {
    _logger.debug("Want to create game $gameId");
    final DocumentReference gameDoc = _gameRef(gameId);
    final bool gameExists = (await gameDoc.get()).exists;
    if (gameExists) {
      _logger.warn("Game $gameId already exists");
      throw ApiError.gameExists(gameId);
    }
    final Game game = Game(id: gameId, gameSystem: system, auth: myRandomAlpha(10));
    await gameDoc.set(game.toJson());
    _logger.debug("Created game $gameId with system ${system.name}");
    return game;
  }

  @override
  Future<Map<String, Map<String, int>>> getSlotsRemaining(String gameId, Form form) async {
    final _Index index = _Index.prepare(_firestore, gameId);
    await index.load();
    final Map<String, Map<String, int>> result = {};
    for (final FormField field in form) {
      // At present singleSelect is the only field type which we can check slots
      // ahead of time. All other fields are free-form and so can really only
      // be checked at submission time.
      if (field.isSingleSelect) {
        final SingleSelectFormField singleSelectField = field.singleSelectRequired;
        final int? slots = singleSelectField.slots;
        if (slots != null) {
          for (final String option in singleSelectField.options) {
            final int optionUseCount = index.countMatches(singleSelectField.key, null, option);
            result.putIfAbsent(singleSelectField.key, () => {}).putIfAbsent(option, () => 0);
            result[singleSelectField.key]![option] = slots - optionUseCount;
          }
        }
      }
    }
    return result;
  }

  @override
  Future<List<String>> validateSubmission(String gameId, Form form, FormResponse submission) async {
    final List<Future<String?>> validationFutures = [];
    final _Index index = _Index.prepare(_firestore, gameId);
    await index.load();
    for (FormField fieldWrapper in form) {
      if (fieldWrapper.isCocSkillset) {
        final CoCSkillsetFormField field = fieldWrapper.cocSkillsetRequired;
        final CocSkillsetResponse? response = submission.fields[field.key]?.cocSkillset;
        validationFutures.add(_validateCocSkillset(field, response));
      } else if (fieldWrapper.isEmail) {
        final EmailFormField field = fieldWrapper.emailRequired;
        final EmailResponse? response = submission.fields[field.key]?.email;
        validationFutures.add(_validateEmail(submission.id, field, response, index));
      } else if (fieldWrapper.isSingleSelect) {
        final SingleSelectFormField field = fieldWrapper.singleSelectRequired;
        final SingleSelectResponse? response = submission.fields[field.key]?.singleSelect;
        validationFutures.add(_validateSingleSelect(submission.id, field, response, index));
      } else if (fieldWrapper.isText) {
        final TextFormField field = fieldWrapper.textRequired;
        final TextResponse? response = submission.fields[field.key]?.text;
        validationFutures.add(_validateText(submission.id, field, response, index));
      } else if (fieldWrapper.isTextArea) {
        final TextAreaFormField field = fieldWrapper.textAreaRequired;
        final TextAreaResponse? response = submission.fields[field.key]?.textArea;
        validationFutures.add(_validateTextArea(submission.id, field, response, index));
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
    _Index index,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid email");
      return "${field.key}: Email is required";
    }
    if (field.slots != null) {
      // TODO could create a race condition since it's not atomic (likewise elsewhere)
      final int slotsTaken = index.countMatches(field.key, submissionId, response);
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
    _Index index,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid singleSelect");
      return "${field.key}: Selection is required";
    }
    if (field.slots != null) {
      final int slotsTaken = index.countMatches(field.key, submissionId, response);
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
    _Index index,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid text");
      return "${field.key}: Response is required";
    }
    if (field.slots != null) {
      final int slotsTaken = index.countMatches(field.key, submissionId, response);
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
    _Index index,
  ) async {
    if (field.required && ((response == null) || (response.trim().isEmpty))) {
      _logger.debug("Received an invalid textArea");
      return "${field.key}: Response is required";
    }
    if (field.slots != null) {
      final int slotsTaken = index.countMatches(field.key, submissionId, response);
      if (slotsTaken >= field.slots!) {
        _logger.debug("Received a textArea that was already taken ($slotsTaken/${field.slots} slots)");
        return "${field.key}=$response is already taken";
      }
    }
    return null;
  }

  @override
  Future<List<FormResponseSummary>?> getSubmissionSummaries(String gameId, String auth) async {
    final bool userIsAuthorized = await _userHasAuthorityToViewSubmissions(gameId, auth);
    if (!userIsAuthorized) {
      _logger.warn("User not authorized to view submissions for $gameId");
      throw ApiError.unauthorized(gameId);
    }
    _logger.debug("Getting submission summaries for game $gameId");
    // TODO inefficient to read every document just to get summaries, also reveals their
    // secrets to the form owner.
    final snapshots = await _responsesRef(gameId).get();
    final List<FormResponseSummary> result = snapshots.docs.map((d) => FormResponseSummary(id: d.id)).toList();
    _logger.debug("Got the following summaries for $gameId: $result");
    return result;
  }

  Future<bool> _userHasAuthorityToViewSubmissions(String gameId, String auth) async {
    final AggregateQuerySnapshot isAuthorizedQuery = await _gamesRef()
        .where(_keys.game_.id, isEqualTo: gameId)
        .where(_keys.game_.auth, isNotEqualTo: auth)
        .limit(1)
        .count()
        .get();

    return (isAuthorizedQuery.count == null) || (isAuthorizedQuery.count == 0);
  }

  DocumentReference<Map<String, dynamic>> _responseRef(String gameId, String submissionId) {
    return _responsesRef(gameId).doc(submissionId);
  }

  CollectionReference<Map<String, dynamic>> _responsesRef(String gameId) {
    return _gameRef(gameId).collection(_keys.game_.responses);
  }

  DocumentReference<Map<String, dynamic>> _gameRef(String gameId) {
    return _gamesRef().doc(gameId);
  }

  CollectionReference<Map<String, dynamic>> _gamesRef() {
    return _firestore.collection(_keys.games);
  }
}

class _Index {
  _Index.prepare(FirebaseFirestore firestore, String gameId) : _docRef = firestore.collection("indexes").doc(gameId);

  final DocumentReference<Map<String, dynamic>> _docRef;
  late final Map<String, Map<String, String>> _data;

  Future<void> load() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _docRef.get();
    final Map<String, dynamic> json = doc.data() ?? {};
    _data = json.map((f, m) => MapEntry(f, (m as Map).map((k, v) => MapEntry(k, v))));
  }

  Future<void> update(FormResponse submission) async {
    // This is probably really not a great idea, but here's my thinking...
    // - Form owners using this will only need on the order of 10 responses.
    // - The chance of false-positives (errant collisions) is pretty small
    // - It aint that serious
    //
    // "But Firestore has its own indexing." Yes, but the way I set up my data
    // model, it's not straightforward to create firestore indexes and besides those
    // indexes are effectively useless because of how specific my queries are
    // (so the indexes are overkill).

    assert(submission.id != null);
    final String submissionIdHash = _hash(submission.id!);
    final Map<String, Map<String, String>> submissionHashes = {};
    final Map<String, Map<String, dynamic>> submissionFields =
        serdes.formResponse.toJson(submission)[_keys.game_.response_.fields];
    for (MapEntry<String, Map<String, dynamic>> entry in submissionFields.entries) {
      final String fieldKey = entry.key;
      final String responseHash = _hash(jsonEncode(entry.value.entries.first.value));
      submissionHashes[fieldKey] = {submissionIdHash: responseHash};
    }
    return _docRef.set(submissionHashes, SetOptions(merge: true));
  }

  /// Counts the number of submission responses for field [fieldKey] that are
  /// the same as the given [response], excluding those from [submissionId] if
  /// they exist.
  int countMatches(String fieldKey, String? submissionId, dynamic response) {
    int count = 0;
    final String? submissionIdHash = submissionId == null ? null : _hash(submissionId);
    final String responseHash = _hash(jsonEncode(response));
    for (final MapEntry<String, String> entry in (_data[fieldKey]?.entries ?? {})) {
      if ((entry.key != submissionIdHash) && (entry.value == responseHash)) {
        count += 1;
      }
    }
    return count;
  }

  String _hash(String source) {
    return sha1.convert(utf8.encode(source)).toString();
  }
}

const _keys = (
  games: 'games',
  game_: (
    id: 'id',
    auth: 'auth',
    form: 'form',
    responses: 'responses',
    response_: (
      id: 'id',
      editAuthSecret: 'editAuthSecret',
      fields: 'fields',
      field_: (
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
