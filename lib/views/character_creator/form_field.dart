import 'package:cthulu_character_creator/fields/coc_skillset/widget.dart';
import 'package:cthulu_character_creator/fields/email/widget.dart';
import 'package:cthulu_character_creator/fields/info/widget.dart';
import 'package:cthulu_character_creator/fields/single_select/widget.dart';
import 'package:cthulu_character_creator/fields/text/widget.dart';
import 'package:cthulu_character_creator/fields/text_area/widget.dart';
import 'package:cthulu_character_creator/model/form.dart' as model;
import 'package:flutter/material.dart';

class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget({super.key, required this.spec});

  final model.FormField spec;

  @override
  Widget build(BuildContext context) {
    if (spec.isInfo) {
      return InfoWidget(spec: spec.infoRequired);
    } else if (spec.isEmail) {
      return FieldWidget(spec: spec.emailRequired);
    } else if (spec.isSingleSelect) {
      return SingleSelectWidget(spec: spec.singleSelectRequired);
    } else if (spec.isText) {
      return TextWidget(spec: spec.textRequired);
    } else if (spec.isTextArea) {
      return TextAreaWidget(spec: spec.textAreaRequired);
    } else if (spec.isCocSkillset) {
      return CocSkillsetWidget(spec: spec.cocSkillsetRequired);
    } else {
      throw UnimplementedError('Cant display this field $spec');
    }
  }
}
