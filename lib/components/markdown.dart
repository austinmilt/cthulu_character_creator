import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FieldMarkdown extends StatelessWidget {
  const FieldMarkdown({super.key, this.title, this.bodyMd});

  final String? title;
  final String? bodyMd;

  @override
  Widget build(BuildContext context) {
    final String? src = _combineElements(title, bodyMd);
    return src == null
        ? const SizedBox()
        : MarkdownBody(
            data: src,
            styleSheet: mdStyle,
          );
  }
}

String? _combineElements(String? title, String? bodyMd) {
  String? mdString;
  if (title != null) {
    if (bodyMd != null) {
      mdString = "## $title\n$bodyMd";
    } else {
      mdString = "## $title";
    }
  } else if (bodyMd != null) {
    mdString = bodyMd;
  }
  return mdString;
}

MarkdownStyleSheet mdStyle = MarkdownStyleSheet(
  h1: const TextStyle(fontSize: 32),
  p: const TextStyle(fontSize: 16),
  blockSpacing: 20,
);
