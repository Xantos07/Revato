import 'package:flutter/material.dart';
import 'package:revato_app/services/utils/text_cleaning_service.dart';
import '../../viewmodel/carousel_editor_view_model.dart';

/// **DIALOG D'AJOUT DE RÉDACTION**
class AddRedactionDialog extends StatefulWidget {
  final CarouselEditorViewModel viewModel;

  const AddRedactionDialog({super.key, required this.viewModel});

  @override
  State<AddRedactionDialog> createState() => _AddRedactionDialogState();
}

class _AddRedactionDialogState extends State<AddRedactionDialog> {
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une étape de rédaction'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nom affiché
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom affiché',
                  hintText: 'Résumé du rêve',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              // Description
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Décrivez brièvement cette étape...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                onChanged: (value) => setState(() {}),
                maxLines: 2,
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

    widget.viewModel.addRedactionCategory(
      name: technicalName,
      displayName: _displayNameController.text.trim(),
      description:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text.trim(),
    );
    Navigator.pop(context);
  }
}
