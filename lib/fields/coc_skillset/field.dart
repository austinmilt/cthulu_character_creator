import 'package:cthulu_character_creator/fields/coc_skillset/skill.dart';

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

  @override
  String toString() {
    return 'CocSkillsetFormField[key=$key, title=$title, '
        'bodyMarkdown=$bodyMarkdown, required=$required, options=$options]';
  }
}
