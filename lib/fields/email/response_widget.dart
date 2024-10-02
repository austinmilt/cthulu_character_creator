import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/email/field.dart';
import 'package:cthulu_character_creator/fields/email/response.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class EmailResponseWidget extends StatelessWidget {
  const EmailResponseWidget({super.key, required this.controller});

  final FieldResponseController controller;

  @override
  Widget build(BuildContext context) {
    final EmailFormField spec = controller.spec.emailRequired;
    final EmailResponse? currentValue = controller.response?.email;
    // TODO impose slot limits
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
          initialValue: currentValue,
          enabled: controller.canEdit,
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
