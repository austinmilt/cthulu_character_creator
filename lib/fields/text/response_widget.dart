import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/text/field.dart' as model;
import 'package:cthulu_character_creator/fields/text/response.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class TextResponseWidget extends StatelessWidget {
  const TextResponseWidget({super.key, required this.spec, this.initialValue});

  final model.TextFormField spec;
  final TextResponse? initialValue;

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
          enabled: context.watch<ResponseController>().canEditResponse,
          decoration: InputDecoration(
            labelText: spec.label,
            helperMaxLines: 2,
            helperText: spec.help,
          ),
          validator: spec.required ? FormBuilderValidators.required() : null,
        ),
      ],
    );
  }
}
