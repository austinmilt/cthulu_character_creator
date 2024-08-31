import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/app.dart';
import 'package:cthulu_character_creator/configure_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (
    :api,
    :loggerFactory,
  ) = await configureServices();

  runApp(MultiProvider(
    providers: [
      Provider<Api>(create: (_) => api),
    ],
    child: const MyApp(),
  ));
}
