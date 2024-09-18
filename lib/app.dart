import 'package:cthulu_character_creator/views/builder/form_builder_view.dart';
import 'package:cthulu_character_creator/views/response/response_view.dart';
import 'package:cthulu_character_creator/views/responses/responses_view.dart';
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
    initialLocation: FormBuilderView.route.path,
    routes: <RouteBase>[
      FormBuilderView.route,
      ResponseView.newRoute,
      ResponseView.existingRoute,
      ResponsesView.route,
    ],
    redirect: (context, state) {
      return null;
    },
  );
}
