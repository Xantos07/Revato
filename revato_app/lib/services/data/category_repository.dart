import 'package:revato_app/database/database.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';

class CategoryRepository {
  Future<List<TagCategory>> getAllTagCategories({
    String orderBy = 'display_order ASC, id ASC',
  }) async {
    final db = await AppDatabase().database;
    final maps = await db.query('tag_categories', orderBy: orderBy);
    return maps.map((map) => TagCategory.fromMap(map)).toList();
  }

  // Récupère seulement les catégories de tags visibles
  Future<List<TagCategory>> getVisibleTagCategories() async {
    final db = await AppDatabase().database;
    final maps = await db.query(
      'tag_categories',
      where: 'is_display = ?',
      whereArgs: [1],
      orderBy: 'display_order ASC, id ASC',
    );
    return maps.map((map) => TagCategory.fromMap(map)).toList();
  }

  // Récupère toutes les catégories de rédaction
  Future<List<RedactionCategory>> getAllRedactionCategories() async {
    final db = await AppDatabase().database;
    final results = await db.query(
      'redaction_categories',
      orderBy: 'display_order ASC, id ASC',
    );

    return results.map((map) => RedactionCategory.fromMap(map)).toList();
  }

  // Récupère seulement les catégories de rédaction visibles
  Future<List<RedactionCategory>> getVisibleRedactionCategories() async {
    final db = await AppDatabase().database;
    final maps = await db.query(
      'redaction_categories',
      where: 'is_display = ?',
      whereArgs: [1],
      orderBy: 'display_order ASC, id ASC',
    );
    return maps.map((map) => RedactionCategory.fromMap(map)).toList();
  }

  Future<void> updateTagCategory(TagCategory category) async {
    final db = await AppDatabase().database;
    await db.update(
      'tag_categories',
      {
        'name': category.name,
        'display_name': category.displayName,
        'description': category.description,
        'color': category.color,
        'is_display': category.isDisplay ? 1 : 0,
        'display_order': category.displayOrder,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Change la visibilité d'une catégorie de tag
  Future<void> toggleTagCategoryVisibility(int id, bool isDisplay) async {
    final db = await AppDatabase().database;
    await db.update(
      'tag_categories',
      {'is_display': isDisplay ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// **MÉTHODES EX-CAROUSELEDITORSERVICE**

  /// Gestion de la visibilité des catégories de rédaction
  Future<void> toggleRedactionCategoryDisplay(
    int categoryId,
    bool isDisplay,
  ) async {
    final db = await AppDatabase().database;
    await db.update(
      'redaction_categories',
      {'is_display': isDisplay ? 1 : 0},
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  /// Réorganisation de l'ordre des catégories de rédaction
  Future<void> reorderRedactionCategories(List<int> categoryIds) async {
    final db = await AppDatabase().database;
    for (int i = 0; i < categoryIds.length; i++) {
      await db.update(
        'redaction_categories',
        {'display_order': i + 1},
        where: 'id = ?',
        whereArgs: [categoryIds[i]],
      );
    }
  }

  /// Réorganisation de l'ordre des catégories de tags
  Future<void> reorderTagCategories(List<int> categoryIds) async {
    final db = await AppDatabase().database;
    for (int i = 0; i < categoryIds.length; i++) {
      await db.update(
        'tag_categories',
        {'display_order': i + 1},
        where: 'id = ?',
        whereArgs: [categoryIds[i]],
      );
    }
  }

  /// Mise à jour d'une catégorie de rédaction
  Future<void> updateRedactionCategory(RedactionCategory category) async {
    final db = await AppDatabase().database;
    await db.update(
      'redaction_categories',
      {
        'name': category.name,
        'display_name': category.displayName,
        'description': category.description,
        'is_display': category.isDisplay ? 1 : 0,
        'display_order': category.displayOrder,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Ajout d'une nouvelle catégorie de rédaction
  Future<int> addRedactionCategory({
    required String name,
    required String displayName,
    String? description,
  }) async {
    final db = await AppDatabase().database;
    return await db.insert('redaction_categories', {
      'name': name,
      'display_name': displayName,
      'description': description,
      'is_display': 1,
      'display_order': 999,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Ajout d'une nouvelle catégorie de tag
  Future<int> addTagCategory({
    required String name,
    required String displayName,
    String? description,
    String? color,
  }) async {
    final db = await AppDatabase().database;
    return await db.insert('tag_categories', {
      'name': name,
      'display_name': displayName,
      'description': description,
      'color': color ?? '#7C3AED',
      'is_display': 1,
      'display_order': 999,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Suppression d'une catégorie de tag
  Future<void> deleteTagCategory(int categoryId) async {
    final db = await AppDatabase().database;
    await db.delete('tag_categories', where: 'id = ?', whereArgs: [categoryId]);
  }

  /// Suppression d'une catégorie de rédaction
  Future<void> deleteRedactionCategory(int categoryId) async {
    final db = await AppDatabase().database;
    await db.delete(
      'redaction_categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }
}
