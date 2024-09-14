import 'package:cthulu_character_creator/fields/coc_skillset/field.dart';
import 'package:cthulu_character_creator/fields/email/field.dart';
import 'package:cthulu_character_creator/fields/info/field.dart';
import 'package:cthulu_character_creator/fields/single_select/field.dart';
import 'package:cthulu_character_creator/fields/text/field.dart';
import 'package:cthulu_character_creator/fields/text_area/field.dart';

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

  /// Returns the key of the field if it has one, null otherwise.
  String? key() {
    if (isCocSkillset) return cocSkillset?.key;
    if (isEmail) return email?.key;
    if (isInfo) return null;
    if (isSingleSelect) return singleSelect?.key;
    if (isText) return text?.key;
    if (isTextArea) return textArea?.key;
    throw UnimplementedError("Unhandled field");
  }

  @override
  String toString() {
    if (isCocSkillset) return _strWrap(cocSkillset.toString());
    if (isEmail) return _strWrap(email.toString());
    if (isInfo) return _strWrap(info.toString());
    if (isSingleSelect) return _strWrap(singleSelect.toString());
    if (isText) return _strWrap(text.toString());
    if (isTextArea) return _strWrap(textArea.toString());
    return _strWrap('?');
  }

  String _strWrap(String str) {
    return 'FormField[group=$group, $str]';
  }
}
