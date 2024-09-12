import 'package:cthulu_character_creator/fields/info/field.dart' as model;
import 'package:cthulu_character_creator/components/markdown.dart';
import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key, required this.spec});

  final model.InformationFormField spec;

  @override
  Widget build(BuildContext context) {
    return FieldMarkdown(
      title: spec.title,
      bodyMd: spec.bodyMarkdown,
    );
  }
}
