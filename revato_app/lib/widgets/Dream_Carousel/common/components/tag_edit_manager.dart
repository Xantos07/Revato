import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../viewmodel/dream_writing_view_model.dart';

// ================================
// GESTIONNAIRE D'ÉDITION DE TAGS
// ================================

/// Classe qui gère l'édition des tags (locale et globale)
class TagEditManager {
  final BuildContext context;

  TagEditManager(this.context);

  /// Affiche la boîte de dialogue pour choisir le type d'édition
  Future<void> handleTagEdit({
    required String tag,
    required List<String> currentTags,
    required Function(List<String>) onTagsChanged,
    required Function(String) onEditTag,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Modifier le tag',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Color(0xFF7C3AED),
            ),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Que voulez-vous faire avec le tag "$tag" ?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Édition locale : modifie seulement ce rêve\n'
                'Édition globale : modifie tous les rêves utilisant ce tag',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('local'),
              child: const Text('Édition locale'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('global'),
              child: const Text('Édition globale'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    switch (result) {
      case 'local':
        _handleLocalEdit(tag, currentTags, onTagsChanged, onEditTag);
        break;
      case 'global':
        await _handleGlobalEdit(tag, currentTags, onTagsChanged);
        break;
    }
  }

  /// Édition locale : juste remplir le champ et supprimer de la liste
  void _handleLocalEdit(
    String tag,
    List<String> currentTags,
    Function(List<String>) onTagsChanged,
    Function(String) onEditTag,
  ) {
    onEditTag(tag);
    final updatedTags = currentTags.where((t) => t != tag).toList();
    onTagsChanged(updatedTags);
  }

  /// Édition globale : renommer dans tous les rêves
  Future<void> _handleGlobalEdit(
    String oldTag,
    List<String> currentTags,
    Function(List<String>) onTagsChanged,
  ) async {
    final controller = TextEditingController(text: oldTag);

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Renommer le tag globalement'),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Renommer "$oldTag" dans tous les rêves :'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nouveau nom du tag',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed:
                  () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Renommer'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && result != oldTag) {
      await _performGlobalRename(oldTag, result, currentTags, onTagsChanged);
    }
  }

  /// Effectue le renommage global via le ViewModel
  Future<void> _performGlobalRename(
    String oldTag,
    String newTag,
    List<String> currentTags,
    Function(List<String>) onTagsChanged,
  ) async {
    final viewModel = Provider.of<DreamWritingViewModel>(
      context,
      listen: false,
    );
    final success = await viewModel.renameTagGlobally(oldTag, newTag);

    if (success) {
      // Mettre à jour la liste locale
      final updatedTags =
          currentTags.map((tag) => tag == oldTag ? newTag : tag).toList();
      onTagsChanged(updatedTags);

      // Afficher un message de succès
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tag "$oldTag" renommé en "$newTag" dans tous les rêves',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Afficher un message d'erreur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du renommage du tag'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
