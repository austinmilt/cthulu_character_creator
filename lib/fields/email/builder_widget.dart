import 'package:cthulu_character_creator/fields/email/field.dart';
import 'package:cthulu_character_creator/fields/email/response_widget.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:cthulu_character_creator/model/form.dart' as m;

class EmailBuilder extends StatefulWidget {
  const EmailBuilder({super.key, required this.fieldIndex});

  final int fieldIndex;

  @override
  State<EmailBuilder> createState() => _EmailBuilderState();
}

class _EmailBuilderState extends State<EmailBuilder> {
  List<bool> _toggleState = [true, false];

  m.FormField _getSpec(FormBuilderController controller) {
    final m.FormField? candidate = controller.getField(widget.fieldIndex);
    return m.FormField.email(
      EmailFormField(
        key: candidate?.email?.key ?? 'email-${widget.fieldIndex}',
        title: candidate?.email?.title,
        bodyMarkdown: candidate?.email?.bodyMarkdown,
        required: candidate?.email?.required ?? true,
        slots: candidate?.email?.slots,
      ),
      candidate?.group,
    );
  }

  void _onUpdate(m.FormField update, FormBuilderController controller) {
    controller.setField(widget.fieldIndex, update);
  }

  @override
  Widget build(BuildContext context) {
    final FormBuilderController controller = context.watch<FormBuilderController>();
    final m.FormField spec = _getSpec(controller);
    return Column(
      children: [
        ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
            setState(() {
              _toggleState = [index == 0, index == 1];
            });
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          isSelected: _toggleState,
          children: const [Icon(Icons.edit), Icon(Icons.preview)],
        ),
        if (_toggleState[0])
          _Editor(
            spec: spec,
            onUpdate: (p0) => _onUpdate(p0, controller),
          ),
        if (_toggleState[1])
          EmailResponseWidget(
            spec: spec.emailRequired,
            canEdit: false,
            initialValue: 'john.doe@gmail.com',
          )
      ],
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.spec, required this.onUpdate});

  final m.FormField spec;
  final void Function(m.FormField) onUpdate;

  void _onUpdate({
    String? key,
    String? title,
    String? bodyMarkdown,
    bool? required,
    int? slots,
  }) {
    debugPrint('update');
    final EmailFormField emailSpec = spec.emailRequired;
    onUpdate(m.FormField.email(EmailFormField(
      key: key ?? emailSpec.key,
      title: title ?? emailSpec.title,
      bodyMarkdown: bodyMarkdown ?? emailSpec.bodyMarkdown,
      required: required ?? emailSpec.required,
      slots: slots ?? emailSpec.slots,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final EmailFormField emailSpec = spec.emailRequired;
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
              initialValue: emailSpec.key,
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
              initialValue: emailSpec.title,
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
              initialValue: emailSpec.required,
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
              initialValue: emailSpec.slots?.toString(),
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
        initialValue: emailSpec.bodyMarkdown,
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
