import 'package:cthulu_character_creator/home_page.dart';
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
    initialLocation: HomePage.path,
    routes: <RouteBase>[
      HomePage.route(),
    ],
    redirect: (context, state) {
      if (state.path == '/') {
        return HomePage.path;
      }
      return null;
    },
  );
}
