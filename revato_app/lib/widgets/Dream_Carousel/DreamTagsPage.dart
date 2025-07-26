import 'package:flutter/material.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamPageBase.dart';
import 'dream_tags_input_field_with_editing.dart';

/// Page d'édition des tags pour le carousel de rêves
/// Responsabilité : Affichage et navigation uniquement
class DreamTagsPage extends StatefulWidget {
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
  State<DreamTagsPage> createState() => _DreamTagsPageState();
}

class _DreamTagsPageState extends State<DreamTagsPage> {
  @override
  Widget build(BuildContext context) {
    return DreamPageBase(
      title: widget.title,
      small: true,
      child: DreamTagsInputFieldWithEditing(
        label: widget.label,
        tags: widget.tags,
        onChanged: widget.onChanged,
        chipColor: widget.chipColor,
        chipTextColor: widget.chipTextColor,
        addButtonColor: widget.addButtonColor,
        existingTags: widget.existingTags,
      ),
    );
  }
}
