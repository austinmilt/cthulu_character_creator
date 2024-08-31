import 'package:cthulu_character_creator/character_form.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const path = '/';

  static GoRoute route() {
    return GoRoute(
      path: path,
      builder: (context, state) {
        return const HomePage();
      },
    );
  }

  static void navigate(BuildContext context) {
    context.push(path);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MainForm(),
    );
  }
}
