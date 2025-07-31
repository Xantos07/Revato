import 'package:flutter/material.dart';
import '../../viewmodel/carousel_editor_view_model.dart';
import 'redaction_category_card.dart';
import 'tag_category_card.dart';
import 'add_redaction_dialog.dart';
import 'add_tag_dialog.dart';

/// **ONGLET RÉDACTIONS**
class RedactionTabView extends StatelessWidget {
  final CarouselEditorViewModel viewModel;

  const RedactionTabView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouton d'ajout
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddRedactionDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une étape de rédaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),

        // Liste réorganisable
        Expanded(
          child: ReorderableListView.builder(
            itemCount: viewModel.redactionCategories.length,
            onReorder: viewModel.reorderRedactionCategories,
            itemBuilder: (context, index) {
              final category = viewModel.redactionCategories[index];
              return RedactionCategoryCard(
                key: ValueKey(category.id),
                category: category,
                index: index,
                viewModel: viewModel,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddRedactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddRedactionDialog(viewModel: viewModel),
    );
  }
}

/// **ONGLET TAGS**
class TagTabView extends StatelessWidget {
  final CarouselEditorViewModel viewModel;

  const TagTabView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bouton d'ajout
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _showAddTagDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une catégorie de tag'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),

        // Liste réorganisable
        Expanded(
          child: ReorderableListView.builder(
            itemCount: viewModel.tagCategories.length,
            onReorder: viewModel.reorderTagCategories,
            itemBuilder: (context, index) {
              final category = viewModel.tagCategories[index];
              return TagCategoryCard(
                key: ValueKey(category.id),
                category: category,
                index: index,
                viewModel: viewModel,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTagDialog(viewModel: viewModel),
    );
  }
}
