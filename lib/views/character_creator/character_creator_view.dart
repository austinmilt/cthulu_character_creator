import 'package:cthulu_character_creator/views/character_creator/character_form_v2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CharacterCreatorView extends StatelessWidget {
  const CharacterCreatorView({
    super.key,
    required this.gameId,
    this.responseId,
    this.editAuthSecret,
  });

  final String gameId;
  final String? responseId;
  final String? editAuthSecret;

  static final GoRoute newRoute = GoRoute(
    name: 'character-creator-new',
    path: '/character/create/:gameId',
    builder: (context, state) {
      final String? gameId = state.pathParameters['gameId'];
      if (gameId == null) {
        throw StateError('Tried to navigate to character creator without a game ID');
      }
      return CharacterCreatorView(gameId: gameId);
    },
  );

  static final GoRoute editRoute = GoRoute(
    name: 'character-creator-edit',
    path: '/character/create/:gameId/:responseId',
    builder: (context, state) {
      final String? gameId = state.pathParameters['gameId'];
      final String? responseId = state.pathParameters['responseId'];
      final String? editAuthSecret = state.uri.queryParameters['s'];
      if (gameId == null) {
        throw StateError('Tried to navigate to character creator without a game ID');
      }
      return CharacterCreatorView(
        gameId: gameId,
        responseId: responseId,
        editAuthSecret: editAuthSecret,
      );
    },
  );

  static void navigate(BuildContext context, String gameId, String? responseId, String? editAuthSecret) {
    final Map<String, String> pathParams = {};
    final Map<String, String> queryParams = {};
    pathParams['gameId'] = gameId;
    if (responseId != null) pathParams['responseId'] = responseId;
    if (editAuthSecret != null) queryParams['s'] = editAuthSecret;
    context.goNamed(editRoute.name!, pathParameters: pathParams, queryParameters: queryParams);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainForm(
        gameId: gameId,
        responseId: responseId,
        editAuthSecret: editAuthSecret,
      ),
    );
  }
}
