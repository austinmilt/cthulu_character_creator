import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/model/form.dart';
import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:cthulu_character_creator/model/skill.dart';
import 'package:cthulu_character_creator/views/character_creator/form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:cthulu_character_creator/model/form.dart' as form_model;

class MainForm extends StatefulWidget {
  const MainForm({super.key, required this.gameId});

  final String gameId;

  @override
  MainFormState createState() {
    return MainFormState();
  }
}

class MainFormState extends State<MainForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _submitting = false;
  late Future<form_model.Form> _formFuture;
  late final Logger _logger;

  @override
  void initState() {
    super.initState();
    _logger = context.read<LoggerFactory>().makeLogger(MainForm);
    _formFuture = context.read<Api>().getForm(widget.gameId);
  }

  void _onSubmit() {
    setState(() {
      _submitting = true;
      _onSubmitMain().then((_) {
        setState(() {
          _submitting = false;
        });
      }).onError((e, s) {
        _logger.error('Error submitting form $e');
        setState(() {
          _submitting = false;
        });
      });
    });
  }

  Future<void> _onSubmitMain() async {
    final bool? formIsValid = _formKey.currentState?.saveAndValidate();
    if (formIsValid == false) {
      // user has not filled in all required fields with valid values.
      // If [formIsValid] is null then there's no data yet, which we will
      // balk about below
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all required responses.')));
      return;
    }

    final Map<String, dynamic>? formDataMap = _formKey.currentState?.value;
    if (formDataMap == null) {
      throw StateError("BUG: Should not be able to submit the form without any data");
    }

    // TODO refactor this to pull fields from the Form
    final FormResponseData submission = FormResponseData(
      gameId: widget.gameId,
      email: formDataMap['email'],
      occupation: formDataMap['occupation'],
      skills: (formDataMap['skills'] as (List<Skill>, bool)).$1,
      name: formDataMap['name'],
      appearance: formDataMap['appearance'],
      traits: formDataMap['traits'],
      ideology: formDataMap['ideology'],
      injuries: formDataMap['injuries'],
      relationships: formDataMap['relationships'],
      phobias: formDataMap['phobias'],
      treasures: formDataMap['treasures'],
      details: formDataMap['details'],
      items: formDataMap['items'],
    );
    final Api api = context.read<Api>();
    try {
      await api.submitForm(submission);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission received! You may still make changes and resubmit.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Submission error! Check your responses and resubmit.')));
      }
      rethrow;
    }
  }

  List<List<FormFieldEntry>> _groupEntries(form_model.Form form) {
    final List<List<FormFieldEntry>> result = [];
    List<FormFieldEntry> currentGroupOfEntries = [];
    String? lastGroup;
    for (int i = 0; i < form.length; i++) {
      final FormFieldEntry entry = form[i];
      // detect when a new group has started. Note this grouping preserves
      // the overall ordering of entries at the expense that non-contiguous
      // entries with the same group ID will wind up in different sections, e.g.
      // [group a, group a, group b, group a] => [[group a, group a], [group b], [group a]]
      if ((i > 0) && ((entry.group == null) || (entry.group != lastGroup))) {
        result.add(currentGroupOfEntries);
        currentGroupOfEntries = [];
      }
      currentGroupOfEntries.add(entry);
      lastGroup = entry.group;
    }
    result.add(currentGroupOfEntries);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: _TopCenterScrollableContainer(
        maxWidth: 600,
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: _formFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<List<FormFieldEntry>> groupedEntries = _groupEntries(snapshot.data!);
              final List<Widget> children = [];
              for (List<FormFieldEntry> group in groupedEntries) {
                if (group.length == 1) {
                  children.add(_section(FormFieldWidget(spec: group.first)));
                } else {
                  children.add(_section(Column(
                    children: group.map((field) => FormFieldWidget(spec: field)).toList(),
                  )));
                }
              }
              children.add(
                FilledButton(
                  onPressed: _submitting ? null : _onSubmit,
                  child: _submitting ? const Text('Loading') : const Text('Submit'),
                ),
              );
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('uh oh ${snapshot.error} ${snapshot.stackTrace}'),
              );
            } else {
              // TODO handle errors and edge cases
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class _TopCenterScrollableContainer extends StatelessWidget {
  const _TopCenterScrollableContainer({this.child, this.maxWidth, this.padding});

  final Widget? child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        // wrapping the main Container (below) in a Center makes it so the Center
        // takes up the full width of the view while enforcing a max width on
        // the main Container. This makes the page's scrollbar (from the
        // SingleChildScrollView) stick to the right side of the page rather than
        // being butted up against the main Container, which is annoying on mobile
        child: Center(
          child: Container(
            constraints: (maxWidth == null) ? null : BoxConstraints(maxWidth: maxWidth!),
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: child ?? const SizedBox(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _section(Widget? child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    // PhysicalModel applies a shadow based on elevation
    child: PhysicalModel(
      color: Colors.white,
      elevation: 1,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ),
  );
}
