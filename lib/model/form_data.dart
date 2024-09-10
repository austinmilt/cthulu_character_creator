import 'package:cthulu_character_creator/model/skill.dart';

class FormResponse {
  FormResponse({required this.id, required this.fields});

  String? id;
  final List<FormFieldResponse> fields;
}

class FormFieldResponse {
  FormFieldResponse._({
    required this.fieldKey,
    this.email,
    this.singleSelect,
    this.cocSkillset,
    this.text,
    this.textArea,
  });

  // fields in the response should stay sync'd with FormFieldEntry
  final String fieldKey;
  final String? email;
  final String? singleSelect;
  final List<Skill>? cocSkillset;
  final String? text;
  final String? textArea;

  factory FormFieldResponse.email(String fieldKey, String response) {
    return FormFieldResponse._(fieldKey: fieldKey, email: response);
  }

  bool get isEmail => email != null;
  String get emailRequired => email!;

  factory FormFieldResponse.singleSelect(String fieldKey, String response) {
    return FormFieldResponse._(fieldKey: fieldKey, singleSelect: response);
  }

  bool get isSingleSelect => singleSelect != null;
  String get singleSelectRequired => singleSelect!;

  factory FormFieldResponse.cocSkillset(String fieldKey, List<Skill> response) {
    return FormFieldResponse._(fieldKey: fieldKey, cocSkillset: response);
  }

  bool get isCocSkillset => cocSkillset != null;
  List<Skill> get cocSkillSetRequired => cocSkillset!;

  factory FormFieldResponse.text(String fieldKey, String response) {
    return FormFieldResponse._(fieldKey: fieldKey, text: response);
  }

  bool get isText => text != null;
  String get textRequired => text!;

  factory FormFieldResponse.textArea(String fieldKey, String response) {
    return FormFieldResponse._(fieldKey: fieldKey, textArea: response);
  }

  bool get isTextArea => textArea != null;
  String get textAreaRequired => textArea!;
}
