import 'package:cthulu_character_creator/fields/email/field.dart';
import 'package:cthulu_character_creator/fields/email/response_widget.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cthulu_character_creator/model/form.dart' as m;

class EmailBuilder extends StatefulWidget {
  const EmailBuilder({super.key, required this.fieldIndex});

  final int fieldIndex;

  @override
  State<EmailBuilder> createState() => _EmailBuilderState();
}

class _EmailBuilderState extends State<EmailBuilder> {
  String? key;
  String? title;
  String? bodyMarkdown;
  bool? required;
  int? slots;

  m.FormField _getSpec(FormBuilderController controller) {
    final m.Form controllerForm = controller.form;
    final m.FormField? controllerSpec =
        (controllerForm.length > widget.fieldIndex) ? controllerForm[widget.fieldIndex] : null;
    final EmailFormField? controllerField = controllerSpec?.email;
    return m.FormField.email(
      EmailFormField(
        key: key ?? controllerField?.key ?? "lakjsdflkajsdflkjasldfkj",
        title: title ?? controllerField?.title,
        bodyMarkdown: bodyMarkdown ?? controllerField?.bodyMarkdown,
        required: required ?? controllerField?.required ?? true,
        slots: slots ?? controllerField?.slots,
      ),
      controllerSpec?.group,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FormBuilderController controller = context.watch<FormBuilderController>();
    final m.FormField spec = _getSpec(controller);
    // TODO toggle between edit with field stuff like key, and preview like below
    // TODO will also need to add the field to the form if it doesnt already exist
    // TODO also you put some placeholder stuff in the builder view
    return EmailResponseWidget(spec: spec.emailRequired);
  }
}
