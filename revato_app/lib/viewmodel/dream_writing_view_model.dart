import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';
import 'package:revato_app/services/dream_service.dart';
import 'package:revato_app/services/dream_writing_service.dart';
import 'package:revato_app/services/tag_service.dart';
import 'package:revato_app/services/carousel_editor_service.dart';

class DreamWritingViewModel extends ChangeNotifier {
  final DreamService _dreamService;
  final TagService _tagService;
  final DreamWritingService _dreamWritingService;
  final CarouselEditorService _carouselEditorService;

  /// **CONSTRUCTEUR AVEC INJECTION DE DÉPENDANCE**
  DreamWritingViewModel({
    DreamService? dreamService,
    TagService? tagService,
    CarouselEditorService? carouselEditorService,
    DreamWritingService? dreamWritingService,
  }) : _dreamService = dreamService ?? DreamService(),
       _tagService = tagService ?? TagService(),
       _carouselEditorService =
           carouselEditorService ?? CarouselEditorService(),
       _dreamWritingService = dreamWritingService ?? DreamWritingService() {
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
      // Utilise le CarouselEditorService pour récupérer seulement les catégories visibles
      _availableCategories =
          await _carouselEditorService.getVisibleTagCategories();
      _availableCategoriesRedaction =
          await _carouselEditorService.getVisibleRedactionCategories();

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
    return _dreamService.insertDreamWithData(data);
  }

  /// **RÉCUPÉRATION DES TAGS** pour une catégorie spécifique
  /// Méthode asynchrone qui interroge la base de données
  Future<List<String>> getTagsForCategory(String categoryName) {
    return _tagService.getTagsForCategory(categoryName);
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
      final dream = await _dreamService.getDreamWithTagsAndRedactions(dreamId);
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
    final validTags = _dreamWritingService.filterValidTags(tags);
    _tagsByCategory[category] = validTags;
    notifyListeners();
  }

  ///

  Map<String, dynamic> collectData() {
    return _dreamWritingService.formatDreamData(
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
    final state = _dreamWritingService.mapDreamToEditingState(
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
      final success = await _tagService.renameTagGlobally(oldName, newName);
      if (success) {
        _dreamWritingService.addTagLocally(_tagsByCategory, oldName, newName);
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
      return await _tagService.getAllAvailableTags();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tags: $e');
      return [];
    }
  }
}
