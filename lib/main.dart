import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/app.dart';
import 'package:cthulu_character_creator/configure_services.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/views/character_creator/form_controller.dart';
import 'package:cthulu_character_creator/views/submissions/submissions_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (
    :api,
    :loggerFactory,
  ) = await configureServices();

  final FormController formController = FormController(api);
  final SubmissionsController submissionsController = SubmissionsController(api);

  runApp(MultiProvider(
    providers: [
      Provider<Api>(create: (_) => api),
      Provider<LoggerFactory>(create: (_) => loggerFactory),
      ChangeNotifierProvider<FormController>(create: (_) => formController),
      ChangeNotifierProvider<SubmissionsController>(create: (_) => submissionsController),
    ],
    child: const MyApp(),
  ));
}
