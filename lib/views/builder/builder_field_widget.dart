import 'package:cthulu_character_creator/fields/coc_skillset/builder_widget.dart';
import 'package:cthulu_character_creator/fields/email/builder_widget.dart';
import 'package:cthulu_character_creator/fields/info/builder_widget.dart';
import 'package:cthulu_character_creator/fields/single_select/builder_widget.dart';
import 'package:cthulu_character_creator/fields/text/builder_widget.dart';
import 'package:cthulu_character_creator/fields/text_area/builder_widget.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';

class BuilderFieldWidget extends StatelessWidget {
  const BuilderFieldWidget({super.key, required this.controller});

  final FieldBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final C4FormField field = controller.spec;
    if (field.isCocSkillset) {
      return CocSkillsetBuilder(controller: controller);
    } else if (field.isEmail) {
      return EmailBuilder(controller: controller);
    } else if (field.isInfo) {
      return InfoBuilder(controller: controller);
    } else if (field.isSingleSelect) {
      return SingleSelectBuilder(controller: controller);
    } else if (field.isText) {
      return TextBuilder(controller: controller);
    } else if (field.isTextArea) {
      return TextAreaBuilder(controller: controller);
    } else {
      throw StateError("Unhandled field type $field");
    }
  }
}
