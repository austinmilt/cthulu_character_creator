import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/field.dart' as model;
import 'package:cthulu_character_creator/fields/coc_skillset/selector.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/skill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CocSkillsetWidget extends StatefulWidget {
  const CocSkillsetWidget({super.key, required this.spec});

  final model.CoCSkillsetFormField spec;

  @override
  State<CocSkillsetWidget> createState() => _CocSkillsetWidgetState();
}

class _CocSkillsetWidgetState extends State<CocSkillsetWidget> {
  bool _complete = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FieldMarkdown(
          title: widget.spec.title,
          bodyMd: widget.spec.bodyMarkdown,
        ),
        const SizedBox(height: 12),
        FormBuilderField(
          name: widget.spec.key,
          validator: (List<Skill>? value) => _complete ? null : "You must select occupational and personal skills",
          builder: (FormFieldState<List<Skill>> field) {
            return InputDecorator(
              decoration: InputDecoration(
                border: InputBorder.none,
                errorText: field.errorText,
              ),
              child: SkillSelector(
                onChange: (skills, complete) {
                  _complete = complete;
                  field.didChange(skills);
                },
                options: widget.spec.options,
              ),
            );
          },
        ),
      ],
    );
  }
}
