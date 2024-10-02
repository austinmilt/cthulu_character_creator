import 'package:cthulu_character_creator/views/builder/form_builder.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FormBuilderView extends StatelessWidget {
  const FormBuilderView({super.key});

  static final GoRoute route = GoRoute(
    name: 'build-form',
    path: '/form/build',
    builder: (context, state) {
      return const FormBuilderView();
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
    // TODO make a new game thing
    return FutureBuilder(
      future: context.read<FormBuilderController>().load('coc-dragoncon-stakes'),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _ViewLoaded();
        } else {
          return const CircularProgressIndicator();
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
  List<bool> _toggleState = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ToggleButtons(
        direction: Axis.horizontal,
        onPressed: (int index) {
          setState(() {
            _toggleState = [index == 0, index == 1];
          });
          context.read<FormBuilderController>().editing = index == 0;
        },
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        isSelected: _toggleState,
        children: const [Icon(Icons.edit), Icon(Icons.preview)],
      ),
      body: FormBuilder(gameId: 'coc-dragoncon-stakes'),
    );
  }
}
