import 'package:cthulu_character_creator/views/builder/form_builder.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FormBuilderView extends StatelessWidget {
  const FormBuilderView({
    super.key,
    required this.gameId,
    required this.authSecret,
  });

  final String gameId;
  final String authSecret;

  static final GoRoute route = GoRoute(
    name: 'build-form',
    path: '/:gameId/form/build',
    builder: (context, state) {
      final String? gameId = state.pathParameters['gameId'];
      final String? auth = state.uri.queryParameters['s'];
      if (gameId == null) {
        throw StateError('Tried to navigate to submissions view without a game ID');
      }
      if (auth == null) {
        throw StateError("Not authorized to view this.");
      }
      return FormBuilderView(gameId: gameId, authSecret: auth);
    },
  );

  static void navigate(
    BuildContext context,
    String gameId,
    String auth,
  ) {
    final Map<String, String> pathParams = {};
    final Map<String, String> queryParams = {};
    pathParams['gameId'] = gameId;
    queryParams['s'] = auth;
    context.goNamed(
      route.name!,
      pathParameters: pathParams,
      queryParameters: queryParams,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<void> future = context.read<FormBuilderController>().load(gameId, authSecret);
    return FutureBuilder(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          // TODO error page
          return Text("${snapshot.error}");
        } else if (snapshot.connectionState == ConnectionState.done) {
          return const _ViewLoaded();
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
  const _ViewLoaded();

  @override
  State<_ViewLoaded> createState() => _ViewLoadedState();
}

class _ViewLoadedState extends State<_ViewLoaded> {
  List<bool> _toggleState = [true, false];

  @override
  Widget build(BuildContext context) {
    final FormBuilderController controller = context.read<FormBuilderController>();
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            // TODO indicate this will wipe out all existing responses (and then wipe them out)
            onTap: () => controller.save(),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.save,
                  size: 32,
                )),
          ),
          const SizedBox(height: 12),
          ToggleButtons(
            direction: Axis.horizontal,
            onPressed: (int index) {
              setState(() {
                _toggleState = [index == 0, index == 1];
              });
              context.read<FormBuilderController>().editing = index == 0;
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            isSelected: _toggleState,
            children: const [
              Icon(Icons.edit),
              Icon(Icons.preview),
            ],
          ),
        ],
      ),
      body: const FormBuilder(),
    );
  }
}
