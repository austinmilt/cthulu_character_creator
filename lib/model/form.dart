import 'package:cthulu_character_creator/model/skill.dart';

typedef Form = List<FormField>;

class FormField {
  FormField._({
    this.group,
    this.info,
    this.email,
    this.singleSelect,
    this.cocSkillset,
    this.text,
    this.textArea,
  });

  final String? group;
  final InformationFormField? info;
  final EmailFormField? email;
  final SingleSelectFormField? singleSelect;
  final CoCSkillsetFormField? cocSkillset;
  final TextFormField? text;
  final TextAreaFormField? textArea;

  factory FormField.info(InformationFormField field, [String? group]) {
    return FormField._(info: field, group: group);
  }

  bool get isInfo => info != null;
  InformationFormField get infoRequired => info!;

  factory FormField.email(EmailFormField field, [String? group]) {
    return FormField._(email: field, group: group);
  }

  bool get isEmail => email != null;
  EmailFormField get emailRequired => email!;

  factory FormField.singleSelect(SingleSelectFormField field, [String? group]) {
    return FormField._(singleSelect: field, group: group);
  }

  bool get isSingleSelect => singleSelect != null;
  SingleSelectFormField get singleSelectRequired => singleSelect!;

  factory FormField.cocSkillset(CoCSkillsetFormField field, [String? group]) {
    return FormField._(cocSkillset: field, group: group);
  }

  bool get isCocSkillset => cocSkillset != null;
  CoCSkillsetFormField get cocSkillsetRequired => cocSkillset!;

  factory FormField.text(TextFormField field, [String? group]) {
    return FormField._(text: field, group: group);
  }

  bool get isText => text != null;
  TextFormField get textRequired => text!;

  factory FormField.textArea(TextAreaFormField field, [String? group]) {
    return FormField._(textArea: field, group: group);
  }

  bool get isTextArea => textArea != null;
  TextAreaFormField get textAreaRequired => textArea!;
}

class InformationFormField {
  InformationFormField({required this.title, required this.bodyMarkdown});

  final String? title;
  final String? bodyMarkdown;
}

class EmailFormField {
  EmailFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.slots,
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final int? slots;
}

class SingleSelectFormField {
  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final int? slots;
  final List<String> options;

  SingleSelectFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.slots,
    required this.options,
  });
}

class CoCSkillsetFormField {
  CoCSkillsetFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.options,
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final List<Skill> options;
}

class TextFormField {
  TextFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.slots,
    required this.label,
    required this.help,
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final String? label;
  final String? help;
  final bool required;
  final int? slots;
}

class TextAreaFormField {
  TextAreaFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.slots,
    required this.label,
    required this.help,
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final String? label;
  final String? help;
  final bool required;
  final int? slots;
}
