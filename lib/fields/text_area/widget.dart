import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/text_area/field.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TextAreaWidget extends StatelessWidget {
  const TextAreaWidget({super.key, required this.spec});

  final model.TextAreaFormField spec;

  @override
  Widget build(BuildContext context) {
    // TODO validate slots
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
