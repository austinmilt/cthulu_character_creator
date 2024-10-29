import 'package:cthulu_character_creator/fields/info/field.dart' as model;
import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';

class InfoResponseWidget extends StatelessWidget {
  const InfoResponseWidget({super.key, required this.controller});

  final FieldResponseController controller;

  @override
  Widget build(BuildContext context) {
    final model.InformationFormField spec = controller.spec.infoRequired;
    return FieldMarkdown(
      title: spec.title,
      bodyMd: spec.bodyMarkdown,
    );
  }
}
