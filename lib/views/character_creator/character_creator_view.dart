import 'package:cthulu_character_creator/views/character_creator/character_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CharacterCreatorView extends StatelessWidget {
  const CharacterCreatorView({super.key, required this.gameId});

  final String gameId;

  static final GoRoute route = GoRoute(
    name: 'character-creator',
    path: '/character/create/:gameId',
    builder: (context, state) {
      final String? gameId = state.pathParameters['gameId'];
      if (gameId == null) {
        throw StateError('Tried to navigate to character creator without a game ID');
      }
      return CharacterCreatorView(gameId: gameId);
    },
  );

  static void navigate(BuildContext context, String gameId) {
    context.goNamed(route.name!, pathParameters: {gameId: gameId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainForm(gameId: gameId),
    );
  }
}
