import 'package:flutter/material.dart';
import 'package:revato_app/widgets/CarouselEditor/edit_tag_category_dialog.dart';
import '../../viewmodel/carousel_editor_view_model.dart';
import '../../model/tag_model.dart';

/// **CARTE DE CATÉGORIE TAG**
class TagCategoryCard extends StatelessWidget {
  final TagCategory category;
  final int index;
  final CarouselEditorViewModel viewModel;

  const TagCategoryCard({
    super.key,
    required this.category,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        category.color != null
            ? Color(int.parse(category.color!.replaceFirst('#', '0xFF')))
            : Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Text(category.displayName ?? category.name),
        subtitle: Text(category.description ?? 'Pas de description'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Couleur
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 8),
            // Toggle visibility
            Switch(
              value: category.isDisplay,
              onChanged:
                  category.id != null
                      ? (value) =>
                          viewModel.toggleTagDisplay(category.id!, value)
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
          (context) =>
              EditTagCategoryDialog(category: category, viewModel: viewModel),
    );
  }
}
