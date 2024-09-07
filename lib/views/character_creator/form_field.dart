import 'package:cthulu_character_creator/model/form.dart' as model;
import 'package:cthulu_character_creator/model/skill.dart';
import 'package:cthulu_character_creator/views/character_creator/skill_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget({super.key, required this.spec});

  final model.FormFieldEntry spec;

  @override
  Widget build(BuildContext context) {
    if (spec.isIntro) {
      return _Intro(spec: spec.introRequired);
    } else if (spec.isEmail) {
      return _Email(spec: spec.emailRequired);
    } else if (spec.isSingleSelect) {
      return _SingleSelect(spec: spec.singleSelectRequired);
    } else if (spec.isText) {
      return _Text(spec: spec.textRequired);
    } else if (spec.isCocSkillset) {
      return _CocSkillSelect(spec: spec.cocSkillsetRequired);
    } else {
      throw UnimplementedError('Cant dispaly this field $spec');
    }
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.spec});

  final model.IntroductionFormField spec;

  @override
  Widget build(BuildContext context) {
    return _mdFromSpec(spec.title, spec.bodyMarkdown);
  }
}

class _Text extends StatelessWidget {
  const _Text({required this.spec});

  final model.TextFormField spec;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _mdFromSpec(spec.title, spec.bodyMarkdown),
        FormBuilderTextField(
          name: spec.key,
          decoration: InputDecoration(labelText: spec.title),
          keyboardType: TextInputType.emailAddress,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.email(),
          ]),
        ),
      ],
    );
  }
}

class _Email extends StatelessWidget {
  const _Email({required this.spec});

  final model.EmailFormField spec;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _mdFromSpec(spec.title, spec.bodyMarkdown),
        const SizedBox(height: 10),
        FormBuilderTextField(
          name: spec.key,
          decoration: InputDecoration(labelText: spec.title),
          keyboardType: TextInputType.emailAddress,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.email(),
          ]),
        ),
      ],
    );
  }
}

class _SingleSelect extends StatelessWidget {
  const _SingleSelect({required this.spec});

  final model.SingleSelectFormField spec;

  List<FormBuilderChipOption<T>> _options<T>(Iterable<T> values) {
    return values.map((e) => FormBuilderChipOption(value: e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _mdFromSpec(spec.title, spec.bodyMarkdown),
        const SizedBox(height: 20),
        FormBuilderChoiceChip(
          name: spec.key,
          spacing: 8,
          runSpacing: 8,
          // disable the bottom border line that's on every input
          decoration: const InputDecoration(border: InputBorder.none),
          options: _options(spec.options),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
          ]),
        ),
      ],
    );
  }
}

class _CocSkillSelect extends StatelessWidget {
  const _CocSkillSelect({required this.spec});

  final model.CoCSkillsetFormField spec;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _mdFromSpec(spec.title, spec.bodyMarkdown),
        const SizedBox(height: 12),
        FormBuilderField(
          name: spec.key,
          validator: ((List<Skill>, bool)? value) =>
              (value?.$2 == true) ? null : "You must select occupational and personal skills",
          builder: (FormFieldState<(List<Skill>, bool)> field) {
            return InputDecorator(
              decoration: InputDecoration(
                border: InputBorder.none,
                errorText: field.errorText,
              ),
              child: SkillSelector(
                onChange: (skills, complete) => field.didChange((skills, complete)),
                options: spec.options,
              ),
            );
          },
        ),
      ],
    );
  }
}

Widget _mdFromSpec(String? title, String? bodyMd) {
  String? mdString;
  if (title != null) {
    if (bodyMd != null) {
      mdString = "# $title\n$bodyMd";
    } else {
      mdString = "# $title";
    }
  } else if (bodyMd != null) {
    mdString = bodyMd;
  }
  if (mdString != null) {
    return _md(mdString);
  } else {
    return const SizedBox();
  }
}

Widget _md(String src) {
  return MarkdownBody(
    data: src,
    styleSheet: mdStyle,
  );
}

MarkdownStyleSheet mdStyle = MarkdownStyleSheet(
  h1: const TextStyle(fontSize: 32),
  p: const TextStyle(fontSize: 16),
  blockSpacing: 20,
);
