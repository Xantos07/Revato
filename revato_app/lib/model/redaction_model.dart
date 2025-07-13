class RedactionCategory {
  final String name;
  final String description;

  RedactionCategory({required this.name, required this.description});

  @override
  String toString() {
    return 'RedactionCategory{name: $name, description: $description}';
  }
}
