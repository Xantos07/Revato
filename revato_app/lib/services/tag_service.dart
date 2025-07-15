import 'package:revato_app/model/tag_model.dart';
import 'package:revato_app/services/dream_service.dart';

/// **SERVICE POUR LA GESTION DES TAGS**
/// Responsable de :
/// - Récupérer les catégories de tags depuis la base de données
/// - Récupérer les tags pour une catégorie spécifique
/// - Centraliser l'accès aux données de tags pour tous les ViewModels
class TagService {
  // Instance du service principal pour accéder à la DB
  final DreamService _dreamService = DreamService();

  /// **RÉCUPÉRATION DE TOUTES LES CATÉGORIES DE TAGS**
  /// Retourne la liste complète des catégories disponibles
  Future<List<TagCategory>> getAllTagCategories() async {
    return await _dreamService.getAllTagCategories();
  }

  /// **RÉCUPÉRATION DES TAGS POUR UNE CATÉGORIE**
  /// Retourne tous les tags disponibles pour une catégorie spécifique
  Future<List<String>> getTagsForCategory(String categoryName) async {
    return await _dreamService.getTagsForCategory(categoryName);
  }

  /// **RÉCUPÉRATION DE TOUS LES TAGS DISPONIBLES**
  /// Retourne une liste plate de tous les tags, toutes catégories confondues
  Future<List<String>> getAllAvailableTags() async {
    final categories = await getAllTagCategories();
    final List<String> allTags = [];

    for (final category in categories) {
      final tagsInCategory = await getTagsForCategory(category.name);
      allTags.addAll(tagsInCategory);
    }

    return allTags;
  }

  /// **RÉCUPÉRATION DES TAGS AVEC LEURS CATÉGORIES**
  /// Retourne un Map associant chaque tag à sa catégorie
  Future<Map<String, String>> getTagsWithCategories() async {
    final categories = await getAllTagCategories();
    final Map<String, String> tagToCategory = {};

    for (final category in categories) {
      final tagsInCategory = await getTagsForCategory(category.name);
      for (final tag in tagsInCategory) {
        tagToCategory[tag] = category.name;
      }
    }

    return tagToCategory;
  }

  /// **RECHERCHE DE TAGS PAR TEXTE**
  /// Filtre les tags disponibles selon un texte de recherche
  Future<List<String>> searchTags(String searchText) async {
    if (searchText.isEmpty) return [];

    final allTags = await getAllAvailableTags();
    return allTags
        .where((tag) => tag.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  /// **RÉCUPÉRATION DES CATÉGORIES POPULAIRES**
  /// Retourne les catégories les plus utilisées (à implémenter selon les besoins)
  Future<List<TagCategory>> getPopularCategories() async {
    // Pour l'instant, retourne toutes les catégories
    // TODO: Implémenter la logique de popularité basée sur l'usage
    return await getAllTagCategories();
  }
}
