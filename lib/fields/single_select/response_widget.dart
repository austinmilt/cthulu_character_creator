import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/single_select/field.dart';
import 'package:cthulu_character_creator/fields/single_select/response.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class SingleSelectResponseWidget extends StatefulWidget {
  const SingleSelectResponseWidget({super.key, required this.controller});

  final FieldResponseController controller;

  @override
  State<SingleSelectResponseWidget> createState() => _SingleSelectResponseWidgetState();
}

class _SingleSelectResponseWidgetState extends State<SingleSelectResponseWidget> {
  List<FormBuilderChipOption<String>> _options(SingleSelectFormField spec) {
    final List<FormBuilderChipOption<String>> result = [];
    for (final String option in spec.options) {
      final String label;
      final int? slots = spec.slots;
      // TODO should this be a field in the field controller rather than the top response controller?
      final int? slotsRemaining = context.watch<ResponseController>().slotsRemaining(spec.key, option);
      if (slots != null) {
        if (slotsRemaining != null) {
          label = '$option ($slotsRemaining/$slots)';
        } else {
          label = '$option ($slots/$slots)';
        }
      } else {
        label = option;
      }
      result.add(FormBuilderChipOption(
        value: option,
        child: Text(label),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final SingleSelectFormField spec = widget.controller.spec.singleSelectRequired;
    final SingleSelectResponse? currentValue = widget.controller.response?.singleSelect;
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
          initialValue: currentValue,
          enabled: widget.controller.canEdit,
          spacing: 8,
          runSpacing: 8,
          // disable the bottom border line that's on every input
          decoration: const InputDecoration(border: InputBorder.none),
          options: _options(spec),
          validator: spec.required ? FormBuilderValidators.required() : null,
        ),
      ],
    );
  }
}
