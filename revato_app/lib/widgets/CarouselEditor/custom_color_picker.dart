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
    '#121212', // noir
    '#1E1E1E', // gris très foncé
    '#F5F5F5', // blanc cassé
    '#B0B0B0', // gris clair
    '#FFD54F', // Jaune principal
    '#FFC107', // Jaune accent
    '#7C3AED', // Violet profond
    '#4DB6AC', // Turquoise
    '#81C784', // Vert clair
    '#F06292', // Rose
    '#FF5722', // Orange profond
    '#3F51B5', // Indigo profond
    '#64B5F6', // Bleu clair
    '#9575CD', // Violet moyen
    '#E57373', // Rouge clair
    '#607D8B', // Bleu gris
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Couleur:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        // Bouton sélecteur de couleur personnalisé
        ElevatedButton.icon(
          onPressed: _showCustomColorPicker,
          icon: const Icon(Icons.palette, size: 16),
          label: const Text('Personnaliser'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        const SizedBox(height: 16),
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
          'Couleurs prédéfinies:',
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

  /// **AFFICHAGE DU SÉLECTEUR DE COULEUR PERSONNALISÉ**
  void _showCustomColorPicker() {
    showDialog(
      context: context,
      builder:
          (context) => _CustomColorPickerDialog(
            initialColor: currentColor,
            onColorSelected: (color) {
              final hexColor =
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
              _selectColor(hexColor);
            },
          ),
    );
  }
}

/// **DIALOG SÉLECTEUR DE COULEUR PERSONNALISÉ**
class _CustomColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorSelected;

  const _CustomColorPickerDialog({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<_CustomColorPickerDialog> {
  late Color selectedColor;
  late double hue;
  late double saturation;
  late double lightness;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    final hslColor = HSLColor.fromColor(selectedColor);
    hue = hslColor.hue;
    saturation = hslColor.saturation;
    lightness = hslColor.lightness;
  }

  void _updateColor() {
    setState(() {
      selectedColor =
          HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choisir une couleur'),
      content: SizedBox(
        width: 300,
        height: 350,
        child: Column(
          children: [
            // Aperçu de la couleur sélectionnée
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Curseur de teinte (Hue)
            _buildSlider(
              label: 'Teinte',
              value: hue,
              max: 360,
              onChanged: (value) {
                hue = value;
                _updateColor();
              },
              gradient: LinearGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                  Colors.red,
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Curseur de saturation
            _buildSlider(
              label: 'Saturation',
              value: saturation,
              max: 1.0,
              onChanged: (value) {
                saturation = value;
                _updateColor();
              },
              gradient: LinearGradient(
                colors: [
                  HSLColor.fromAHSL(1.0, hue, 0.0, lightness).toColor(),
                  HSLColor.fromAHSL(1.0, hue, 1.0, lightness).toColor(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Curseur de luminosité
            _buildSlider(
              label: 'Luminosité',
              value: lightness,
              max: 1.0,
              onChanged: (value) {
                lightness = value;
                _updateColor();
              },
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  HSLColor.fromAHSL(1.0, hue, saturation, 0.5).toColor(),
                  Colors.white,
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(selectedColor);
            Navigator.pop(context);
          },
          child: const Text('Choisir'),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required Function(double) onChanged,
    required Gradient gradient,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${(value / max * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          height: 30,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 30,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
            ),
            child: Slider(value: value, max: max, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}
