class EmailFormField {
  EmailFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.slots,
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final int? slots;

  @override
  String toString() {
    return 'EmailFormField[key=$key, title=$title, bodyMarkdown=$bodyMarkdown, '
        'required=$required, slots=$slots]';
  }
}
