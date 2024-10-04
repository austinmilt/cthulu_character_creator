import 'package:cthulu_character_creator/fields/coc_skillset/field.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/slot/slot.dart';
import 'package:cthulu_character_creator/fields/email/field.dart';
import 'package:cthulu_character_creator/fields/info/field.dart';
import 'package:cthulu_character_creator/fields/single_select/field.dart';
import 'package:cthulu_character_creator/fields/text/field.dart';
import 'package:cthulu_character_creator/fields/text_area/field.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/skill/skill.dart';
import 'package:cthulu_character_creator/model/form_response.dart';

const serdes = (
  form: (
    toJson: _formToJson,
    fromJson: _formFromJson,
  ),
  formResponse: (
    toJson: _formResponseToJson,
    fromJson: _formResponseFromJson,
  ),
);

List<dynamic> _formToJson(C4Form form) {
  return form.map(_formFieldEntryToJson).toList();
}

C4Form _formFromJson(List<Map<String, dynamic>> json) {
  return json.map(_formFieldEntryFromJson).toList();
}

Map<String, dynamic> _formFieldEntryToJson(C4FormField entry) {
  final Map<String, dynamic> result;
  if (entry.isInfo) {
    result = _infoToJson(entry.infoRequired);
  } else if (entry.isEmail) {
    result = _emailToJson(entry.emailRequired);
  } else if (entry.isSingleSelect) {
    result = _singleSelectToJson(entry.singleSelectRequired);
  } else if (entry.isText) {
    result = _textToJson(entry.textRequired);
  } else if (entry.isTextArea) {
    result = _textAreaToJson(entry.textAreaRequired);
  } else if (entry.isCocSkillset) {
    result = _cocSkillsetToJson(entry.cocSkillsetRequired);
  } else {
    throw UnimplementedError("Dont know how to serialize $entry to JSON");
  }
  _putFieldIfPresent('group', entry.group, result);
  return result;
}

C4FormField _formFieldEntryFromJson(Map<String, dynamic> json) {
  final String? group = json['group'];
  if (json.containsKey("info")) return C4FormField.info(_infoFromJson(json["info"]), group);
  if (json.containsKey("email")) return C4FormField.email(_emailFromJson(json["email"]), group);
  if (json.containsKey("singleSelect")) {
    return C4FormField.singleSelect(_singleSelectFromJson(json["singleSelect"]), group);
  }
  if (json.containsKey("cocSkillset")) {
    return C4FormField.cocSkillset(_cocSkillsetSelectFromJson(json["cocSkillset"]), group);
  }
  if (json.containsKey("text")) return C4FormField.text(_textFromJson(json["text"]), group);
  if (json.containsKey("textArea")) return C4FormField.textArea(_textAreaFromJson(json["textArea"]), group);
  throw UnimplementedError("Dont know how to deserialize $json to FormFieldEntry");
}

Map<String, dynamic> _infoToJson(InformationFormField field) {
  return {
    "title": field.title,
    "bodyMarkdown": field.bodyMarkdown,
  };
}

InformationFormField _infoFromJson(Map<String, dynamic> json) {
  return InformationFormField(
    title: json["title"],
    bodyMarkdown: _decodeMarkdown(json["bodyMarkdown"]),
  );
}

Map<String, dynamic> _emailToJson(EmailFormField field) {
  final Map<String, dynamic> result = {
    "key": field.key,
    "required": field.required,
  };
  _putFieldIfPresent('title', field.title, result);
  _putFieldIfPresent('bodyMarkdown', field.bodyMarkdown, result);
  _putFieldIfPresent('slots', field.slots, result);
  return result;
}

EmailFormField _emailFromJson(Map<String, dynamic> json) {
  return EmailFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: _decodeMarkdown(json["bodyMarkdown"]),
    required: json["required"],
    slots: json["slots"],
  );
}

Map<String, dynamic> _singleSelectToJson(SingleSelectFormField field) {
  final Map<String, dynamic> result = {
    "key": field.key,
    "required": field.required,
    "options": field.options,
  };
  _putFieldIfPresent('title', field.title, result);
  _putFieldIfPresent('bodyMarkdown', field.bodyMarkdown, result);
  _putFieldIfPresent('slots', field.slots, result);
  return result;
}

SingleSelectFormField _singleSelectFromJson(Map<String, dynamic> json) {
  return SingleSelectFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: _decodeMarkdown(json["bodyMarkdown"]),
    required: json["required"],
    slots: json["slots"],
    options: (json["options"] as List).map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _cocSkillsetToJson(CoCSkillsetFormField field) {
  final Map<String, dynamic> result = {
    "key": field.key,
    "required": field.required,
    "skills": field.skills.map((s) => _skillToJson(s)).toList(),
    "slots": field.slots.map((s) => _slotToJson(s)).toList(),
  };
  _putFieldIfPresent('title', field.title, result);
  _putFieldIfPresent('bodyMarkdown', field.bodyMarkdown, result);
  return result;
}

CoCSkillsetFormField _cocSkillsetSelectFromJson(Map<String, dynamic> json) {
  return CoCSkillsetFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: _decodeMarkdown(json["bodyMarkdown"]),
    required: json["required"],
    // TODO remove the "options" version
    skills: ((json["skills"] ?? json["options"]) as List).map((e) => _skillFromJson(e)).toList(),
    slots: (json["slots"] as List).map((e) => _slotFromJson(e)).toList(),
  );
}

