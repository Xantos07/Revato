import 'package:flutter/material.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';

Widget buildTagsTab(BuildContext context, DreamFilterViewModel vm) {
  if (vm.isLoadingCategories) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (vm.availableTagCategories.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tag, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune catégorie de tags disponible',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec compteur de tags sélectionnés
        if (vm.selectedTags.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${vm.selectedTags.length} tag(s) sélectionné(s)',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                TextButton(
                  onPressed: vm.clearFilters,
                  child: const Text('Effacer'),
                ),
              ],
            ),
          ),

        // Liste des catégories avec ExpansionTiles
        ...vm.availableTagCategories.map(
          (category) => _buildCategoryExpansionTile(context, vm, category),
        ),
      ],
    ),
  );
}

/// **CONSTRUCTION D'UNE CATÉGORIE AVEC LISTE DÉROULANTE**
Widget _buildCategoryExpansionTile(
  BuildContext context,
  DreamFilterViewModel vm,
  category,
) {
  final tags = vm.getTagsForCategory(category.name);
  final selectedCount = vm.getSelectedTagsCountForCategory(category.name);

  if (tags.isEmpty) {
    return const SizedBox.shrink();
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: ExpansionTile(
      title: Row(
        children: [
          // Icône de catégorie - punaise
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: category.getFlutterColor(), // Couleur depuis la DB
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.push_pin,
              color: category.getTextColor(), // Couleur de texte adaptative
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Nom de la catégorie - utilise displayName depuis la DB
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.displayName ?? category.name, // Nom depuis la DB
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (selectedCount > 0)
                  Text(
                    '$selectedCount sélectionné(s)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),

          // Badge avec nombre de tags
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${tags.length}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                tags.map((tag) => _buildTagChip(context, vm, tag)).toList(),
          ),
        ),
      ],
    ),
  );
}

/// **CONSTRUCTION D'UN CHIP DE TAG**
Widget _buildTagChip(
  BuildContext context,
  DreamFilterViewModel vm,
  String tag,
) {
  final isSelected = vm.isTagSelected(tag);

  return FilterChip(
    label: Text(tag),
    selected: isSelected,
    onSelected: (selected) => vm.toggleTagFilter(tag),
    backgroundColor: Theme.of(context).colorScheme.surface,
    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
    checkmarkColor: Theme.of(context).colorScheme.primary,
    labelStyle: TextStyle(
      color:
          isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
    ),
    side: BorderSide(
      color:
          isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
    ),
  );
}
