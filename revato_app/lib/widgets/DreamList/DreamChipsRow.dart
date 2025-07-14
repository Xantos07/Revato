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
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor:
                tag.color.isNotEmpty
                    ? Color(int.parse(tag.color.replaceFirst('#', '0xFF')))
                    : const Color(0xFF7C3AED), // Couleur par défaut si vide

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
