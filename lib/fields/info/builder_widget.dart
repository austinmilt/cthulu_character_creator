import 'package:cthulu_character_creator/fields/info/field.dart';
import 'package:cthulu_character_creator/fields/info/response_widget.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:cthulu_character_creator/model/form.dart';

class InfoBuilder extends StatefulWidget {
  const InfoBuilder({super.key, required this.controller});

  final FieldBuilderController controller;

  @override
  State<InfoBuilder> createState() => _InfoBuilderState();
}

class _InfoBuilderState extends State<InfoBuilder> {
  // C4FormField _getSpec(FormBuilderController controller) {
  //   final C4FormField? candidate = controller.getField(widget.fieldIndex);
  //   return C4FormField.info(
  //     InformationFormField(
  //       title: candidate?.info?.title,
  //       bodyMarkdown: candidate?.info?.bodyMarkdown,
  //     ),
  //     candidate?.group,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final C4FormField spec = widget.controller.spec;
    return widget.controller.editing
        ? _Editor(spec: spec, onUpdate: (p0) => widget.controller.spec = p0)
        : InfoResponseWidget(
            controller: FieldResponseController(spec, true, null),
          );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({required this.spec, required this.onUpdate});

  final C4FormField spec;
  final void Function(C4FormField) onUpdate;

  void _onUpdate({
    String? title,
    String? bodyMarkdown,
  }) {
    final InformationFormField subspec = spec.infoRequired;
    onUpdate(C4FormField.info(InformationFormField(
      title: title ?? subspec.title,
      bodyMarkdown: bodyMarkdown ?? subspec.bodyMarkdown,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final InformationFormField subspec = spec.infoRequired;
    return Column(children: [
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
      const SizedBox(height: 18),
      FormBuilderTextField(
        name: 'bodyMarkdown',
        initialValue: subspec.bodyMarkdown,
        decoration: const InputDecoration(labelText: 'description'),
        onChanged: (v) => _onUpdate(bodyMarkdown: v),
        minLines: 1,
        maxLines: 20,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.maxLength(10000),
        ]),
      ),
    ]);
  }
}
