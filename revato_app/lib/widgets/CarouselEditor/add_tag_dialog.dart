import 'package:flutter/material.dart';
import 'package:revato_app/services/utils/text_cleaning_service.dart';
import '../../viewmodel/carousel_editor_view_model.dart';
import 'custom_color_picker.dart';

/// **DIALOG D'AJOUT DE TAG**
class AddTagDialog extends StatefulWidget {
  final CarouselEditorViewModel viewModel;

  const AddTagDialog({super.key, required this.viewModel});

  @override
  State<AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<AddTagDialog> {
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#7C3AED';

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 16, left: 24, right: 8),
      title: SizedBox(
        height: 48,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(right: 50),
                child: Text(
                  'Ajouter une catégorie de tag',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).dialogTheme.titleTextStyle,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Annuler',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom affiché',
                  hintText: 'Thème du rêve',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Thème principal du rêve...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
                onChanged: (value) => setState(() {}),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Sélecteur de couleur personnalisé
              CustomColorPicker(
                initialColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isFormValid() ? _onAdd : null,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  bool _isFormValid() {
    return _displayNameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty;
  }

  void _onAdd() {
    final technicalName = TextCleaningService.generateTechnicalName(
      _displayNameController.text,
    );

    widget.viewModel.addTagCategory(
      name: technicalName,
      displayName: _displayNameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
    );
    Navigator.pop(context);
  }
}
