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
    return Scaffold(
      body: FutureBuilder(
        future: context.read<FormBuilderController>().load('coc-dragoncon-stakes'),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FormBuilder(gameId: 'coc-dragoncon-stakes');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
