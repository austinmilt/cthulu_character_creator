import 'package:cthulu_character_creator/form_data.dart';

abstract interface class Api {
  Future<void> submitForm(FormData submission);
}
