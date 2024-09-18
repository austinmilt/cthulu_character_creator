import 'package:cthulu_character_creator/model/form_data.dart';
import 'package:cthulu_character_creator/views/response/response_view.dart';
import 'package:cthulu_character_creator/views/responses/responses_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ResponsesView extends StatelessWidget {
  const ResponsesView({
    super.key,
    required this.gameId,
    required this.auth,
  });

  final String gameId;
  final String auth;

  static final GoRoute route = GoRoute(
    name: 'view-submissions',
    path: '/:gameId/responses',
    builder: (context, state) {
      final String? gameId = state.pathParameters['gameId'];
      final String? auth = state.uri.queryParameters['s'];
      if (gameId == null) {
        throw StateError('Tried to navigate to submissions view without a game ID');
      }
      if (auth == null) {
        throw StateError("Not authorized to view this.");
      }
      return ResponsesView(gameId: gameId, auth: auth);
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
    return Scaffold(
      body: FutureBuilder(
        future: context.read<ResponsesController>().load(gameId, auth),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _Submissions();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _Submissions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ResponsesController controller = context.watch<ResponsesController>();
    final List<FormResponseSummary> summaries = controller.summaries;
    return _TopCenterContainer(
      maxWidth: 600,
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: summaries.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(summaries[index].id),
          onTap: () => ResponseView.navigate(
            context,
            controller.gameId,
            summaries[index].id,
            null,
          ),
        ),
      ),
    );
  }
}

class _TopCenterContainer extends StatelessWidget {
  const _TopCenterContainer({this.child, this.maxWidth, this.padding});

  final Widget? child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
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
    );
  }
}
