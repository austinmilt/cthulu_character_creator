import 'package:cthulu_character_creator/views/response/response_form.dart';
import 'package:cthulu_character_creator/views/response/response_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class ResponseView extends StatelessWidget {
  const ResponseView({
    super.key,
    required this.gameId,
    this.responseId,
    this.editAuthSecret,
  });

  final String gameId;
  final String? responseId;
  final String? editAuthSecret;

  static final GoRoute newRoute = GoRoute(
    name: 'respond-to-form',
    path: '/:gameId/form/respond',
    builder: (context, state) {
      final String? gameId = state.pathParameters['gameId'];
      if (gameId == null) {
        throw StateError('Tried to navigate to character creator without a game ID');
      }
      return ResponseView(gameId: gameId);
    },
  );

  static final GoRoute existingRoute = GoRoute(
    name: 'view-or-edit-response',
    path: '/:gameId/form/response/:responseId',
    builder: (context, state) {
      final String? gameId = state.pathParameters['gameId'];
      final String? responseId = state.pathParameters['responseId'];
      final String? editAuthSecret = state.uri.queryParameters['s'];
      if (gameId == null) {
        throw StateError('Tried to navigate to character creator without a game ID');
      }
      return ResponseView(
        gameId: gameId,
        responseId: responseId,
        editAuthSecret: editAuthSecret,
      );
    },
  );

  static void navigate(BuildContext context, String gameId, String? responseId, String? editAuthSecret) {
    final Map<String, String> pathParams = {};
    final Map<String, String> queryParams = {};
    pathParams['gameId'] = gameId;
    if (responseId != null) pathParams['responseId'] = responseId;
    if (editAuthSecret != null) queryParams['s'] = editAuthSecret;
    context.goNamed(existingRoute.name!, pathParameters: pathParams, queryParameters: queryParams);
  }

  /// Replaces the current route with this view's route without refreshing
  static void replaceRoute(BuildContext context, String gameId, String? responseId, String? editAuthSecret) {
    final Map<String, String> pathParams = {};
    final Map<String, String> queryParams = {};
    pathParams['gameId'] = gameId;
    if (responseId != null) pathParams['responseId'] = responseId;
    if (editAuthSecret != null) queryParams['s'] = editAuthSecret;
    context.replaceNamed(existingRoute.name!, pathParameters: pathParams, queryParameters: queryParams);
  }

  void _onShare(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _CopyUrl(
          gameId: gameId,
          responseId: responseId,
          editAuthSecret: editAuthSecret,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: () => _onShare(context),
        icon: const Icon(Icons.share),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: FutureBuilder(
        future: context.read<ResponseController>().load(gameId, responseId, editAuthSecret),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return const ResponseForm();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _CopyUrl extends StatelessWidget {
  const _CopyUrl({
    required this.gameId,
    this.responseId,
    this.editAuthSecret,
  });

  final String gameId;
  final String? responseId;
  final String? editAuthSecret;

  bool _canShareEdit() {
    return (responseId != null) && (editAuthSecret != null);
  }

  String _editUrl(BuildContext context) {
    final String path =
        ResponseView.existingRoute.path.replaceFirst(":gameId", gameId).replaceFirst(":responseId", responseId ?? "");
    return "${_urlOrigin(context)}$path?s=$editAuthSecret";
  }

  bool _canShareResponse() {
    return responseId != null;
  }

  String _responseUrl(BuildContext context) {
    final String path =
        ResponseView.existingRoute.path.replaceFirst(":gameId", gameId).replaceFirst(":responseId", responseId ?? "");
    return "${_urlOrigin(context)}$path";
  }

  String _formUrl(BuildContext context) {
    final String path = ResponseView.newRoute.path.replaceFirst(":gameId", gameId);
    return "${_urlOrigin(context)}$path";
  }

  String _urlOrigin(BuildContext context) {
    final String href = html.window.location.href;
    return href.substring(0, href.indexOf("#") + 1);
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
          _option(context, 'Form', _formUrl(context)),
          if (_canShareResponse())
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: _option(context, 'Response', _responseUrl(context)),
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
