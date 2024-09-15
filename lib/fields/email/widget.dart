import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/email/field.dart' as model;
import 'package:cthulu_character_creator/fields/email/response.dart';
import 'package:cthulu_character_creator/views/character_creator/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class EmailWidget extends StatelessWidget {
  const EmailWidget({super.key, required this.spec, this.initialValue});

  final model.EmailFormField spec;
  final EmailResponse? initialValue;

  @override
  Widget build(BuildContext context) {
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
          initialValue: initialValue,
          enabled: context.watch<FormController>().canEditResponse,
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
