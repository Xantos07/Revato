import 'package:flutter/material.dart';

// ================================
// COMPOSANT DE SUGGESTIONS D'AUTOCOMPLÉTION
// ================================

/// Widget qui affiche les suggestions d'autocomplétion
class TagSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final Color chipColor;

  const TagSuggestionsWidget({
    required this.suggestions,
    required this.onSuggestionTap,
    required this.chipColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            suggestions
                .map((suggestion) => _buildSuggestionItem(context, suggestion))
                .toList(),
      ),
    );
  }

  /// Construit un élément de suggestion
  Widget _buildSuggestionItem(BuildContext context, String suggestion) {
    return InkWell(
      onTap: () => onSuggestionTap(suggestion),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border:
              suggestions.last != suggestion
                  ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  )
                  : null,
        ),
        child: Row(
          children: [
            Icon(Icons.history, size: 16, color: chipColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.north_west,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
