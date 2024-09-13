import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:cthulu_character_creator/views/character_creator/form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:cthulu_character_creator/model/form.dart' as form_model;

class MainForm extends StatefulWidget {
  const MainForm({
    super.key,
    required this.gameId,
    this.responseId,
    this.editAuthSecret,
  });

  final String gameId;
  final String? responseId;
  final String? editAuthSecret;

  @override
  MainFormState createState() {
    return MainFormState();
  }
}

class MainFormState extends State<MainForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  late Future<form_model.Form> _formFuture;

  @override
  void initState() {
    super.initState();
    _formFuture = context.read<Api>().getForm(widget.gameId);
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
              return _FormLoaded(
                gameId: widget.gameId,
                responseId: widget.responseId,
                editAuthSecret: widget.editAuthSecret,
                form: snapshot.requireData,
              );
            } else if (snapshot.hasError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Something went wrong ${snapshot.error}')));
              return const SizedBox();
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

class _FormLoaded extends StatefulWidget {
  const _FormLoaded({
    required this.gameId,
    required this.form,
    this.responseId,
    this.editAuthSecret,
  });

  final String gameId;
  final String? responseId;
  final form_model.Form form;
  final String? editAuthSecret;

  @override
  State<_FormLoaded> createState() => _FormLoadedState();
}

class _FormLoadedState extends State<_FormLoaded> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _submitting = false;
  late final Logger _logger;
  late final List<List<form_model.FormField>> _fields;

  @override
  void initState() {
    super.initState();
    _logger = context.read<LoggerFactory>().makeLogger(MainForm);
    _fields = _groupEntries(widget.form);
  }

  void _onSubmit() {
    setState(() {
      _submitting = true;
      _onSubmitMain().then((_) {
        setState(() {
          _submitting = false;
        });
      }).onError((e, s) {
        _logger.error('Error submitting form', e, s);
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

    final FormResponse submission = FormResponse(
      id: widget.responseId,
      editAuthSecret: widget.editAuthSecret,
      fields: {},
    );
    for (form_model.FormField spec in widget.form) {
      if (spec.isCocSkillset) {
        final String key = spec.cocSkillsetRequired.key;
        if (formDataMap[key] != null) {
          submission.fields[key] = FormFieldResponse.cocSkillset(formDataMap[key]);
        }
      } else if (spec.isEmail) {
        final String key = spec.emailRequired.key;
        if (formDataMap[key] != null) {
          submission.fields[key] = (FormFieldResponse.email(formDataMap[key]));
        }
      } else if (spec.isSingleSelect) {
        final String key = spec.singleSelectRequired.key;
        if (formDataMap[key] != null) {
          submission.fields[key] = (FormFieldResponse.singleSelect(formDataMap[key]));
        }
      } else if (spec.isText) {
        final String key = spec.textRequired.key;
        if (formDataMap[key] != null) {
          submission.fields[key] = (FormFieldResponse.text(formDataMap[key]));
        }
      } else if (spec.isTextArea) {
        final String key = spec.textAreaRequired.key;
        if (formDataMap[key] != null) {
          submission.fields[key] = (FormFieldResponse.textArea(formDataMap[key]));
        }
      }
    }

    final Api api = context.read<Api>();
    final List<String> validationFailures = await api.validateSubmission(widget.gameId, widget.form, submission);
    if (validationFailures.isNotEmpty && mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Column(children: validationFailures.map((f) => Text(f)).toList()),
        ));
      }
      return;
    }

    try {
      await api.submitForm(widget.gameId, submission);
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

  List<List<form_model.FormField>> _groupEntries(form_model.Form form) {
    final List<List<form_model.FormField>> result = [];
    List<form_model.FormField> currentGroupOfEntries = [];
    String? lastGroup;
    for (int i = 0; i < form.length; i++) {
      final form_model.FormField entry = form[i];
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
    final List<Widget> children = [];
    for (List<form_model.FormField> group in _fields) {
      if (group.length == 1) {
        children.add(_section(FormFieldWidget(spec: group.first)));
      } else {
        children.add(_section(Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
    return FormBuilder(
      key: _formKey,
      child: _TopCenterScrollableContainer(
        maxWidth: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
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
