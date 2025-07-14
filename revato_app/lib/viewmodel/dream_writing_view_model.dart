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
  // **CONTRÔLEURS D'INTERFACE**
  final TextEditingController titleController =
      TextEditingController(); // Titre du rêve

  // **ÉTATS DE L'APPLICATION**
  bool isLoading = true; // Indique si les données sont en cours de chargement
  int page = 0; // Index de la page courante dans le carousel

  // **DONNÉES TEMPORAIRES** (stockage pendant la saisie)
  Map<String, List<String>> tagsByCategory =
      {}; // Tags sélectionnés par catégorie
  Map<String, TextEditingController> noteControllers =
      {}; // Contrôleurs des champs de notes

  // **DONNÉES MÉTIER** (récupérées depuis la DB)
  List<TagCategory> _availableCategories = []; // Catégories de tags disponibles
  List<RedactionCategory> _availableCategoriesRedaction =
      []; // Catégories de rédactions

  // **GETTERS PUBLICS** (accès lecture seule pour l'UI)
  List<TagCategory> get availableCategories => _availableCategories;
  List<RedactionCategory> get availableCategoriesRedaction =>
      _availableCategoriesRedaction;

  /// **CONSTRUCTEUR** - Initialise automatiquement le ViewModel
  DreamWritingViewModel() {
    _init(); // Charge les données au démarrage
  }

  /// **INITIALISATION PRIVÉE**
  /// Charge les catégories depuis la base de données au démarrage
  Future<void> _init() async {
    // **1. DÉBUT DU CHARGEMENT**
    isLoading = true;
    notifyListeners(); // Notifie l'UI pour afficher un indicateur de chargement

    try {
      // **2. RÉCUPÉRATION DES DONNÉES DEPUIS LA DB**
      _availableCategories = await DreamService().getAllTagCategories();
      _availableCategoriesRedaction =
          await DreamService().getAllRedactionCategories();

      // **DEBUG** - Vérification des données chargées
      print(
        'Catégories chargées: ${_availableCategories.map((c) => c.name).toList()}',
      );
      print(
        'Catégories de rédaction chargées: ${_availableCategoriesRedaction.map((c) => c.name).toList()}',
      );
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }

    // **3. FIN DU CHARGEMENT**
    isLoading = false;
    notifyListeners(); // Notifie l'UI que les données sont prêtes
  }

  /// **RÉCUPÉRATION DES TAGS** pour une catégorie spécifique
  /// Méthode asynchrone qui interroge la base de données
  Future<List<String>> getTagsForCategory(String categoryName) {
    return DreamService().getTagsForCategory(categoryName);
  }

  /// **RÉCUPÉRATION DES TAGS LOCAUX** (stockés temporairement)
  /// Retourne les tags sélectionnés par l'utilisateur pour une catégorie
  List<String> getLocalTagsForCategory(String categoryName) {
    return tagsByCategory[categoryName] ?? [];
  }

  /// **RÉCUPÉRATION DES TAGS EXISTANTS** (à implémenter)
  /// Pour pré-remplir les sélections lors de l'édition d'un rêve existant
  List<String> getExistingTagsForCategory(String categoryName) {
    return []; // TODO: Récupérer depuis la DB lors de l'édition
  }

  /// **GESTIONNAIRE DE CONTRÔLEURS DE NOTES**
  /// Crée ou récupère le contrôleur de texte pour une catégorie de notes
  /// Pattern Lazy Loading : crée le contrôleur seulement quand nécessaire
  TextEditingController getNoteController(String category) {
    return noteControllers.putIfAbsent(category, () => TextEditingController());
  }

  /// **MISE À JOUR DES TAGS**
  /// Sauvegarde les tags sélectionnés pour une catégorie
  void setTagsForCategory(String category, List<String> tags) {
    tagsByCategory[category] = tags;
    notifyListeners(); // Notifie l'UI du changement
  }

  /// **MISE À JOUR DES NOTES**
  /// Sauvegarde le texte d'une note pour une catégorie
  void setNoteForCategory(String category, String note) {
    noteControllers[category]?.text = note;
    notifyListeners(); // Notifie l'UI du changement
  }

  /// **COLLECTE DES DONNÉES COMPLÈTES**
  /// Rassemble toutes les données saisies pour la sauvegarde
  /// Retourne un Map structuré pour le service de sauvegarde
  Map<String, dynamic> collectData() {
    final data = {
      'title': titleController.text.trim(), // Titre nettoyé
      // Toutes les notes par catégorie
      'redactionByCategory': noteControllers.map(
        (key, controller) => MapEntry(key, controller.text.trim()),
      ),
      // Tous les tags par catégorie
      'tagsByCategory': Map<String, List<String>>.from(tagsByCategory),
    };

    // **DEBUG - AFFICHAGE DES DONNÉES COLLECTÉES**
    print('=== DONNÉES COLLECTÉES POUR SAUVEGARDE ===');
    print('Titre: ${data['title']}');
    print('Tags par catégorie:');
    for (final entry
        in (data['tagsByCategory'] as Map<String, List<String>>).entries) {
      if (entry.value.isNotEmpty) {
        print(' - ${entry.key}: ${entry.value}');
      }
    }
    print('Rédactions par catégorie:');
    for (final entry
        in (data['redactionByCategory'] as Map<String, String>).entries) {
      if (entry.value.isNotEmpty) {
        print(' - ${entry.key}: ${entry.value}');
      }
    }
    print('==========================================');

    return data; // Données prêtes pour la sauvegarde
  }

  /// **NAVIGATION DANS LE CAROUSEL**
  /// Met à jour l'index de la page courante et notifie l'UI
  void setPage(int newPage) {
    page = newPage;
    notifyListeners(); // Déclenche la reconstruction des widgets
  }
}
