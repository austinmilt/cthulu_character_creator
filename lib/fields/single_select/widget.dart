import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/single_select/field.dart' as model;
import 'package:cthulu_character_creator/fields/single_select/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SingleSelectWidget extends StatelessWidget {
  const SingleSelectWidget({super.key, required this.spec, this.intialValue});

  final model.SingleSelectFormField spec;
  final SingleSelectResponse? intialValue;

  List<FormBuilderChipOption<T>> _options<T>(Iterable<T> values) {
    return values.map((e) => FormBuilderChipOption(value: e)).toList();
  }

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
        const SizedBox(height: 20),
        FormBuilderChoiceChip(
          name: spec.key,
          initialValue: intialValue,
          spacing: 8,
          runSpacing: 8,
          // disable the bottom border line that's on every input
          decoration: const InputDecoration(border: InputBorder.none),
          options: _options(spec.options),
          validator: spec.required ? FormBuilderValidators.required() : null,
        ),
      ],
    );
  }
}
