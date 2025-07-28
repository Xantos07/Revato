import 'package:flutter/material.dart';

// ================================
// COMPOSANT D'AFFICHAGE DES TAGS
// ================================

/// Widget qui affiche les tags sous forme de chips
/// Gère l'affichage, la suppression et l'édition optionnelle
class TagChipsWidget extends StatelessWidget {
  final List<String> tags;
  final Function(String) onRemoveTag;
  final Function(String)? onEditTag; // Optionnel
  final Color chipColor;
  final Color? chipTextColor;

  const TagChipsWidget({
    required this.tags,
    required this.onRemoveTag,
    required this.chipColor,
    this.onEditTag,
    this.chipTextColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags.map(_buildTagChip).toList(),
    );
  }

  /// Construit un chip de tag
  Widget _buildTagChip(String tag) {
    final chip = Chip(
      label: Text(tag, style: TextStyle(color: chipTextColor ?? Colors.white)),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => onRemoveTag(tag),
      backgroundColor: chipColor,
    );

    // Si l'édition est autorisée, wrap avec GestureDetector
    if (onEditTag != null) {
      return GestureDetector(onTap: () => onEditTag!(tag), child: chip);
    }

    return chip;
  }
}
