import 'package:cthulu_character_creator/fields/coc_skillset/widget.dart';
import 'package:cthulu_character_creator/fields/email/response_widget.dart';
import 'package:cthulu_character_creator/fields/info/response_widget.dart';
import 'package:cthulu_character_creator/fields/single_select/response_widget.dart';
import 'package:cthulu_character_creator/fields/text/response_widget.dart';
import 'package:cthulu_character_creator/fields/text_area/response_widget.dart';
import 'package:cthulu_character_creator/model/form.dart' as model;
import 'package:cthulu_character_creator/model/form_response.dart';
import 'package:flutter/material.dart';

class ResponseField extends StatelessWidget {
  const ResponseField({
    super.key,
    required this.spec,
    this.initialValue,
    required this.canEdit,
  });

  final model.FormField spec;
  final FormFieldResponse? initialValue;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    if (spec.isInfo) {
      return InfoResponseWidget(spec: spec.infoRequired);
    } else if (spec.isEmail) {
      return EmailResponseWidget(
        spec: spec.emailRequired,
        initialValue: initialValue?.email,
        canEdit: canEdit,
      );
    } else if (spec.isSingleSelect) {
      return SingleSelectResponseWidget(
        spec: spec.singleSelectRequired,
        intialValue: initialValue?.singleSelect,
      );
    } else if (spec.isText) {
      return TextResponseWidget(
        spec: spec.textRequired,
        initialValue: initialValue?.text,
      );
    } else if (spec.isTextArea) {
      return TextAreaResponseWidget(
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
