import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';

class DreamChipsRow extends StatelessWidget {
  final Dream dream;

  const DreamChipsRow(this.dream, {Key? key}) : super(key: key);

  Color _desaturate(Color color, [double amount = .4]) {
    final hsl = HSLColor.fromColor(color);
    final hslDesat = hsl.withSaturation(
      (hsl.saturation * (1 - amount)).clamp(0.0, 1.0),
    );
    return hslDesat.toColor();
  }

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
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? _desaturate(
                          Color(int.parse(tag.color.replaceFirst('#', '0xFF'))),
                          0.2,
                        )
                        : Color(int.parse(tag.color.replaceFirst('#', '0xFF'))))
                    : (Theme.of(context).brightness == Brightness.dark
                        ? _desaturate(const Color(0xFF7C3AED), 0.2)
                        : const Color(
                          0xFF7C3AED,
                        )), // Couleur par défaut si vide

            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide.none,
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
