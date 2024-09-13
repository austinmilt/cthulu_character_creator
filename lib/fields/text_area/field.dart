class TextAreaFormField {
  TextAreaFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.slots,
    required this.label,
    required this.help,
  });

  final String key;
  final String? title;
  final String? bodyMarkdown;
  final String? label;
  final String? help;
  final bool required;
  final int? slots;

  @override
  String toString() {
    return 'TextAreaFormField[key=$key, title=$title, '
        'bodyMarkdown=$bodyMarkdown, label=$label, help=$help, '
        'required=$required, slots=$slots]';
  }
}
