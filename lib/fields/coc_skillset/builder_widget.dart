import 'package:cthulu_character_creator/fields/coc_skillset/field.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/skill/builder_widget.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/skill/skill.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/slot/builder_widget.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/slot/slot.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/widget.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/form_response.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CocSkillsetBuilder extends StatelessWidget {
  const CocSkillsetBuilder({super.key, required this.controller});

  final FieldBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final C4FormField spec = controller.spec;
    return controller.editing
        ? _Editor(
            spec: spec,
            onUpdate: (p0) => controller.spec = p0,
          )
        : CocSkillsetWidget(
            controller: FieldResponseController(
              spec,
              true,
              FormFieldResponse.cocSkillset(spec.cocSkillsetRequired.skills),
            ),
          );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.spec, required this.onUpdate});

  final C4FormField spec;
  final void Function(C4FormField) onUpdate;

  void _onUpdate({
    String? key,
    String? title,
    String? bodyMarkdown,
    bool? required,
    List<Skill>? skills,
    List<SkillSlot>? slots,
  }) {
    final CoCSkillsetFormField subspec = spec.cocSkillsetRequired;
    onUpdate(C4FormField.cocSkillset(CoCSkillsetFormField(
      key: key ?? subspec.key,
      title: title ?? subspec.title,
      bodyMarkdown: bodyMarkdown ?? subspec.bodyMarkdown,
      required: required ?? subspec.required,
      skills: skills ?? subspec.skills,
      slots: slots ?? subspec.slots,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final CoCSkillsetFormField subspec = spec.cocSkillsetRequired;
    return Column(children: [
      FormBuilderTextField(
        name: 'key',
        decoration: const InputDecoration(
          labelText: 'key',
          helperText: "The unique identifying key of this field in your form used to label responses.",
          helperMaxLines: 20,
        ),
        initialValue: subspec.key,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (v) => _onUpdate(key: v),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.maxLength(20),
        ]),
      ),
      FormBuilderTextField(
        name: 'title',
        decoration: const InputDecoration(labelText: 'title'),
        initialValue: subspec.title,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (v) => _onUpdate(title: v),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.maxLength(40),
        ]),
      ),
      FormBuilderCheckbox(
        name: 'required',
        title: const Text("required"),
        initialValue: subspec.required,
        onChanged: (v) => _onUpdate(required: v),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
      ),
      FormBuilderTextField(
        name: 'bodyMarkdown',
        initialValue: subspec.bodyMarkdown,
        decoration: const InputDecoration(labelText: 'description'),
        onChanged: (v) => _onUpdate(bodyMarkdown: v),
        minLines: 1,
        maxLines: 100,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.maxLength(10000),
        ]),
      ),
      const SizedBox(height: 24),
      SkillsBuilderWidget(
        skills: subspec.skills,
        onUpdate: (v) => _onUpdate(skills: v),
      ),
      const SizedBox(height: 24),
      SkillSlotsBuilderWidget(
        slots: subspec.slots,
        onUpdate: (v) => _onUpdate(slots: v),
      ),
    ]);
  }
}
