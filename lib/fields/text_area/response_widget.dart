import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/text_area/field.dart' as model;
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class TextAreaResponseWidget extends StatelessWidget {
  const TextAreaResponseWidget({super.key, required this.controller});

  final FieldResponseController controller;

  @override
  Widget build(BuildContext context) {
    final model.TextAreaFormField spec = controller.spec.textAreaRequired;
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
          initialValue: controller.response?.textArea,
          enabled: controller.canEdit,
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
