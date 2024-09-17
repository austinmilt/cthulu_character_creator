import 'package:cthulu_character_creator/fields/coc_skillset/widget.dart';
import 'package:cthulu_character_creator/fields/email/widget.dart';
import 'package:cthulu_character_creator/fields/info/widget.dart';
import 'package:cthulu_character_creator/fields/single_select/widget.dart';
import 'package:cthulu_character_creator/fields/text/widget.dart';
import 'package:cthulu_character_creator/fields/text_area/widget.dart';
import 'package:cthulu_character_creator/model/form.dart' as model;
import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:flutter/material.dart';

class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget({super.key, required this.spec, this.initialValue});

  final model.FormField spec;
  final FormFieldResponse? initialValue;

  @override
  Widget build(BuildContext context) {
    if (spec.isInfo) {
      return InfoWidget(spec: spec.infoRequired);
    } else if (spec.isEmail) {
      return EmailWidget(
        spec: spec.emailRequired,
        initialValue: initialValue?.email,
      );
    } else if (spec.isSingleSelect) {
      return SingleSelectWidget(
        spec: spec.singleSelectRequired,
        intialValue: initialValue?.singleSelect,
      );
    } else if (spec.isText) {
      return TextWidget(
        spec: spec.textRequired,
        initialValue: initialValue?.text,
      );
    } else if (spec.isTextArea) {
      return TextAreaWidget(
        spec: spec.textAreaRequired,
        initialValue: initialValue?.textArea,
      );
    } else if (spec.isCocSkillset) {
      return CocSkillsetWidget(
        spec: spec.cocSkillsetRequired,
        initialValue: initialValue?.cocSkillset,
      );
    } else {
      throw UnimplementedError('Cant display this field $spec');
    }
  }
}
