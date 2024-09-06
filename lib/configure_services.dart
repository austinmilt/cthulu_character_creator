import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/dev/dev_logging.dart';
import 'package:cthulu_character_creator/env.dart';
import 'package:cthulu_character_creator/firebase/firestore_form_api.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

typedef Services = ({
  Api api,
  LoggerFactory loggerFactory,
});

/// Configures app services, focused primarily on choosing which implementation
/// of a service to use, such as dev, main, or third-party-specific, as well
/// as loading environment/implementation-specific configurations for services.
///
/// This function uses a fail-fast approach for interdependent services.
/// It does this by using [late] where they are a dependency to throw an
/// exception if they have not actually been built.
Future<Services> configureServices() async {
  late final LogOutput logOutput;
  late final DebugLogOutput debugLogOutput;
  if (Env.loggingImplementation == 'firebase') {
  } else if (Env.loggingImplementation == 'debug') {
    debugLogOutput = DebugLogOutput();
    logOutput = debugLogOutput;
  }
  final LoggerFactory loggerFactory = LoggerFactory(logOutput);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  late final Api api;
  late final FirestoreFormApi firestoreFormApi;
  {
    firestoreFormApi = FirestoreFormApi(FirebaseFirestore.instance);
    api = firestoreFormApi;
  }

  return (
    api: api,
    loggerFactory: loggerFactory,
  );
}
