import 'package:cthulu_character_creator/fields/coc_skillset/skill.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/slot.dart';

class CoCSkillsetFormField {
  CoCSkillsetFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.skills,
    required this.slots,
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final List<Skill> skills;
  final List<SkillSlot> slots;

  @override
  String toString() {
    return 'CocSkillsetFormField[key=$key, title=$title, '
        'bodyMarkdown=$bodyMarkdown, required=$required, skills=$skills, '
        'slots=$slots]';
  }
}
