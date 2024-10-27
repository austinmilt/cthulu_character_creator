import 'package:cthulu_character_creator/fields/coc_skillset/skill/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SkillsBuilderWidget extends StatelessWidget {
  const SkillsBuilderWidget({super.key, required this.skills, required this.onUpdate});

  final List<Skill> skills;
  final void Function(List<Skill>) onUpdate;

  void _onUpdate(int index, Skill newValue) {
    onUpdate(List.generate(skills.length, (i) => (i == index) ? newValue : skills[i]));
  }

  void _addSkill() {
    onUpdate(skills + [Skill("NEW", 0)]);
  }

  void _onRemove(int index) {
    final List<Skill> newSkills = [];
    for (int i = 0; i < skills.length; i++) {
      if (i != index) newSkills.add(skills[i]);
    }
    onUpdate(newSkills);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Skill list'),
        const SizedBox(height: 8),
        ListView.builder(
          // update the key to force a re-render when we remove a skill
          key: Key(skills.join()),
          shrinkWrap: true,
          itemCount: skills.length + 1,
          itemBuilder: (context, i) => (i < skills.length)
              ? Card.outlined(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _SkillBuilderWidget(
                          skill: skills[i],
                          onUpdate: (v) => _onUpdate(i, v),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () => _onRemove(i),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: IconButton.outlined(
                      onPressed: _addSkill,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SkillBuilderWidget extends StatelessWidget {
  const _SkillBuilderWidget({required this.skill, required this.onUpdate});

  final Skill skill;
  final void Function(Skill) onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormBuilderTextField(
          name: 'name',
          decoration: const InputDecoration(
            labelText: 'name',
          ),
          initialValue: skill.name,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (v) => onUpdate(Skill(v!, skill.basePercentage)),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.maxLength(40),
          ]),
        ),
        const SizedBox(height: 8),
        FormBuilderTextField(
          name: 'basePercentage',
          decoration: const InputDecoration(
            labelText: 'base percentage',
            helperText: 'Percentage points (0-100) the skill has before any modifications.',
            helperMaxLines: 20,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          initialValue: skill.basePercentage.toString(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (v) => onUpdate(Skill(skill.name, int.parse(v!))),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.max(100),
            FormBuilderValidators.min(0),
          ]),
        ),
      ],
    );
  }
}
