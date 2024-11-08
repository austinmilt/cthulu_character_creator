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
  @override
  Widget build(BuildContext context) {
    // TODO try to reduce the number of propagating updates that might be causing
    // the cursor to lose focus when you type in a slot
    print('update');
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
      FormBuilderTextField(
        name: 'key',
        decoration: const InputDecoration(
          labelText: 'key',
          helperText: "The unique identifying key of this field in your form used to label responses.",
          helperMaxLines: 20,
        ),
        initialValue: subspec.key,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (v) => _onUpdate(key: v),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.maxLength(20),
        ]),
      ),
      FormBuilderTextField(
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
      FormBuilderCheckbox(
        name: 'required',
        title: const Text("required"),
        initialValue: subspec.required,
        onChanged: (v) => _onUpdate(required: v),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
        ]),
      ),
      FormBuilderTextField(
        name: 'slots',
        decoration: const InputDecoration(
          labelText: 'slots',
          helperText: "The number of times a response may be repeated; 1 slot "
              "means each response must be unique.",
          helperMaxLines: 20,
        ),
        initialValue: subspec.slots?.toString(),
        keyboardType: TextInputType.number,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (v) => _onUpdate(slots: (v == null) ? null : int.parse(v)),
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.positiveNumber(),
          FormBuilderValidators.max(100),
        ]),
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
      const SizedBox(height: 24),
      _OptionsBuilder(
        options: subspec.options,
        onUpdate: (v) => _onUpdate(options: v),
      )
    ]);
  }
}

class _OptionsBuilder extends StatelessWidget {
  const _OptionsBuilder({required this.options, required this.onUpdate});

  final List<String> options;
  final void Function(List<String>) onUpdate;

  void _onUpdate(int index, String newValue) {
    onUpdate(List.generate(
      options.length,
      (i) => (i == index) ? newValue : options[i],
    ));
  }

  void _addOption() {
    onUpdate(options + ["NEW"]);
  }

  void _onRemove(int index) {
    options.removeAt(index);
    onUpdate(options);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Slots'),
        const SizedBox(height: 8),
        ListView.builder(
          // update the key to force a re-render when we remove a skill
          key: Key(options.length.toString()),
          shrinkWrap: true,
          itemCount: options.length + 1,
          itemBuilder: (context, i) => (i < options.length)
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Stack(
                    children: [
                      _OptionBuilder(
                        option: options[i],
                        onUpdate: (v) => _onUpdate(i, v),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            onPressed: () => _onRemove(i),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: IconButton.outlined(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _OptionBuilder extends StatelessWidget {
  const _OptionBuilder({required this.option, required this.onUpdate});

  final String option;
  final void Function(String) onUpdate;

  void _onUpdate(String? value) {
    if (value != null) {
      onUpdate(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: 'option',
      keyboardType: TextInputType.text,
      initialValue: option,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: _onUpdate,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.maxLength(100),
        FormBuilderValidators.minLength(1),
      ]),
    );
  }
}
