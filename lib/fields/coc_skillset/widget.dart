import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/field.dart' as model;
import 'package:cthulu_character_creator/fields/coc_skillset/selector.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/skill/skill.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class CocSkillsetWidget extends StatefulWidget {
  const CocSkillsetWidget({super.key, required this.controller});

  final FieldResponseController controller;

  @override
  State<CocSkillsetWidget> createState() => _CocSkillsetWidgetState();
}

class _CocSkillsetWidgetState extends State<CocSkillsetWidget> {
  bool _complete = false;

  @override
  Widget build(BuildContext context) {
    final model.CoCSkillsetFormField spec = widget.controller.spec.cocSkillsetRequired;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FieldMarkdown(
          title: spec.title,
          bodyMd: spec.bodyMarkdown,
        ),
        const SizedBox(height: 12),
        FormBuilderField(
          name: spec.key,
          initialValue: widget.controller.response?.cocSkillset,
          enabled: context.watch<ResponseController>().canEditResponse,
          validator: (List<Skill>? value) => _complete ? null : "You must fill all skill slots",
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
                spec: spec,
                initialValue: widget.controller.response?.cocSkillset,
              ),
            );
          },
        ),
      ],
    );
  }
}
