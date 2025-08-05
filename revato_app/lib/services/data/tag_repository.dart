import 'package:revato_app/database/database.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';

class TagRepository {
  /// Renomme un tag dans une catégorie
  Future<void> renameTag(
    String oldName,
    String newName,
    String categoryName,
  ) async {
    final db = await AppDatabase().database;
    // Récupérer l'id de la catégorie
    final categoryResult = await db.query(
      'tag_categories',
      where: 'name = ?',
      whereArgs: [categoryName],
      limit: 1,
    );
    if (categoryResult.isEmpty) return;
    final categoryId = categoryResult.first['id'];

    // Vérifier si le nouveau nom existe déjà dans cette catégorie
    final existing = await db.query(
      'tags',
      where: 'name = ? AND category_id = ?',
      whereArgs: [newName, categoryId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      // Si le tag existe déjà, il faut relier tous les rêves de l'ancien tag vers le nouveau, puis supprimer l'ancien tag
      final newTagId = existing.first['id'];
      final oldTagRows = await db.query(
        'tags',
        where: 'name = ? AND category_id = ?',
        whereArgs: [oldName, categoryId],
        limit: 1,
      );
      if (oldTagRows.isEmpty) return;
      final oldTagId = oldTagRows.first['id'];
      // Mettre à jour toutes les liaisons dream_tags
      await db.update(
        'dream_tags',
        {'tag_id': newTagId},
        where: 'tag_id = ?',
        whereArgs: [oldTagId],
      );
      // Supprimer l'ancien tag
      await db.delete('tags', where: 'id = ?', whereArgs: [oldTagId]);
    } else {
      // Sinon, on peut simplement renommer le tag
      await db.update(
        'tags',
        {'name': newName},
        where: 'name = ? AND category_id = ?',
        whereArgs: [oldName, categoryId],
      );
    }
  }

  // Méthodes pour récupérer les catégories et tags
  Future<List<String>> getTagsForCategory(String categoryName) async {
    final db = await AppDatabase().database;
    // Récupérer l'id de la catégorie
    final categoryResult = await db.query(
      'tag_categories',
      where: 'name = ?',
      whereArgs: [categoryName],
      limit: 1,
    );
    if (categoryResult.isEmpty) return [];
    final categoryId = categoryResult.first['id'];

    // Récupérer les tags de cette catégorie
    final tagResults = await db.query(
      'tags',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return tagResults.map((row) => row['name'] as String).toList();
  }

  // récupérer seulement les catégories actives
  Future<List<RedactionCategory>> getActiveRedactionCategories() async {
    final db = await AppDatabase().database;
    final results = await db.query(
      'redaction_categories',
      where: 'is_display = ?',
      whereArgs: [1],
      orderBy: 'display_order ASC, name ASC',
    );
    return results.map((row) => RedactionCategory.fromMap(row)).toList();
  }

  Future<List<TagCategory>> getActiveTagCategories() async {
    final db = await AppDatabase().database;
    final results = await db.query(
      'tag_categories',
      where: 'is_display = ?',
      whereArgs: [1],
      orderBy: 'display_order ASC, name ASC',
    );
    return results.map((row) => TagCategory.fromMap(row)).toList();
  }

  // Méthode pour récupérer les couleurs des catégories de tags
  Future<Map<String, String>> getTagCategoryColors() async {
    final db = await AppDatabase().database;
    final results = await db.query(
      'tag_categories',
      columns: ['name', 'color'],
    );
    return Map.fromEntries(
      results.map(
        (row) => MapEntry(
          row['name'] as String,
          row['color'] as String? ?? '#FFFFFF',
        ),
      ),
    );
  }

  /// **RÉCUPÉRATION DE TOUS LES TAGS DISPONIBLES**
  /// Retourne une liste plate de tous les tags, toutes catégories confondues
  Future<List<String>> getAllAvailableTags() async {
    final categories = await getActiveTagCategories();
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
    final categories = await getActiveTagCategories();
    final Map<String, String> tagToCategory = {};

    for (final category in categories) {
      final tagsInCategory = await getTagsForCategory(category.name);
      for (final tag in tagsInCategory) {
        tagToCategory[tag] = category.name;
      }
    }

    return tagToCategory;
  }

  /// Filtre Service
  /// **RECHERCHE DE TAGS PAR TEXTE**
  /// Filtre les tags disponibles selon un texte de recherche
  Future<List<String>> searchTags(String searchText) async {
    if (searchText.isEmpty) return [];

    final allTags = await getAllAvailableTags();
    return allTags
        .where((tag) => tag.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  /// **RÉCUPÉRATION DE LA CATÉGORIE D'UN TAG**
  /// Retourne la catégorie d'un tag donné
  Future<String?> getTagCategory(String tagName) async {
    final db = await AppDatabase().database;
    final result = await db.rawQuery(
      '''
      SELECT tc.name as category_name
      FROM tags t
      JOIN tag_categories tc ON t.category_id = tc.id
      WHERE t.name = ?
      LIMIT 1
    ''',
      [tagName],
    );

    if (result.isNotEmpty) {
      return result.first['category_name'] as String;
    }
    return null;
  }
}
