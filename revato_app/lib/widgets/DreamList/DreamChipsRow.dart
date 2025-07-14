import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';

class DreamChipsRow extends StatelessWidget {
  final Dream dream;

  const DreamChipsRow(this.dream, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [];

    // Ajouter les tags -- mettre des couleurs par rapport a leur catégorie
    for (final tag in dream.tags) {
      if (tag.name.isNotEmpty) {
        chips.add(
          Chip(
            label: Text(
              tag.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7C3AED),
              ),
            ),
            backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
            side: BorderSide(
              color: const Color(0xFF7C3AED).withOpacity(0.3),
              width: 0.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }
    }
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(spacing: 6, runSpacing: 4, children: chips),
    );
  }
}
