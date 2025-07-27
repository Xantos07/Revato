// ================================
// GESTIONNAIRE D'AUTOCOMPLÉTION POUR TAGS
// ================================

/// Classe utilitaire pour gérer l'autocomplétion des tags
class TagAutocompleteManager {
  // État de l'autocomplétion
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  // Getters
  List<String> get suggestions => _suggestions;
  bool get showSuggestions => _showSuggestions;

  /// Met à jour les suggestions basées sur le texte saisi
  void updateSuggestions({
    required String text,
    required List<String> existingTags,
    required List<String> currentTags,
    required bool hasFocus,
  }) {
    final lowerText = text.toLowerCase();

    if (lowerText.isEmpty) {
      _suggestions = [];
      _showSuggestions = false;
      return;
    }

    final filteredSuggestions =
        existingTags
            .where(
              (tag) =>
                  tag.toLowerCase().contains(lowerText) &&
                  !currentTags.contains(tag),
            )
            .take(5)
            .toList();

    _suggestions = filteredSuggestions;
    _showSuggestions = filteredSuggestions.isNotEmpty && hasFocus;
  }

  /// Masque les suggestions
  void hideSuggestions() {
    _showSuggestions = false;
  }

  /// Efface les suggestions
  void clearSuggestions() {
    _suggestions = [];
    _showSuggestions = false;
  }
}
