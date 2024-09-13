class InformationFormField {
  InformationFormField({required this.title, required this.bodyMarkdown});

  final String? title;
  final String? bodyMarkdown;

  @override
  String toString() {
    return 'InformationFormField[title=$title, bodyMarkdown=$bodyMarkdown]';
  }
}
