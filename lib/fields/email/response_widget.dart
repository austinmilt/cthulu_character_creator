import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/email/field.dart' as model;
import 'package:cthulu_character_creator/fields/email/response.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class EmailResponseWidget extends StatelessWidget {
  const EmailResponseWidget({super.key, required this.spec, this.initialValue});

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
          enabled: context.watch<ResponseController>().canEditResponse,
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
