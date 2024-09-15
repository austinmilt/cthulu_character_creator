import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/text_area/field.dart' as model;
import 'package:cthulu_character_creator/fields/text_area/response.dart';
import 'package:cthulu_character_creator/views/character_creator/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class TextAreaWidget extends StatelessWidget {
  const TextAreaWidget({super.key, required this.spec, this.initialValue});

  final model.TextAreaFormField spec;
  final TextAreaResponse? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldMarkdown(
          title: spec.title,
          bodyMd: spec.bodyMarkdown,
        ),
        FormBuilderTextField(
          name: spec.key,
          initialValue: initialValue,
          enabled: context.watch<FormController>().canEditResponse,
          decoration: InputDecoration(
            labelText: spec.label,
            helperMaxLines: 2,
            helperText: spec.help,
          ),
          minLines: 1,
          maxLines: 5,
          validator: spec.required ? FormBuilderValidators.required() : null,
        ),
      ],
    );
  }
}
