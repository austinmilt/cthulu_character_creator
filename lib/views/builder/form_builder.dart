import 'package:cthulu_character_creator/components/top_center_scrollable_container.dart';
import 'package:cthulu_character_creator/fields/email/builder_widget.dart';
import 'package:cthulu_character_creator/fields/info/builder_widget.dart';
import 'package:flutter/material.dart';

class FormBuilder extends StatefulWidget {
  const FormBuilder({super.key, required this.gameId, required this.editing});

  final String gameId;
  final bool editing;

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  @override
  Widget build(BuildContext context) {
    return TopCenterScrollableContainer(
      maxWidth: 600,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InfoBuilder(fieldIndex: 0, editing: widget.editing),
          EmailBuilder(fieldIndex: 1, editing: widget.editing),
        ],
      ),
    );
  }
}
