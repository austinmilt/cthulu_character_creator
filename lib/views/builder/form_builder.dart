import 'package:cthulu_character_creator/components/top_center_list_view.dart';
import 'package:cthulu_character_creator/fields/coc_skillset/field.dart';
import 'package:cthulu_character_creator/fields/email/field.dart';
import 'package:cthulu_character_creator/fields/info/field.dart';
import 'package:cthulu_character_creator/fields/single_select/field.dart';
import 'package:cthulu_character_creator/fields/text/field.dart';
import 'package:cthulu_character_creator/fields/text_area/field.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/views/builder/builder_field_widget.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder({super.key});

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  Widget _card(Widget child, void Function()? onRemove) {
    return Card.outlined(
      elevation: 1,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
          if (onRemove != null)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FormBuilderController controller = context.watch<FormBuilderController>();
    final List<C4FormField?> partialForm = controller.partialForm;
    final int fieldCount = controller.partialForm.length;
    return TopCenterListView(
      maxWidth: 600,
      itemCount: fieldCount + 1,
      itemBuilder: (context, i) {
        if (i < fieldCount) {
          final C4FormField? field = partialForm[i];
          if (field != null) {
            final FieldBuilderController fieldController = controller.getFieldController(i);
            return _card(
              BuilderFieldWidget(controller: fieldController),
              controller.editing ? () => controller.removeField(i) : null,
            );
          } else {
            return const SizedBox();
          }
        } else if (controller.editing) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              runSpacing: 20,
              alignment: WrapAlignment.spaceBetween,
              spacing: 20,
              children: [
                IconButton.filled(
                  onPressed: () => controller.addField(
                    C4FormField.info(
                      InformationFormField(title: 'title', bodyMarkdown: 'body'),
                    ),
                  ),
                  icon: const Icon(Icons.info),
                ),
                IconButton.filled(
                  onPressed: () => controller.addField(
                    C4FormField.email(
                      EmailFormField(
                        key: 'email-$fieldCount',
                        title: 'Email',
                        bodyMarkdown: null,
                        required: true,
                        slots: 1,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.email),
                ),
                IconButton.filled(
                  onPressed: () => controller.addField(
                    C4FormField.text(
                      C4TextFormField(
                        key: 'text-$fieldCount',
                        title: 'Text',
                        required: true,
                        bodyMarkdown: null,
                        slots: null,
                        label: null,
                        help: null,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.text_fields),
                ),
                IconButton.filled(
                  onPressed: () => controller.addField(
                    C4FormField.textArea(
                      TextAreaFormField(
                        key: 'text-area-$fieldCount',
                        title: 'Text Area',
                        required: true,
                        bodyMarkdown: null,
                        slots: null,
                        label: null,
                        help: null,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.text_snippet),
                ),
                IconButton.filled(
                  onPressed: () => controller.addField(
                    C4FormField.singleSelect(
                      SingleSelectFormField(
                        key: 'singles-select-$fieldCount',
                        title: 'Select',
                        required: true,
                        bodyMarkdown: null,
                        slots: 1,
                        options: [],
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.radio_button_checked),
                ),
                IconButton.filled(
                  onPressed: () => controller.addField(
                    C4FormField.cocSkillset(
                      CoCSkillsetFormField(
                        key: 'coc-skillset-$fieldCount',
                        title: 'Skills',
                        required: true,
                        bodyMarkdown: null,
                        skills: [],
                        slots: [],
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.psychology),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
