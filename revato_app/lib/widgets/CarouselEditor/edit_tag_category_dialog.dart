import 'package:flutter/material.dart';
import '../../model/tag_model.dart';
import '../../viewmodel/carousel_editor_view_model.dart';
import 'custom_color_picker.dart';

/// **DIALOG D'ÉDITION DE CATÉGORIE TAG**
class EditTagCategoryDialog extends StatefulWidget {
  final TagCategory category;
  final CarouselEditorViewModel viewModel;

  const EditTagCategoryDialog({
    super.key,
    required this.category,
    required this.viewModel,
  });

  @override
  State<EditTagCategoryDialog> createState() => _EditTagCategoryDialogState();
}

class _EditTagCategoryDialogState extends State<EditTagCategoryDialog> {
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.category.displayName ?? widget.category.name,
    );
    _descriptionController = TextEditingController(
      text: widget.category.description ?? '',
    );
    _selectedColor = widget.category.color ?? '#7C3AED';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier la catégorie de tag'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Nom affiché
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom affiché',
                  hintText: 'Lieux du rêve',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Lieux et environnements du rêve...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Sélecteur de couleur
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }

  void _saveChanges() async {
    if (_displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom affiché est obligatoire')),
      );
      return;
    }

    try {
      // Créer une nouvelle instance de TagCategory avec les modifications
      final updatedCategory = TagCategory(
        id: widget.category.id,
        name: widget.category.name, // Le nom technique ne change pas
        displayName: _displayNameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
        isDisplay: widget.category.isDisplay,
        displayOrder: widget.category.displayOrder,
        createdAt: widget.category.createdAt,
      );

      // Sauvegarder via le ViewModel
      await widget.viewModel.updateTagCategory(updatedCategory);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catégorie modifiée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification: $e')),
        );
      }
    }
  }
}
