import 'package:cthulu_character_creator/api.dart';
import 'package:cthulu_character_creator/components/top_center_scrollable_container.dart';
import 'package:cthulu_character_creator/crypto.dart';
import 'package:cthulu_character_creator/logging.dart';
import 'package:cthulu_character_creator/model/game.dart';
import 'package:cthulu_character_creator/model/game_system.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_view.dart';
import 'package:cthulu_character_creator/views/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static final GoRoute route = GoRoute(
    name: 'home',
    path: '/',
    builder: (context, state) {
      return const HomeView();
    },
  );

  static void navigate(
    BuildContext context,
    String gameId,
    String auth,
  ) {
    final Map<String, String> pathParams = {};
    final Map<String, String> queryParams = {};
    context.goNamed(
      route.name!,
      pathParameters: pathParams,
      queryParameters: queryParams,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // placeholder for later when we need to load some state, e.g. my games from local storage
      future: Future.value(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _ViewLoaded();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class _ViewLoaded extends StatefulWidget {
  @override
  State<_ViewLoaded> createState() => _ViewLoadedState();
}

class _ViewLoadedState extends State<_ViewLoaded> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TopCenterScrollableContainer(maxWidth: 600, padding: const EdgeInsets.all(20), child: _NewGameForm()),
    );
  }
}

class _NewGameForm extends StatefulWidget {
  @override
  State<_NewGameForm> createState() => _NewGameFormState();
}

class _NewGameFormState extends State<_NewGameForm> {
  static const _k = (
    name: 'name',
    system: 'system',
  );

  final _formKey = GlobalKey<FormBuilderState>();
  late final Logger _logger;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _logger = context.read<LoggerFactory>().makeLogger(HomeView);
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
      throw StateError("BUG: Should not be able to create the game without any data");
    }

    final String gameName = formDataMap[_k.name];
    final GameSystem system = formDataMap[_k.system];

    try {
      final Game game = await context.read<HomeController>().createGame(gameName, system);
      if (mounted) {
        FormBuilderView.navigate(context, game.id, game.auth);
      }
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: _k.name,
            initialValue: myRandomPhrase(),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: "Name",
              helperMaxLines: 2,
              helperText: "Unique game name",
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              // letters, numbers, hyphens, and underscores
              FormBuilderValidators.alphabetical(
                regex: RegExp(r"^[a-zA-Z0-9-_]+$"),
                errorText: "only letters, numbers, hyphens, and underscores allowed",
              ),
              FormBuilderValidators.minLength(3),
              FormBuilderValidators.maxLength(48),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderDropdown(
            name: _k.system,
            initialValue: GameSystem.values.first,
            items: GameSystem.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _onSubmit,
            child: _submitting ? const Text('Loading') : const Text('Create game'),
          ),
        ],
      ),
    );
  }
}