List<dynamic> _skillsToJson(List<Skill> skills) {
  return skills.map(_skillToJson).toList();
}

Map<String, dynamic> _skillToJson(Skill skill) {
  final Map<String, dynamic> result = {
    "name": skill.name,
    "basePercentage": skill.basePercentage,
  };
  if (skill.percentageModifier != 0) result["percentageModifier"] = skill.percentageModifier;
  return result;
}

List<Skill> _skillsFromJson(List<dynamic> json) {
  return List.from(json.map(_skillFromJson));
}

Skill _skillFromJson(dynamic json) {
  return Skill(
    json["name"],
    json["basePercentage"],
    json["percentageModifier"] ?? 0,
  );
}

Map<String, dynamic> _slotToJson(SkillSlot slot) {
  return {
    "type": slot.type.name,
    "points": slot.points,
  };
}

SkillSlot _slotFromJson(dynamic json) {
  final SkillSlotType type = SkillSlotType.fromName(json["type"]);
  switch (type) {
    case SkillSlotType.override:
      return SkillSlot.override(json["points"]);

    case SkillSlotType.modify:
      return SkillSlot.modify(json["points"]);

    default:
      throw UnimplementedError("Unknown how to handle slot type $type");
  }
}

Map<String, dynamic> _textToJson(C4TextFormField field) {
  final Map<String, dynamic> result = {
    "key": field.key,
    "required": field.required,
  };
  _putFieldIfPresent('title', field.title, result);
  _putFieldIfPresent('bodyMarkdown', field.bodyMarkdown, result);
  _putFieldIfPresent('label', field.label, result);
  _putFieldIfPresent('help', field.help, result);
  return result;
}

C4TextFormField _textFromJson(Map<String, dynamic> json) {
  return C4TextFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: _decodeMarkdown(json["bodyMarkdown"]),
    required: json["required"],
    slots: json["slots"],
    label: json["label"],
    help: json["help"],
  );
}

Map<String, dynamic> _textAreaToJson(TextAreaFormField field) {
  final Map<String, dynamic> result = {
    "key": field.key,
    "required": field.required,
  };
  _putFieldIfPresent('title', field.title, result);
  _putFieldIfPresent('bodyMarkdown', field.bodyMarkdown, result);
  _putFieldIfPresent('label', field.label, result);
  _putFieldIfPresent('help', field.help, result);
  return result;
}

TextAreaFormField _textAreaFromJson(Map<String, dynamic> json) {
  return TextAreaFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: _decodeMarkdown(json["bodyMarkdown"]),
    required: json["required"],
    slots: json["slots"],
    label: json["label"],
    help: json["help"],
  );
}

String? _decodeMarkdown(String? source) {
  return source?.replaceAll(RegExp(r'\\n'), '\n');
}

Map<String, dynamic> _formResponseToJson(FormResponse submission) {
  return {
    'id': submission.id,
    'editAuthSecret': submission.editAuthSecret,
    'fields': submission.fields.map((key, response) => MapEntry(key, _formFieldResponseToJson(response))),
  };
}

Map<String, dynamic> _formFieldResponseToJson(FormFieldResponse submission) {
  final Map<String, dynamic> result = {};
  _putFieldIfPresent('email', submission.email, result);
  _putFieldIfPresent('singleSelect', submission.singleSelect, result);
  _putFieldIfPresent('cocSkillset', submission.cocSkillset, result);
  if (submission.isCocSkillset) {
    result['cocSkillset'] = _skillsToJson(submission.cocSkillSetRequired);
  }
  _putFieldIfPresent('text', submission.text, result);
  _putFieldIfPresent('textArea', submission.textArea, result);
  return result;
}

void _putFieldIfPresent<T>(String key, T? field, Map<String, dynamic> json, [dynamic Function(T)? toJson]) {
  toJson ??= (s) => s;
  if (field != null) json[key] = toJson(field);
}

FormResponse _formResponseFromJson(Map<String, dynamic> json) {
  return FormResponse(
    id: json['id'],
    // the secret is only used on upload and edit, never download/view
    editAuthSecret: null,
    fields: (json['fields'] as Map<String, dynamic>).map((k, v) => MapEntry(k, _formFieldResponseFromJson(v))),
  );
}

FormFieldResponse _formFieldResponseFromJson(Map<String, dynamic> json) {
  if (json.containsKey('email')) {
    return FormFieldResponse.email(json['email']);
  } else if (json.containsKey('singleSelect')) {
    return FormFieldResponse.singleSelect(json['singleSelect']);
  } else if (json.containsKey('cocSkillset')) {
    return FormFieldResponse.cocSkillset(_skillsFromJson(json['cocSkillset']));
  } else if (json.containsKey('text')) {
    return FormFieldResponse.text(json['text']);
  } else if (json.containsKey('textArea')) {
    return FormFieldResponse.textArea(json['textArea']);
  } else {
    throw UnimplementedError('Dont know how to deserialize $json');
  }
}
