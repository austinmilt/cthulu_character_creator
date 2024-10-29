import 'package:cthulu_character_creator/views/builder/form_builder.dart';
import 'package:cthulu_character_creator/views/builder/form_builder_controller.dart';
import 'package:cthulu_character_creator/views/response/response_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

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

  void _onShare(BuildContext context) {
    final FormBuilderController controller = context.read<FormBuilderController>();
    showDialog(
      context: context,
      builder: (context) {
        return _CopyUrl(
          gameId: controller.gameId,
          editAuthSecret: controller.editAuthSecret,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FormBuilderController controller = context.read<FormBuilderController>();
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.save,
                      size: 28,
                    )),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => _onShare(context),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.share,
                    size: 28,
                  ),
                ),
              ),
            ],
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

class _CopyUrl extends StatelessWidget {
  const _CopyUrl({
    required this.gameId,
    this.editAuthSecret,
  });

  final String gameId;
  final String? editAuthSecret;

  bool _canShareEdit() {
    return (editAuthSecret != null);
  }

  String _editUrl(BuildContext context) {
    final String path = FormBuilderView.route.path.replaceFirst(":gameId", gameId);
    return "${_urlOrigin(context)}$path?s=$editAuthSecret";
  }

  bool _canShareResponse() {
    return true;
  }

  String _responseUrl(BuildContext context) {
    final String path = ResponseView.newRoute.path.replaceFirst(":gameId", gameId);
    return "${_urlOrigin(context)}$path";
  }

  String _urlOrigin(BuildContext context) {
    return "${html.window.location.origin}/#";
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
  }

  Widget _option(BuildContext context, String label, String url) {
    final String displayUrl = (url.length > 50) ? "...${url.substring(url.length - 50)}" : url;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(alignment: Alignment.centerLeft, child: Text(displayUrl)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _copyToClipboard(url),
            icon: const Icon(Icons.copy),
            label: Text(label),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Share"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_canShareResponse())
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _option(context, 'Respond', _responseUrl(context)),
            ),
          if (_canShareEdit())
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _option(context, 'Edit', _editUrl(context)),
            ),
        ],
      ),
    );
  }
}
