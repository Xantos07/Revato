import 'package:flutter/material.dart';

/// **SÉLECTEUR DE COULEUR PERSONNALISÉ**
class CustomColorPicker extends StatefulWidget {
  final String initialColor;
  final Function(String) onColorChanged;

  const CustomColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late String selectedColor;
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    currentColor = Color(int.parse(selectedColor.replaceFirst('#', '0xFF')));
  }

  /// **COULEURS PRÉDÉFINIES POPULAIRES**
  final List<String> predefinedColors = [
    '#E57373', // Rouge clair
    '#64B5F6', // Bleu clair
    '#81C784', // Vert clair
    '#BA68C8', // Violet clair
    '#FFD54F', // Jaune
    '#7C3AED', // Violet foncé
    '#FF8A65', // Orange
    '#4DB6AC', // Turquoise
    '#F06292', // Rose
    '#9575CD', // Violet moyen
    '#FF5722', // Rouge orangé
    '#795548', // Marron
    '#607D8B', // Bleu gris
    '#FFC107', // Ambre
    '#8BC34A', // Vert clair
    '#3F51B5', // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Couleur:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),

        // Couleur sélectionnée actuelle
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedColor.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Couleurs prédéfinies
        const Text(
          'Couleurs disponibles:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              predefinedColors.map((color) {
                final isSelected = selectedColor == color;
                return GestureDetector(
                  onTap: () => _selectColor(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  void _selectColor(String color) {
    setState(() {
      selectedColor = color;
      currentColor = Color(int.parse(color.replaceFirst('#', '0xFF')));
    });
    widget.onColorChanged(color);
  }
}
