// Imports nécessaires pour la gestion d'état et l'accès aux données
import 'package:flutter/foundation.dart'; // Pour ChangeNotifier
import 'package:flutter/material.dart'; // Pour TextEditingController
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';
import 'package:revato_app/services/dream_service.dart';

/// **VIEW MODEL - GESTIONNAIRE D'ÉTAT**
/// Pattern MVVM : sépare la logique métier de l'interface utilisateur
/// Responsable de :
/// - Gérer l'état de l'écran de saisie des rêves
/// - Coordonner les interactions entre l'UI et les services
/// - Stocker temporairement les données pendant la saisie
/// - Notifier l'UI des changements d'état (via ChangeNotifier)

class DreamWritingViewModel extends ChangeNotifier {
  // **INJECTION DE DÉPENDANCE** - Meilleure testabilité
  final DreamService _dreamService;

  /// **CONSTRUCTEUR AVEC INJECTION DE DÉPENDANCE**
  DreamWritingViewModel({DreamService? dreamService})
    : _dreamService = dreamService ?? DreamService() {
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

  /// **CONSTRUCTEUR** - Initialise automatiquement le ViewModel
  /// **INITIALISATION PRIVÉE**
  /// Charge les catégories depuis la base de données au démarrage
  Future<void> _loadCategories() async {
    // **1. DÉBUT DU CHARGEMENT**
    _isLoading = true;
    notifyListeners(); // Notifie l'UI pour afficher un indicateur de chargement

    try {
      // **2. RÉCUPÉRATION DES DONNÉES DEPUIS LA DB**
      _availableCategories = await _dreamService.getAllTagCategories();
      _availableCategoriesRedaction =
          await _dreamService.getAllRedactionCategories();

      // **DEBUG** - Vérification des données chargées
      debugPrint(
        'Catégories chargées: ${_availableCategories.map((c) => c.name).toList()}',
      );
      debugPrint(
        'Catégories de rédaction chargées: ${_availableCategoriesRedaction.map((c) => c.name).toList()}',
      );
    } catch (e) {
      debugPrint('Erreur lors du chargement des catégories: $e');
    }

    // **3. FIN DU CHARGEMENT**
    _isLoading = false;
    notifyListeners(); // Notifie l'UI que les données sont prêtes
  }

  /// **RÉCUPÉRATION DES TAGS** pour une catégorie spécifique
  /// Méthode asynchrone qui interroge la base de données
  Future<List<String>> getTagsForCategory(String categoryName) {
    return _dreamService.getTagsForCategory(categoryName);
  }

  /// **RÉCUPÉRATION DES TAGS LOCAUX** (stockés temporairement)
  /// Retourne les tags sélectionnés par l'utilisateur pour une catégorie
  List<String> getLocalTagsForCategory(String categoryName) {
    return _tagsByCategory[categoryName] ?? [];
  }

  /// **RÉCUPÉRATION DES TAGS EXISTANTS** (à implémenter)
  /// Pour pré-remplir les sélections lors de l'édition d'un rêve existant
  List<String> getExistingTagsForCategory(String categoryName) {
    return []; // TODO: Récupérer depuis la DB lors de l'édition
  }

  /// **RÉCUPÉRATION D'UNE NOTE** pour une catégorie
  String getNoteForCategory(String categoryName) {
    return _notesByCategory[categoryName] ?? '';
  }

  /// **MISE À JOUR DU TITRE**
  void updateTitle(String title) {
    _dreamTitle = title;
    notifyListeners();
  }

  /// **MISE À JOUR DES TAGS**
  /// Sauvegarde les tags sélectionnés pour une catégorie
  void setTagsForCategory(String category, List<String> tags) {
    _tagsByCategory[category] = tags;
    notifyListeners(); // Notifie l'UI du changement
  }

  /// **MISE À JOUR DES NOTES**
  /// Sauvegarde le texte d'une note pour une catégorie
  void setNoteForCategory(String category, String note) {
    _notesByCategory[category] = note;
    notifyListeners(); // Notifie l'UI du changement
  }

  /// **COLLECTE DES DONNÉES COMPLÈTES**
  /// Rassemble toutes les données saisies pour la sauvegarde
  /// Retourne un Map structuré pour le service de sauvegarde
  Map<String, dynamic> collectData() {
    final data = {
      'title': _dreamTitle.trim(), // Titre nettoyé
      // Toutes les notes par catégorie
      'redactionByCategory': Map<String, String>.from(_notesByCategory),
      // Tous les tags par catégorie
      'tagsByCategory': Map<String, List<String>>.from(_tagsByCategory),
    };

    // **DEBUG - AFFICHAGE DES DONNÉES COLLECTÉES**
    debugPrint('=== DONNÉES COLLECTÉES POUR SAUVEGARDE ===');
    debugPrint('Titre: ${data['title']}');
    debugPrint('Tags par catégorie:');
    for (final entry
        in (data['tagsByCategory'] as Map<String, List<String>>).entries) {
      if (entry.value.isNotEmpty) {
        debugPrint(' - ${entry.key}: ${entry.value}');
      }
    }
    debugPrint('Rédactions par catégorie:');
    for (final entry
        in (data['redactionByCategory'] as Map<String, String>).entries) {
      if (entry.value.isNotEmpty) {
        debugPrint(' - ${entry.key}: ${entry.value}');
      }
    }
    debugPrint('==========================================');

    return data; // Données prêtes pour la sauvegarde
  }

  /// **NAVIGATION DANS LE CAROUSEL**
  /// Met à jour l'index de la page courante et notifie l'UI
  void setPage(int newPage) {
    _currentPage = newPage;
    notifyListeners(); // Déclenche la reconstruction des widgets
  }
}
