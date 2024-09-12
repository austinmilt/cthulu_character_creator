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
}
