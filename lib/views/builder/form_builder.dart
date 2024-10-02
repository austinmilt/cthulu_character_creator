import 'package:cthulu_character_creator/components/top_center_scrollable_container.dart';
import 'package:cthulu_character_creator/fields/info/field.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/views/builder/builder_field_widget.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder({super.key, required this.gameId});

  final String gameId;

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  @override
  Widget build(BuildContext context) {
    final FormBuilderController controller = context.watch<FormBuilderController>();
    final List<Widget> fieldWidgets = [];
    final List<C4FormField?> partialForm = controller.partialForm;
    for (int i = 0; i < controller.partialForm.length; i++) {
      final C4FormField? field = partialForm[i];
      if (field != null) {
        final FieldBuilderController fieldController = controller.getFieldController(i);
        fieldWidgets.add(BuilderFieldWidget(controller: fieldController));
      }
    }
    fieldWidgets.add(
      IconButton.filled(
        onPressed: () => controller.addField(
          C4FormField.info(
            // TODO choose the field type
            InformationFormField(title: 'title', bodyMarkdown: 'body'),
          ),
        ),
        icon: const Icon(Icons.add),
      ),
    );
    return TopCenterScrollableContainer(
      maxWidth: 600,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: fieldWidgets,
      ),
    );
  }
}
