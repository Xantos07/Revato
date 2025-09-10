import 'package:revato_app/services/data/category_repository.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';

/// Service contenant la logique métier des catégories (ex-CarouselEditorService)
class CategoryBusinessService {
  final CategoryRepository _categoryRepo;

  CategoryBusinessService({CategoryRepository? categoryRepo})
    : _categoryRepo = categoryRepo ?? CategoryRepository();

  /// **GESTION DES CATÉGORIES DE RÉDACTION**

  /// Bascule l'affichage d'une catégorie de rédaction
  Future<void> toggleRedactionCategoryDisplay(
    int categoryId,
    bool isDisplay,
  ) async {
    if (categoryId <= 0) {
      throw ArgumentError('ID de catégorie invalide: $categoryId');
    }

    try {
      await _categoryRepo.toggleRedactionCategoryDisplay(categoryId, isDisplay);
      print(
        'Catégorie rédaction $categoryId ${isDisplay ? 'affichée' : 'masquée'}',
      );
    } catch (e) {
      print(
        'Erreur lors du changement de visibilité de la catégorie $categoryId: $e',
      );
      rethrow;
    }
  }

  /// Réorganise l'ordre des catégories de rédaction
  Future<void> reorderRedactionCategories(List<int> categoryIds) async {
    if (categoryIds.isEmpty) {
      throw ArgumentError('La liste des IDs ne peut pas être vide');
    }

    try {
      await _categoryRepo.reorderRedactionCategories(categoryIds);
      print(
        'Ordre des catégories de rédaction mis à jour: ${categoryIds.length} éléments',
      );
    } catch (e) {
      print('Erreur lors de la réorganisation des catégories de rédaction: $e');
      rethrow;
    }
  }

  /// Met à jour une catégorie de rédaction avec validation
  Future<void> updateRedactionCategory(RedactionCategory category) async {
    // Validation métier
    if (category.name.trim().isEmpty) {
      throw ArgumentError('Le nom de la catégorie ne peut pas être vide');
    }
    if (category.displayName.trim().isEmpty) {
      throw ArgumentError('Le nom d\'affichage ne peut pas être vide');
    }

    try {
      await _categoryRepo.updateRedactionCategory(category);
      print('Catégorie de rédaction "${category.name}" mise à jour');
    } catch (e) {
      print('Erreur lors de la mise à jour de la catégorie: $e');
      rethrow;
    }
  }

  /// Met à jour une catégorie de rédaction avec validation
  Future<void> updateTagCategory(TagCategory category) async {
    // Validation métier
    if (category.name.trim().isEmpty) {
      throw ArgumentError('Le nom de la catégorie ne peut pas être vide');
    }
    if (category.displayName.trim().isEmpty) {
      throw ArgumentError('Le nom d\'affichage ne peut pas être vide');
    }

    try {
      await _categoryRepo.updateTagCategory(category);
      print('Catégorie de tag "${category.name}" mise à jour');
    } catch (e) {
      print('Erreur lors de la mise à jour de la catégorie: $e');
      rethrow;
    }
  }

  /// Ajoute une nouvelle catégorie de rédaction avec validation
  Future<int> addRedactionCategory({
    required String name,
    required String displayName,
    String? description,
  }) async {
    // Validation métier
    if (name.trim().isEmpty) {
      throw ArgumentError('Le nom technique ne peut pas être vide');
    }
    if (displayName.trim().isEmpty) {
      throw ArgumentError('Le nom d\'affichage ne peut pas être vide');
    }

    try {
      final categoryId = await _categoryRepo.addRedactionCategory(
        name: name.trim(),
        displayName: displayName.trim(),
        description: description?.trim(),
      );
      print(
        'Nouvelle catégorie de rédaction créée: "$displayName" (ID: $categoryId)',
      );
      return categoryId;
    } catch (e) {
      print('Erreur lors de la création de la catégorie de rédaction: $e');
      rethrow;
    }
  }

  /// **GESTION DES CATÉGORIES DE TAGS**

  /// Bascule l'affichage d'une catégorie de tag
  Future<void> toggleTagCategoryDisplay(int categoryId, bool isDisplay) async {
    if (categoryId <= 0) {
      throw ArgumentError('ID de catégorie invalide: $categoryId');
    }

    try {
      await _categoryRepo.toggleTagCategoryVisibility(categoryId, isDisplay);
      print('Catégorie tag $categoryId ${isDisplay ? 'affichée' : 'masquée'}');
    } catch (e) {
      print(
        'Erreur lors du changement de visibilité de la catégorie tag $categoryId: $e',
      );
      rethrow;
    }
  }

  /// **GESTION DES CATÉGORIES DE TAGS**

