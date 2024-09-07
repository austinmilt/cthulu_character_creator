import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/skill.dart';
import 'package:cthulu_character_creator/model/form_data.dart';

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

List<dynamic> _formToJson(Form form) {
  return form.map(_formFieldEntryToJson).toList();
}

Form _formFromJson(List<Map<String, dynamic>> json) {
  return json.map(_formFieldEntryFromJson).toList();
}

Map<String, dynamic> _formFieldEntryToJson(FormFieldEntry entry) {
  if (entry.isIntro) return _introToJson(entry.introRequired);
  if (entry.isEmail) return _emailToJson(entry.emailRequired);
  if (entry.isSingleSelect) return _singleSelectToJson(entry.singleSelectRequired);
  if (entry.isText) return _textToJson(entry.textRequired);
  if (entry.isCocSkillset) return _cocSkillsetToJson(entry.cocSkillsetRequired);
  throw UnimplementedError("Dont know how to serialize $entry to JSON");
}

FormFieldEntry _formFieldEntryFromJson(Map<String, dynamic> json) {
  if (json.containsKey("intro")) return FormFieldEntry.intro(_introFromJson(json["intro"]));
  if (json.containsKey("email")) return FormFieldEntry.email(_emailFromJson(json["email"]));
  if (json.containsKey("singleSelect")) return FormFieldEntry.singleSelect(_singleSelectFromJson(json["singleSelect"]));
  if (json.containsKey("cocSkillset")) {
    return FormFieldEntry.cocSkillset(_cocSkillsetSelectFromJson(json["cocSkillset"]));
  }
  if (json.containsKey("text")) return FormFieldEntry.text(_textFromJson(json["text"]));
  throw UnimplementedError("Dont know how to deserialize $json to FormFieldEntry");
}

Map<String, dynamic> _introToJson(IntroductionFormField field) {
  return {
    "title": field.title,
    "bodyMarkdown": field.bodyMarkdown,
  };
}

IntroductionFormField _introFromJson(Map<String, dynamic> json) {
  return IntroductionFormField(
    title: json["title"],
    bodyMarkdown: json["bodyMarkdown"],
  );
}

Map<String, dynamic> _emailToJson(EmailFormField field) {
  return {
    "key": field.key,
    "title": field.title,
    "bodyMarkdown": field.bodyMarkdown,
    "required": field.required,
    "slots": field.slots,
  };
}

EmailFormField _emailFromJson(Map<String, dynamic> json) {
  return EmailFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: json["bodyMarkdown"],
    required: json["required"],
    slots: json["slots"],
  );
}

Map<String, dynamic> _singleSelectToJson(SingleSelectFormField field) {
  return {
    "key": field.key,
    "title": field.title,
    "bodyMarkdown": field.bodyMarkdown,
    "required": field.required,
    "slots": field.slots,
    "options": field.options,
  };
}

SingleSelectFormField _singleSelectFromJson(Map<String, dynamic> json) {
  return SingleSelectFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: json["bodyMarkdown"],
    required: json["required"],
    slots: json["slots"],
    options: json["options"],
  );
}

Map<String, dynamic> _cocSkillsetToJson(CoCSkillsetFormField field) {
  return {
    "key": field.key,
    "title": field.title,
    "bodyMarkdown": field.bodyMarkdown,
    "required": field.required,
    "options": field.options.map((s) => _skillToJson(s)).toList(),
  };
}

CoCSkillsetFormField _cocSkillsetSelectFromJson(Map<String, dynamic> json) {
  return CoCSkillsetFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: json["bodyMarkdown"],
    required: json["required"],
    options: (json["options"] as List).map((e) => _skillFromJson(e)).toList(),
  );
}

List<dynamic> _skillsToJson(List<Skill> skills) {
  return skills.map(_skillToJson).toList();
}

Map<String, dynamic> _skillToJson(Skill skill) {
  return {
    "name": skill.name,
    "basePercentage": skill.basePercentage,
    "percentageModifier": skill.percentageModifier,
  };
}

List<Skill> _skillsFromJson(List<Map<String, dynamic>> json) {
  return json.map(_skillFromJson).toList();
}

Skill _skillFromJson(Map<String, dynamic> json) {
  return Skill(
    json["name"],
    json["basePercentage"],
    json["percentageModifier"],
  );
}

Map<String, dynamic> _textToJson(TextFormField field) {
  return {
    "key": field.key,
    "title": field.title,
    "bodyMarkdown": field.bodyMarkdown,
    "required": field.required,
  };
}

TextFormField _textFromJson(Map<String, dynamic> json) {
  return TextFormField(
    key: json["key"],
    title: json["title"],
    bodyMarkdown: json["bodyMarkdown"],
    required: json["required"],
  );
}

Map<String, dynamic> _formResponseToJson(FormResponseData submission) {
  final Map<String, dynamic> result = {
    'gameId': submission.gameId,
    'email': submission.email,
    'occupation': submission.occupation,
    'skills': _skillsToJson(submission.skills),
    'name': submission.name,
    'appearance': submission.appearance,
  };
  _putFieldIfPresent('traits', submission.traits, result);
  _putFieldIfPresent('ideology', submission.ideology, result);
  _putFieldIfPresent('injuries', submission.injuries, result);
  _putFieldIfPresent('relationships', submission.relationships, result);
  _putFieldIfPresent('phobias', submission.phobias, result);
  _putFieldIfPresent('treasures', submission.treasures, result);
  _putFieldIfPresent('details', submission.details, result);
  _putFieldIfPresent('items', submission.items, result);
  return result;
}

void _putFieldIfPresent<T>(String key, T? field, Map<String, dynamic> json, [dynamic Function(T)? toJson]) {
  toJson ??= (s) => s;
  if (field != null) json[key] = toJson(field);
}

FormResponseData _formResponseFromJson(Map<String, dynamic> json) {
  return FormResponseData(
    gameId: json['gameId'],
    email: json['email'],
    occupation: json['occupation'],
    skills: _skillsFromJson(json['skills']),
    name: json['name'],
    appearance: json['appearance'],
    traits: json['traits'],
    ideology: json['ideology'],
    injuries: json['injuries'],
    relationships: json['relationships'],
    phobias: json['phobias'],
    treasures: json['treasures'],
    details: json['details'],
    items: json['items'],
  );
}
