import 'package:cthulu_character_creator/model/skill.dart';

typedef Form = List<FormFieldEntry>;

class FormFieldEntry {
  FormFieldEntry._({
    this.group,
    this.info,
    this.email,
    this.singleSelect,
    this.cocSkillset,
    this.text,
  });

  final String? group;
  final InformationFormField? info;
  final EmailFormField? email;
  final SingleSelectFormField? singleSelect;
  final CoCSkillsetFormField? cocSkillset;
  final TextFormField? text;

  factory FormFieldEntry.info(InformationFormField field, [String? group]) {
    return FormFieldEntry._(info: field, group: group);
  }

  bool get isInfo => info != null;
  InformationFormField get infoRequired => info!;

  factory FormFieldEntry.email(EmailFormField field, [String? group]) {
    return FormFieldEntry._(email: field, group: group);
  }

  bool get isEmail => email != null;
  EmailFormField get emailRequired => email!;

  factory FormFieldEntry.singleSelect(SingleSelectFormField field, [String? group]) {
    return FormFieldEntry._(singleSelect: field, group: group);
  }

  bool get isSingleSelect => singleSelect != null;
  SingleSelectFormField get singleSelectRequired => singleSelect!;

  factory FormFieldEntry.cocSkillset(CoCSkillsetFormField field, [String? group]) {
    return FormFieldEntry._(cocSkillset: field, group: group);
  }

  bool get isCocSkillset => cocSkillset != null;
  CoCSkillsetFormField get cocSkillsetRequired => cocSkillset!;

  factory FormFieldEntry.text(TextFormField field, [String? group]) {
    return FormFieldEntry._(text: field, group: group);
  }

  bool get isText => text != null;
  TextFormField get textRequired => text!;
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

// TODO have to ensure that <T> is JSON compatible
class SingleSelectFormField<T> {
  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final int? slots;
  final List<T> options;

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
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final int? slots;
}
