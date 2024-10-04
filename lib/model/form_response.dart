import 'package:cthulu_character_creator/fields/coc_skillset/response.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/skill/skill.dart';
import 'package:cthulu_character_creator/fields/email/response.dart';
import 'package:cthulu_character_creator/fields/single_select/response.dart';
import 'package:cthulu_character_creator/fields/text/response.dart';
import 'package:cthulu_character_creator/fields/text_area/response.dart';

class FormResponse {
  FormResponse({required this.id, required this.editAuthSecret, required this.fields});

  String? id;
  String? editAuthSecret;
  final Map<String, FormFieldResponse> fields;
}

class FormFieldResponse {
  FormFieldResponse._({
    this.email,
    this.singleSelect,
    this.cocSkillset,
    this.text,
    this.textArea,
  });

  final EmailResponse? email;
  final SingleSelectResponse? singleSelect;
  final CocSkillsetResponse? cocSkillset;
  final TextResponse? text;
  final TextAreaResponse? textArea;

  factory FormFieldResponse.email(EmailResponse response) {
    return FormFieldResponse._(email: response);
  }

  bool get isEmail => email != null;
  String get emailRequired => email!;

  factory FormFieldResponse.singleSelect(SingleSelectResponse response) {
    return FormFieldResponse._(singleSelect: response);
  }

  bool get isSingleSelect => singleSelect != null;
  String get singleSelectRequired => singleSelect!;

  factory FormFieldResponse.cocSkillset(CocSkillsetResponse response) {
    return FormFieldResponse._(cocSkillset: response);
  }

  bool get isCocSkillset => cocSkillset != null;
  List<Skill> get cocSkillSetRequired => cocSkillset!;

  factory FormFieldResponse.text(TextResponse response) {
    return FormFieldResponse._(text: response);
  }

  bool get isText => text != null;
  String get textRequired => text!;

  factory FormFieldResponse.textArea(TextAreaResponse response) {
    return FormFieldResponse._(textArea: response);
  }

  bool get isTextArea => textArea != null;
  String get textAreaRequired => textArea!;
}

class FormResponseSummary {
  FormResponseSummary({required this.id});

  final String id;

  @override
  String toString() {
    return "FormResponseSummary[id=$id]";
  }
}
