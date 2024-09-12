import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/email/field.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FieldWidget extends StatelessWidget {
  const FieldWidget({super.key, required this.spec});

  final model.EmailFormField spec;

  @override
  Widget build(BuildContext context) {
    // TODO validate slots
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FieldMarkdown(
          title: spec.title,
          bodyMd: spec.bodyMarkdown,
        ),
        const SizedBox(height: 10),
        FormBuilderTextField(
          name: spec.key,
          decoration: InputDecoration(labelText: spec.title),
          keyboardType: TextInputType.emailAddress,
          validator: FormBuilderValidators.compose([
            if (spec.required) FormBuilderValidators.required(),
            FormBuilderValidators.email(),
          ]),
        ),
      ],
    );
  }
}
