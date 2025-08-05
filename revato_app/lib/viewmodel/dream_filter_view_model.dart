import 'package:flutter/material.dart';
import 'package:revato_app/services/business/category_business_service.dart';
import 'package:revato_app/services/business/tag_business_service.dart';
import 'package:revato_app/model/tag_model.dart';
import 'package:revato_app/model/dream_model.dart';

class DreamFilterViewModel extends ChangeNotifier {
  // **INJECTION DE DÉPENDANCE**
  final TagBusinessService _tagBusinessService;
  final CategoryBusinessService _categoryBusinessService;

  /// **CONSTRUCTEUR AVEC INJECTION DE DÉPENDANCE**
  /// Permet une meilleure testabilité et découplage
  DreamFilterViewModel({
    CategoryBusinessService? categoryBusinessService,
    TagBusinessService? tagBusinessService,
  }) : _categoryBusinessService =
           categoryBusinessService ?? CategoryBusinessService(),
       _tagBusinessService = tagBusinessService ?? TagBusinessService() {
    _initializeAsync();
  }

  /// **INITIALISATION ASYNCHRONE**
  /// Sépare la construction de l'initialisation async
  Future<void> _initializeAsync() async {
    await loadTagCategories();
  }

  // **ÉTAT PRIVÉ - ENCAPSULATION MVVM**

  // Recherche
  String _searchText = '';

  // Filtrage par tags
  List<String> _selectedTags = [];

  // Catégories de tags
  List<TagCategory> _availableTagCategories = [];
  Map<String, List<String>> _tagsByCategory = {};
  bool _isLoadingCategories = false;

  // Tri
  bool _isSortedByDate = true;

  // **GETTERS PUBLICS - EXPOSITION POUR LA VIEW**

  String get searchText => _searchText;
  List<String> get selectedTags =>
      List.unmodifiable(_selectedTags); // Immutable pour la View
  List<TagCategory> get availableTagCategories =>
      List.unmodifiable(_availableTagCategories);
  Map<String, List<String>> get tagsByCategory =>
      Map.unmodifiable(_tagsByCategory);
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isSortedByDate => _isSortedByDate;

  // **PROPRIÉTÉS CALCULÉES - LOGIQUE DE PRÉSENTATION**
  bool get hasActiveFilters =>
      _selectedTags.isNotEmpty ||
      _filterEndDate != null ||
      _filterStartDate != null;

  bool get hasActiveFiltersIncludingSearch =>
      _selectedTags.isNotEmpty || _searchText.isNotEmpty;

  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  /// **CHARGEMENT DES CATÉGORIES DE TAGS**
  /// Récupère toutes les catégories disponibles depuis le service
  Future<void> loadTagCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _availableTagCategories = await _categoryBusinessService
          .getAllTagCategories(orderBy: 'name');

      // Charger les tags pour chaque catégorie
      for (final category in _availableTagCategories) {
        final tags = await _tagBusinessService.getTagsForCategory(
          category.name,
        );
        _tagsByCategory[category.name] = tags;
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des catégories: $e');
      _availableTagCategories = [];
      _tagsByCategory = {};
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

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

  /// **VÉRIFICATION SI UN TAG EST SÉLECTIONNÉ**
  bool isTagSelected(String tagName) {
    return _selectedTags.contains(tagName);
  }

  /// **MÉTHODE POUR GÉRER LE TRI PAR DATE**
  void toggleSortByDate(bool value) {
    _isSortedByDate = value;
    notifyListeners();
  }

  /// **MÉTHODE POUR RÉINITIALISER TOUS LES FILTRES**
  void clearFilters() {
    _searchText = '';
    _selectedTags.clear();
    notifyListeners();
  }

  /// **MÉTHODE POUR RÉINITIALISER TOUS LES DATES**
  void clearDates() {
    _filterStartDate = null;
    _filterEndDate = null;
    notifyListeners();
  }

  /// **MÉTHODE POUR RÉINITIALISER TOUS LES FILTRES ET ÉTATS**
  void clearAll() {
    clearFilters();
    clearDates();
    _isSortedByDate = true;
    notifyListeners();
  }

  /// **RÉCUPÉRATION DES TAGS POUR UNE CATÉGORIE**
  List<String> getTagsForCategory(String categoryName) {
    return _tagsByCategory[categoryName] ?? [];
  }

  /// **RÉCUPÉRATION DU NOMBRE DE TAGS SÉLECTIONNÉS POUR UNE CATÉGORIE**
  int getSelectedTagsCountForCategory(String categoryName) {
    final tagsInCategory = getTagsForCategory(categoryName);
    return tagsInCategory.where((tag) => _selectedTags.contains(tag)).length;
  }

  /// **FILTRAGE DES RÊVES SELON LES CRITÈRES SÉLECTIONNÉS**
  /// Applique tous les filtres actifs (recherche + tags + dates)
  List<Dream> filterDreams(List<Dream> dreams) {
    var filteredDreams = dreams;

    // Filtrage par texte de recherche (titre)
    if (_searchText.isNotEmpty) {
      filteredDreams =
          filteredDreams
              .where(
                (dream) => dream.title.toLowerCase().contains(
                  _searchText.toLowerCase(),
                ),
              )
              .toList();
    }

    // Filtrage par tags sélectionnés
    if (_selectedTags.isNotEmpty) {
      filteredDreams =
          filteredDreams.where((dream) {
            // Vérifier si le rêve contient au moins un des tags sélectionnés
            final hasMatchingTag = _selectedTags.any((selectedTag) {
              final foundTag = dream.tags.any((dreamTag) {
                final match = dreamTag.name == selectedTag;
                return match;
              });
              return foundTag;
            });

            return hasMatchingTag;
          }).toList();
    }

    if (_filterStartDate != null || _filterEndDate != null) {
      filteredDreams =
          filteredDreams.where((dream) {
            final createdAt = dream.createdAt;
            final isAfterStart =
                _filterStartDate == null ||
                createdAt.isAfter(_filterStartDate!);
            final isBeforeEnd =
                _filterEndDate == null || createdAt.isBefore(_filterEndDate!);

            return isAfterStart && isBeforeEnd;
          }).toList();
    }

    filteredDreams.sort(
      (a, b) =>
          isSortedByDate
              ? b.createdAt.compareTo(a.createdAt)
              : a.createdAt.compareTo(b.createdAt),
    );
    return filteredDreams;
  }

  void setFilterPeriod(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    notifyListeners();
  }
}
