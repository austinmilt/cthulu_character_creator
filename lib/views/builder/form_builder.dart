import 'package:cthulu_character_creator/components/top_center_scrollable_container.dart';
import 'package:cthulu_character_creator/fields/email/builder_widget.dart';
import 'package:flutter/material.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder({super.key, required this.gameId});

  final String gameId;

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  @override
  Widget build(BuildContext context) {
    return const TopCenterScrollableContainer(
      maxWidth: 600,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          EmailBuilder(fieldIndex: 1),
        ],
      ),
    );
  }
}