  /// Réorganise l'ordre des catégories de tags
  Future<void> reorderTagCategories(List<int> categoryIds) async {
    if (categoryIds.isEmpty) {
      throw ArgumentError('La liste des IDs ne peut pas être vide');
    }

    try {
      await _categoryRepo.reorderTagCategories(categoryIds);
      print(
        'Ordre des catégories de tags mis à jour: ${categoryIds.length} éléments',
      );
    } catch (e) {
      print('Erreur lors de la réorganisation des catégories de tags: $e');
      rethrow;
    }
  }

  /// Ajoute une nouvelle catégorie de tag avec validation
  Future<int> addTagCategory({
    required String name,
    required String displayName,
    String? description,
    String? color,
  }) async {
    // Validation métier
    if (name.trim().isEmpty) {
      throw ArgumentError('Le nom technique ne peut pas être vide');
    }
    if (displayName.trim().isEmpty) {
      throw ArgumentError('Le nom d\'affichage ne peut pas être vide');
    }

    // Validation de la couleur si fournie
    if (color != null && !_isValidHexColor(color)) {
      throw ArgumentError('Format de couleur invalide: $color');
    }

    try {
      final categoryId = await _categoryRepo.addTagCategory(
        name: name.trim(),
        displayName: displayName.trim(),
        description: description?.trim(),
        color: color,
      );
      print(
        'Nouvelle catégorie de tag créée: "$displayName" (ID: $categoryId)',
      );
      return categoryId;
    } catch (e) {
      print('Erreur lors de la création de la catégorie de tag: $e');
      rethrow;
    }
  }

  /// **RÉCUPÉRATION AVEC LOGIQUE MÉTIER**

  /// Récupère toutes les catégories de tags avec tri personnalisé
  Future<List<TagCategory>> getAllTagCategories({
    String orderBy = 'display_order ASC, id ASC',
  }) async {
    try {
      final categories = await _categoryRepo.getAllTagCategories(
        orderBy: orderBy,
      );
      print('${categories.length} catégories de tags récupérées');
      return categories;
    } catch (e) {
      print('Erreur lors de la récupération des catégories de tags: $e');
      rethrow;
    }
  }

  /// Récupère toutes les catégories de tags avec tri personnalisé
  Future<List<RedactionCategory>> getAllRedactionCategories({
    String orderBy = 'display_order ASC, id ASC',
  }) async {
    try {
      final categories = await _categoryRepo.getAllRedactionCategories();
      print('${categories.length} catégories de rédaction récupérées');
      return categories;
    } catch (e) {
      print('Erreur lors de la récupération des catégories de rédaction: $e');
      rethrow;
    }
  }

  /// Récupère toutes les catégories visibles avec formatage
  Future<Map<String, dynamic>> getVisibleCategoriesForDisplay() async {
    try {
      final tagCategories = await _categoryRepo.getVisibleTagCategories();
      final redactionCategories =
          await _categoryRepo.getVisibleRedactionCategories();

      return {
        'tagCategories': tagCategories,
        'redactionCategories': redactionCategories,
        'totalVisible': tagCategories.length + redactionCategories.length,
        'hasCategories':
            tagCategories.isNotEmpty || redactionCategories.isNotEmpty,
      };
    } catch (e) {
      print('Erreur lors de la récupération des catégories visibles: $e');
      rethrow;
    }
  }

  /// **SUPPRESSION DE CATÉGORIES**

  /// Supprime une catégorie de tag
  Future<void> deleteTagCategory(int categoryId) async {
    if (categoryId <= 0) {
      throw ArgumentError('ID de catégorie invalide: $categoryId');
    }

    try {
      await _categoryRepo.deleteTagCategory(categoryId);
      print('Catégorie de tag $categoryId supprimée avec succès');
    } catch (e) {
      print(
        'Erreur lors de la suppression de la catégorie de tag $categoryId: $e',
      );
      rethrow;
    }
  }

  /// Supprime une catégorie de rédaction
  Future<void> deleteRedactionCategory(int categoryId) async {
    if (categoryId <= 0) {
      throw ArgumentError('ID de catégorie invalide: $categoryId');
    }

    try {
      await _categoryRepo.deleteRedactionCategory(categoryId);
      print('Catégorie de rédaction $categoryId supprimée avec succès');
    } catch (e) {
      print(
        'Erreur lors de la suppression de la catégorie de rédaction $categoryId: $e',
      );
      rethrow;
    }
  }

  /// **MÉTHODES PRIVÉES - VALIDATION**

  /// Valide si une chaîne est une couleur hexadécimale valide
  bool _isValidHexColor(String color) {
    final hexRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexRegex.hasMatch(color);
  }
}
