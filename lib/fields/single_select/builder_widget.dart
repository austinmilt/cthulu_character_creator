import 'package:cthulu_character_creator/fields/single_select/field.dart';
import 'package:cthulu_character_creator/fields/single_select/response_widget.dart';
import 'package:cthulu_character_creator/model/form_response.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:cthulu_character_creator/model/form.dart';

class SingleSelectBuilder extends StatefulWidget {
  const SingleSelectBuilder({super.key, required this.controller});

  final FieldBuilderController controller;

  @override
  State<SingleSelectBuilder> createState() => _SingleSelectBuilderState();
}

class _SingleSelectBuilderState extends State<SingleSelectBuilder> {
  // C4FormField _getSpec(FormBuilderController controller) {
  //   return C4FormField.singleSelect(
  //     SingleSelectFormField(
  //       key: candidate?.singleSelect?.key ?? 'single-select-${widget.fieldIndex}',
  //       title: candidate?.singleSelect?.title,
  //       bodyMarkdown: candidate?.singleSelect?.bodyMarkdown,
  //       required: candidate?.singleSelect?.required ?? true,
  //       slots: candidate?.singleSelect?.slots,
  //       options: candidate?.singleSelect?.options ?? [],
  //     ),
  //     candidate?.group,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final C4FormField spec = widget.controller.spec;
    return widget.controller.editing
        ? _Editor(
            spec: spec,
            onUpdate: (s) => widget.controller.spec = s,
          )
        : SingleSelectResponseWidget(
            controller: FieldResponseController(
              spec,
              true,
              FormFieldResponse.singleSelect(spec.singleSelectRequired.options.first),
            ),
          );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.spec, required this.onUpdate});

  final C4FormField spec;
  final void Function(C4FormField) onUpdate;

  void _onUpdate({
    String? key,
    String? title,
    String? bodyMarkdown,
    bool? required,
    int? slots,
    List<String>? options,
  }) {
    final SingleSelectFormField subspec = spec.singleSelectRequired;
    onUpdate(C4FormField.singleSelect(SingleSelectFormField(
      key: key ?? subspec.key,
      title: title ?? subspec.title,
      bodyMarkdown: bodyMarkdown ?? subspec.bodyMarkdown,
      slots: slots ?? subspec.slots,
      required: required ?? subspec.required,
      options: options ?? subspec.options,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final SingleSelectFormField subspec = spec.singleSelectRequired;
    return Column(children: [
      Wrap(
        direction: Axis.horizontal,
        spacing: 16,
        runSpacing: 10,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.loose(const Size(100, double.infinity)),
            child: FormBuilderTextField(
              name: 'key',
              decoration: const InputDecoration(labelText: 'key'),
              initialValue: subspec.key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (v) => _onUpdate(key: v),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.maxLength(20),
              ]),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(const Size(100, double.infinity)),
            child: FormBuilderTextField(
              name: 'title',
              decoration: const InputDecoration(labelText: 'title'),
              initialValue: subspec.title,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (v) => _onUpdate(title: v),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.maxLength(40),
              ]),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(const Size(150, double.infinity)),
            child: FormBuilderCheckbox(
              name: 'required',
              title: const Text("required"),
              initialValue: subspec.required,
              onChanged: (v) => _onUpdate(required: v),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(const Size(100, double.infinity)),
            child: FormBuilderTextField(
              name: 'slots',
              decoration: const InputDecoration(
                labelText: 'slots',
                helperText: "The number of times a response may be repeated; 1 slot "
                    "means each response must be unique.",
              ),
              initialValue: subspec.slots?.toString(),
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (v) => _onUpdate(slots: (v == null) ? null : int.parse(v)),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.positiveNumber(),
                FormBuilderValidators.max(100)
              ]),
            ),
          ),
        ],
      ),
      FormBuilderTextField(
        name: 'bodyMarkdown',
        initialValue: subspec.bodyMarkdown,
        decoration: const InputDecoration(labelText: 'description'),
        onChanged: (v) => _onUpdate(bodyMarkdown: v),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.maxLength(10000),
        ]),
      ),
    ]);
  }
}
