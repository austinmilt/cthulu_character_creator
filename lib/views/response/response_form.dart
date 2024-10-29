import 'package:cthulu_character_creator/components/top_center_scrollable_container.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/model/form_response.dart';
import 'package:cthulu_character_creator/views/response/response_view.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:cthulu_character_creator/views/response/response_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:cthulu_character_creator/model/form.dart';

class ResponseForm extends StatefulWidget {
  const ResponseForm({super.key});

  @override
  ResponseFormState createState() {
    return ResponseFormState();
  }
}

class ResponseFormState extends State<ResponseForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final ResponseController controller = context.watch<ResponseController>();
    return FormBuilder(
      key: _formKey,
      child: TopCenterScrollableContainer(
        maxWidth: 600,
        padding: const EdgeInsets.all(16),
        child: _FormLoaded(
          gameId: controller.gameId,
          responseId: controller.submission?.id,
          editAuthSecret: controller.submission?.editAuthSecret,
          form: controller.form,
          priorResponse: controller.submission,
        ),
      ),
    );
  }
}

class _FormLoaded extends StatefulWidget {
  const _FormLoaded({
    required this.gameId,
    required this.form,
    this.priorResponse,
    this.responseId,
    this.editAuthSecret,
  });

  final String gameId;
  final String? responseId;
  final C4Form form;
  final FormResponse? priorResponse;
  final String? editAuthSecret;

  @override
  State<_FormLoaded> createState() => _FormLoadedState();
}

class _FormLoadedState extends State<_FormLoaded> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _submitting = false;
  late final Logger _logger;
  late final List<List<C4FormField>> _fields;

  @override
  void initState() {
    super.initState();
    // TODO could clean some of this up putting logic and state into the controller
    _logger = context.read<LoggerFactory>().makeLogger(ResponseForm);
    _fields = _prepareEntries(widget.form, widget.priorResponse);
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
    for (C4FormField spec in widget.form) {
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

    final ResponseController controller = context.read<ResponseController>();
    final List<String> validationFailures = await controller.validationSubmission(submission);
    if (validationFailures.isNotEmpty && mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Column(children: validationFailures.map((f) => Text(f)).toList()),
        ));
      }
      return;
    }

    try {
      await controller.submit(submission);
      if (mounted) {
        ResponseView.replaceRoute(
          context,
          widget.gameId,
          submission.id,
          submission.editAuthSecret,
        );
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

  List<List<C4FormField>> _prepareEntries(C4Form form, FormResponse? startingValues) {
    final List<List<C4FormField>> result = [];
    List<C4FormField> currentGroupOfEntries = [];
    String? lastGroup;
    for (int i = 0; i < form.length; i++) {
      final C4FormField entry = form[i];
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
    final ResponseController controller = context.watch<ResponseController>();
    final List<Widget> children = [];
    int index = 0;
    for (List<C4FormField> group in _fields) {
      if (group.length == 1) {
        final FieldResponseController fieldController = controller.getFieldController(index++);
        children.add(_section(ResponseFieldWidget(controller: fieldController)));
      } else {
        children.add(_section(Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: group
              .map(
                (field) => ResponseFieldWidget(
                  controller: controller.getFieldController(index++),
                ),
              )
              .toList(),
        )));
      }
    }
    if (context.watch<ResponseController>().canEditResponse) {
      children.add(
        FilledButton(
          onPressed: _submitting ? null : _onSubmit,
          child: _submitting ? const Text('Loading') : const Text('Submit'),
        ),
      );
    }
    return FormBuilder(
      key: _formKey,
      child: TopCenterScrollableContainer(
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
