import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/fields/single_select/field.dart' as model;
import 'package:cthulu_character_creator/fields/single_select/response.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class SingleSelectResponseWidget extends StatefulWidget {
  const SingleSelectResponseWidget({super.key, required this.spec, this.intialValue});

  final model.SingleSelectFormField spec;
  final SingleSelectResponse? intialValue;

  @override
  State<SingleSelectResponseWidget> createState() => _SingleSelectResponseWidgetState();
}

class _SingleSelectResponseWidgetState extends State<SingleSelectResponseWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<FormBuilderChipOption<String>> _options(Iterable<String> values) {
    final List<FormBuilderChipOption<String>> result = [];
    for (final String option in values) {
      final String label;
      final int? slots = widget.spec.slots;
      final int? slotsRemaining = context.watch<ResponseController>().slotsRemaining(widget.spec.key, option);
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FieldMarkdown(
          title: widget.spec.title,
          bodyMd: widget.spec.bodyMarkdown,
        ),
        const SizedBox(height: 20),
        FormBuilderChoiceChip(
          name: widget.spec.key,
          initialValue: widget.intialValue,
          enabled: context.watch<ResponseController>().canEditResponse,
          spacing: 8,
          runSpacing: 8,
          // disable the bottom border line that's on every input
          decoration: const InputDecoration(border: InputBorder.none),
          options: _options(widget.spec.options),
          validator: widget.spec.required ? FormBuilderValidators.required() : null,
        ),
      ],
    );
  }
}
