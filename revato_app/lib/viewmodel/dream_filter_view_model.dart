import 'package:flutter/material.dart';
import 'package:revato_app/services/dream_service.dart';
import 'package:revato_app/model/tag_model.dart';
import 'package:revato_app/model/dream_model.dart';

/// **VIEW MODEL POUR LE FILTRAGE DES RÊVES**
///
/// RESPONSABILITÉS (pattern MVVM) :
/// - Gère l'état des filtres et recherche (Model → View)
/// - Expose les données formatées pour l'UI (View binding)
/// - Coordonne les services mais ne contient pas de logique métier
/// - Notifie les changements d'état à la View via ChangeNotifier

class DreamFilterViewModel extends ChangeNotifier {
  // **INJECTION DE DÉPENDANCE**
  final DreamService _dreamService;

  /// **CONSTRUCTEUR AVEC INJECTION DE DÉPENDANCE**
  /// Permet une meilleure testabilité et découplage
  DreamFilterViewModel({DreamService? dreamService})
    : _dreamService = dreamService ?? DreamService() {
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
      _availableTagCategories = await _dreamService.getAllTagCategories();

      // Charger les tags pour chaque catégorie
      for (final category in _availableTagCategories) {
        final tags = await _dreamService.getTagsForCategory(category.name);
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
    debugPrint('=== TOGGLE TAG FILTER ===');
    debugPrint('Tag à basculer: "$tagName"');
    debugPrint('Tags avant: $_selectedTags');

    if (_selectedTags.contains(tagName)) {
      _selectedTags.remove(tagName);
      debugPrint('Tag retiré');
    } else {
      _selectedTags.add(tagName);
      debugPrint('Tag ajouté');
    }

    debugPrint('Tags après: $_selectedTags');
    debugPrint('========================');
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

    debugPrint('=== DÉBUT FILTRAGE ===');
    debugPrint('Nombre de rêves total: ${dreams.length}');
    debugPrint('Texte de recherche: "$_searchText"');
    debugPrint('Tags sélectionnés: $_selectedTags');
    debugPrint('Date de début: ${_filterStartDate?.toString()}');
    debugPrint('Date de fin: ${_filterEndDate?.toString()}');

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
      debugPrint('Après filtrage texte: ${filteredDreams.length} rêves');
    }

    // Filtrage par tags sélectionnés
    if (_selectedTags.isNotEmpty) {
      debugPrint('--- DÉBUT FILTRAGE PAR TAGS ---');
      filteredDreams =
          filteredDreams.where((dream) {
            // Debug: affichage des tags du rêve
            final dreamTagNames = dream.tags.map((tag) => tag.name).toList();
            debugPrint('Rêve "${dream.title}" a les tags: $dreamTagNames');
            debugPrint('Tags recherchés: $_selectedTags');

            // Vérifier si le rêve contient au moins un des tags sélectionnés
            final hasMatchingTag = _selectedTags.any((selectedTag) {
              final foundTag = dream.tags.any((dreamTag) {
                final match = dreamTag.name == selectedTag;
                debugPrint(
                  'Comparaison: "${dreamTag.name}" == "$selectedTag" = $match',
                );
                return match;
              });
              return foundTag;
            });

            debugPrint(
              'Rêve "${dream.title}" correspond aux filtres: $hasMatchingTag',
            );
            debugPrint('---');
            return hasMatchingTag;
          }).toList();
      debugPrint('--- FIN FILTRAGE PAR TAGS ---');
      debugPrint('Après filtrage tags: ${filteredDreams.length} rêves');
    }

    if (_filterStartDate != null || _filterEndDate != null) {
      debugPrint('--- DÉBUT FILTRAGE PAR DATE ---');
      filteredDreams =
          filteredDreams.where((dream) {
            final createdAt = dream.createdAt;
            final isAfterStart =
                _filterStartDate == null ||
                createdAt.isAfter(_filterStartDate!);
            final isBeforeEnd =
                _filterEndDate == null || createdAt.isBefore(_filterEndDate!);

            debugPrint(
              'Rêve "${dream.title}" - Date: $createdAt, '
              'Après début: $isAfterStart, Avant fin: $isBeforeEnd',
            );

            return isAfterStart && isBeforeEnd;
          }).toList();
      debugPrint('--- FIN FILTRAGE PAR DATE ---');
      debugPrint('Après filtrage date: ${filteredDreams.length} rêves');
    }

    debugPrint('=== FIN FILTRAGE ===');

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
