import 'package:flutter/material.dart';
import 'package:revato_app/services/tag_service.dart';

/// **VIEW MODEL POUR LE FILTRAGE DES RÊVES**
/// Gère l'état des filtres et de la recherche dans la liste des rêves
class DreamFilterViewModel extends ChangeNotifier {
  // **PROPRIÉTÉS DE RECHERCHE**
  String _searchText = '';
  String get searchText => _searchText;

  // **PROPRIÉTÉS DE FILTRAGE**
  List<String> _selectedTags = [];
  List<String> get selectedTags => _selectedTags;

  get isSortedByDate => true;

  get hasActiveFilters => true;

  get availableTagCategories => null;

  /// **MÉTHODE POUR METTRE À JOUR LA RECHERCHE**
  void updateSearchText(String text) {
    _searchText = text;
    notifyListeners(); // Notifie les widgets qui écoutent
  }

  /// **MÉTHODE POUR AJOUTER/RETIRER UN TAG DE FILTRAGE**
  void toggleTagFilter(String tagName) {
    if (_selectedTags.contains(tagName)) {
      _selectedTags.remove(tagName);
    } else {
      _selectedTags.add(tagName);
    }
    notifyListeners();
  }

  /// **MÉTHODE POUR RÉINITIALISER TOUS LES FILTRES**
  void clearFilters() {
    _searchText = '';
    _selectedTags.clear();
    notifyListeners();
  }

  void toggleSortByDate(bool value) {}

  void clearAll() {}

  void toggleTagSelection(category, bool isSelected) {}
}
