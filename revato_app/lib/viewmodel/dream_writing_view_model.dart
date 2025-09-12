import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';
import 'package:revato_app/services/business/dream_business_service.dart';
import 'package:revato_app/services/business/tag_business_service.dart';
import 'package:revato_app/services/business/category_business_service.dart';
import 'package:revato_app/services/utils/save_tempory_carousel.dart';

class DreamWritingViewModel extends ChangeNotifier {
  final DreamBusinessService _dreamBusinessService;
  final TagBusinessService _tagBusinessService;
  final CategoryBusinessService _categoryBusinessService;

  /// **CONSTRUCTEUR AVEC INJECTION DE DÉPENDANCE**
  DreamWritingViewModel({
    DreamBusinessService? dreamService,
    TagBusinessService? tagBusinessService,
    CategoryBusinessService? categoryBusinessService,
  }) : _dreamBusinessService = dreamService ?? DreamBusinessService(),
       _tagBusinessService = tagBusinessService ?? TagBusinessService(),
       _categoryBusinessService =
           categoryBusinessService ?? CategoryBusinessService() {
    _initializeAsync();
  }

  /// **INITIALISATION ASYNCHRONE**
  Future<void> _initializeAsync() async {
    await _loadCategories();
  }

  // **ÉTAT PRIVÉ - PAS DE DÉPENDANCES UI**

  // État de l'application (MVVM compliant)
  bool _isLoading = true;
  int _currentPage = 0;

  // Données de saisie
  String _dreamTitle = '';
  Map<String, List<String>> _tagsByCategory = {};
  Map<String, String> _notesByCategory = {};

  // Données métier
  List<TagCategory> _availableCategories = [];
  List<RedactionCategory> _availableCategoriesRedaction = [];

  // **GETTERS PUBLICS - EXPOSITION POUR LA VIEW**

  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  String get dreamTitle => _dreamTitle;
  Map<String, List<String>> get tagsByCategory =>
      Map.unmodifiable(_tagsByCategory);
  Map<String, String> get notesByCategory => Map.unmodifiable(_notesByCategory);
  List<TagCategory> get availableCategories =>
      List.unmodifiable(_availableCategories);
  List<RedactionCategory> get availableCategoriesRedaction =>
      List.unmodifiable(_availableCategoriesRedaction);

  /// **CONSTRUCTEUR** - Initialise au
  /// **INITIALISATION PRIVÉE**
  /// Charge les catégories depuis la base de données au démarrage
  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners(); // Notifie l'UI pour afficher un indicateur de chargement

    try {
      // Utilise le CategoryBusinessService pour récupérer les catégories visibles
      final categoriesData =
          await _categoryBusinessService.getVisibleCategoriesForDisplay();

      _availableCategories =
          categoriesData['tagCategories'] as List<TagCategory>;
      _availableCategoriesRedaction =
          categoriesData['redactionCategories'] as List<RedactionCategory>;

      // **DEBUG** - Vérification des données chargées
      debugPrint(
        'Catégories visibles chargées: ${_availableCategories.map((c) => c.name).toList()}',
      );
      debugPrint(
        'Catégories de rédaction visibles chargées: ${_availableCategoriesRedaction.map((c) => c.name).toList()}',
      );
    } catch (e) {
      debugPrint('Erreur lors du chargement des catégories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> insertDreamWithData(Map<String, dynamic> data) {
    return _dreamBusinessService.createDream(data);
  }

  /// **RÉCUPÉRATION DES TAGS** pour une catégorie spécifique
  /// Méthode asynchrone qui interroge la base de données
  Future<List<String>> getTagsForCategory(String categoryName) {
    return _tagBusinessService.getTagsForCategory(categoryName);
  }

  /// **RÉCUPÉRATION DES TAGS LOCAUX** (stockés temporairement)
  /// Retourne les tags sélectionnés par l'utilisateur pour une catégorie
  List<String> getLocalTagsForCategory(String categoryName) {
    return _tagsByCategory[categoryName] ?? [];
  }

  /// **RÉCUPÉRATION D'UNE NOTE** pour une catégorie
  String getNoteForCategory(String categoryName) {
    return _notesByCategory[categoryName] ?? '';
  }

  void GetDreamWithId(int dreamId) async {
    try {
      final dream = await _dreamBusinessService.getDreamWithTagsAndRedactions(
        dreamId,
      );
      if (dream != null) {
        initializeWithDream(dream);
      } else {
        debugPrint('Aucun rêve trouvé avec l\'ID: $dreamId');
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération du rêve: $e');
    }
  }

  /// Partie Edit

  /// **MISE À JOUR DU TITRE**
  void updateTitle(String title) {
    _dreamTitle = title;
    notifyListeners();

    // Sauvegarde temporaire
    SaveTemporyCarousel.saveTempData(
      dreamTitle: _dreamTitle,
      tagsByCategory: _tagsByCategory,
      notesByCategory: _notesByCategory,
    );
  }

  /// **MISE À JOUR DES NOTES**
  /// Sauvegarde le texte d'une note pour une catégorie
  void setNoteForCategory(String category, String note) {
    _notesByCategory[category] = note;
    notifyListeners(); // Notifie l'UI du changement
  }

  /// **MISE À JOUR DES TAGS**
  /// Sauvegarde les tags sélectionnés pour une catégorie
  void setTagsForCategory(String category, List<String> tags) {
    final validTags = _dreamBusinessService.filterValidTags(tags);
    _tagsByCategory[category] = validTags;
    notifyListeners();
  }

  ///

  Map<String, dynamic> collectData() {
    return _dreamBusinessService.formatDreamData(
      _dreamTitle,
      _notesByCategory,
      _tagsByCategory,
    );
  }

  /// **NAVIGATION DANS LE CAROUSEL**
  /// Met à jour l'index de la page courante et notifie l'UI
  void setPage(int newPage) {
    _currentPage = newPage;
    notifyListeners(); // Déclenche la reconstruction des widgets
  }

  void initializeWithDream(Dream dream) {
    final state = _dreamBusinessService.mapDreamToEditingState(
      dream,
      _availableCategories,
      _availableCategoriesRedaction,
    );
    _dreamTitle = state['title'];
    _notesByCategory = state['redactionsByCategory'];
    _tagsByCategory = state['tagsByCategory'];
    notifyListeners();
  }

  /// ========================
  /// PARTIE TAG
  /// ========================

  /// Renomme un tag globalement dans tous les rêves
  Future<bool> renameTagGlobally(String oldName, String newName) async {
    try {
      final success = await TagBusinessService().renameTagGlobally(
        oldName,
        newName,
      );
      if (success) {
        _dreamBusinessService.addTagLocally(_tagsByCategory, oldName, newName);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Erreur lors du renommage global du tag: $e');
      return false;
    }
  }

  /// Met à jour les tags pour une catégorie donnée
  void updateTagsForCategory(String categoryName, List<String> newTags) {
    _tagsByCategory[categoryName] = newTags;
    notifyListeners();
  }

  /// Récupère tous les tags existants pour l'autocomplétion
  Future<List<String>> getAllAvailableTags() async {
    try {
      return await _tagBusinessService.getAllAvailableTags();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tags: $e');
      return [];
    }
  }
}
