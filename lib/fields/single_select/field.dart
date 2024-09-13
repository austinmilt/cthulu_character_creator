class SingleSelectFormField {
  final String key;
  final String? title;
  final String? bodyMarkdown;
  final bool required;
  final int? slots;
  final List<String> options;

  SingleSelectFormField({
    required this.key,
    required this.title,
    required this.bodyMarkdown,
    required this.required,
    required this.slots,
    required this.options,
  });

  @override
  String toString() {
    return 'SingleSelectFormField[key=$key, title=$title, '
        'bodyMarkdown=$bodyMarkdown, required=$required, slots=$slots, '
        'options=$options]';
  }
}
