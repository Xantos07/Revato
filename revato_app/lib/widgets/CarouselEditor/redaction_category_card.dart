import 'package:flutter/material.dart';
import 'package:revato_app/widgets/CarouselEditor/edit_redaction_category_dialog.dart';
import '../../viewmodel/carousel_editor_view_model.dart';
import '../../model/redaction_model.dart';

/// **CARTE DE CATÉGORIE RÉDACTION**
class RedactionCategoryCard extends StatelessWidget {
  final RedactionCategory category;
  final int index;
  final CarouselEditorViewModel viewModel;

  const RedactionCategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(category.displayName),
        subtitle: Text(category.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle visibility
            Switch(
              value: category.isDisplay,
              onChanged:
                  category.id != null
                      ? (value) =>
                          viewModel.toggleRedactionDisplay(category.id!, value)
                      : null,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => EditRedactionCategoryDialog(
            category: category,
            viewModel: viewModel,
          ),
    );
  }
}
