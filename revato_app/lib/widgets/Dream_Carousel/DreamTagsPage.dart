import 'package:flutter/material.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamFields.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamPageBase.dart';

class DreamTagsPage extends StatelessWidget {
  final String title;
  final String label;
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final Color chipColor;
  final Color? chipTextColor;
  final Color? addButtonColor;
  final List<String>? existingTags; // Tags existants pour l'autocomplétion
  const DreamTagsPage({
    required this.title,
    required this.label,
    required this.tags,
    required this.onChanged,
    required this.chipColor,
    this.chipTextColor,
    this.addButtonColor,
    this.existingTags,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return DreamPageBase(
      title: title,
      small: true,
      child: DreamTagsInputField(
        label: label,
        tags: tags,
        onChanged: onChanged,
        chipColor: chipColor,
        chipTextColor: chipTextColor,
        addButtonColor: addButtonColor,
        existingTags: existingTags,
      ),
    );
  }
}
