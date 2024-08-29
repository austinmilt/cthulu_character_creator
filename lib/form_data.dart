import 'package:cthulu_character_creator/skill.dart';

class FormData {
  FormData({
    required this.email,
    required this.occupation,
    required this.skills,
    required this.name,
    required this.appearance,
    required this.traits,
    required this.ideology,
    required this.injuries,
    required this.relationships,
    required this.phobias,
    required this.treasures,
    required this.details,
    required this.items,
  });

  final String email;
  final String occupation;
  final List<Skill> skills;
  final String name;
  final String appearance;
  final String? traits;
  final String? ideology;
  final String? injuries;
  final String? relationships;
  final String? phobias;
  final String? treasures;
  final String? details;
  final String? items;
}
