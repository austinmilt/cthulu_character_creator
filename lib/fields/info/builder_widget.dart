import 'package:cthulu_character_creator/fields/info/field.dart';
import 'package:cthulu_character_creator/fields/info/response_widget.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:cthulu_character_creator/model/form.dart' as m;

class InfoBuilder extends StatefulWidget {
  const InfoBuilder({super.key, required this.fieldIndex, required this.editing});

  final int fieldIndex;
  final bool editing;

  @override
  State<InfoBuilder> createState() => _InfoBuilderState();
}

class _InfoBuilderState extends State<InfoBuilder> {
  m.FormField _getSpec(FormBuilderController controller) {
    final m.FormField? candidate = controller.getField(widget.fieldIndex);
    return m.FormField.info(
      InformationFormField(
        title: candidate?.info?.title,
        bodyMarkdown: candidate?.info?.bodyMarkdown,
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
    return widget.editing
        ? _Editor(
            spec: spec,
            onUpdate: (p0) => _onUpdate(p0, controller),
          )
        : InfoResponseWidget(spec: spec.infoRequired);
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.spec, required this.onUpdate});

  final m.FormField spec;
  final void Function(m.FormField) onUpdate;

  void _onUpdate({
    String? title,
    String? bodyMarkdown,
  }) {
    final InformationFormField subspec = spec.infoRequired;
    onUpdate(m.FormField.info(InformationFormField(
      title: title ?? subspec.title,
      bodyMarkdown: bodyMarkdown ?? subspec.bodyMarkdown,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final InformationFormField subspec = spec.infoRequired;
    return Column(children: [
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
      const SizedBox(height: 18),
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
