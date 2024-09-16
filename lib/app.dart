import 'package:cthulu_character_creator/views/character_creator/character_creator_view.dart';
import 'package:cthulu_character_creator/views/submissions/view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      restorationScopeId: 'app',
      supportedLocales: const [
        Locale('en', ''),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      routerConfig: _router(),
    );
  }
}

GoRouter _router() {
  return GoRouter(
    initialLocation: '/submissions/coc-dragoncon-stakes',
    routes: <RouteBase>[
      CharacterCreatorView.newRoute,
      CharacterCreatorView.existingRoute,
      SubmissionsView.route,
    ],
    redirect: (context, state) {
      return null;
    },
  );
}
