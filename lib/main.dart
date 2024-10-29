import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/app.dart';
import 'package:cthulu_character_creator/configure_services.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:cthulu_character_creator/views/home/home_controller.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:cthulu_character_creator/views/responses/responses_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (
    :api,
    :loggerFactory,
  ) = await configureServices();

  final ResponseController responseController = MainResponseController(api);
  final ResponsesController responsesController = ResponsesController(api);
  final FormBuilderController formBuilderController = FormBuilderController(api);
  final HomeController homeController = HomeController(api);

  runApp(MultiProvider(
    providers: [
      Provider<Api>(create: (_) => api),
      Provider<LoggerFactory>(create: (_) => loggerFactory),
      ChangeNotifierProvider<ResponseController>(create: (_) => responseController),
      ChangeNotifierProvider<ResponsesController>(create: (_) => responsesController),
      ChangeNotifierProvider<FormBuilderController>(create: (_) => formBuilderController),
      ChangeNotifierProvider<HomeController>(create: (_) => homeController),
    ],
    child: const MyApp(),
  ));
}
