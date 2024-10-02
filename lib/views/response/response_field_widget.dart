import 'package:cthulu_character_creator/fields/coc_skillset/widget.dart';
import 'package:cthulu_character_creator/fields/email/response_widget.dart';
import 'package:cthulu_character_creator/fields/info/response_widget.dart';
import 'package:cthulu_character_creator/fields/single_select/response_widget.dart';
import 'package:cthulu_character_creator/fields/text/response_widget.dart';
import 'package:cthulu_character_creator/fields/text_area/response_widget.dart';
import 'package:cthulu_character_creator/model/form.dart' as model;
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';

class ResponseFieldWidget extends StatelessWidget {
  const ResponseFieldWidget({
    super.key,
    required this.controller,
  });

  final FieldResponseController controller;

  @override
  Widget build(BuildContext context) {
    final model.C4FormField spec = controller.spec;
    if (spec.isInfo) {
      return InfoResponseWidget(controller: controller);
    } else if (spec.isEmail) {
      return EmailResponseWidget(controller: controller);
    } else if (spec.isSingleSelect) {
      return SingleSelectResponseWidget(controller: controller);
    } else if (spec.isText) {
      return TextResponseWidget(controller: controller);
    } else if (spec.isTextArea) {
      return TextAreaResponseWidget(controller: controller);
    } else if (spec.isCocSkillset) {
      return CocSkillsetWidget(controller: controller);
    } else {
      throw UnimplementedError('Cant display this field $spec');
    }
  }
}
