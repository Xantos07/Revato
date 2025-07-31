import '../database/database.dart';
import '../model/redaction_model.dart';
import '../model/tag_model.dart';

/// **SERVICE DE GESTION DES PRÉFÉRENCES DU CAROUSEL**
/// Service dédié à la personnalisation du carousel d'écriture.
/// Responsable de :
/// - Gérer la visibilité des catégories (is_display)
/// - Gérer l'ordre d'affichage (display_order)
/// - Ajouter de nouvelles catégories
/// - Modifier les catégories existantes
class CarouselEditorService {
  final AppDatabase _database = AppDatabase();

  /// **RÉCUPÉRATION DES CATÉGORIES POUR L'ÉDITION**
  Future<List<RedactionCategory>> getAllRedactionCategories() async {
    final db = await _database.database;
    final maps = await db.query(
      'redaction_categories',
      orderBy: 'display_order ASC, id ASC',
    );
    return maps.map((map) => RedactionCategory.fromMap(map)).toList();
  }

  Future<List<TagCategory>> getAllTagCategories() async {
    final db = await _database.database;
    final maps = await db.query(
      'tag_categories',
      orderBy: 'display_order ASC, id ASC',
    );
    return maps.map((map) => TagCategory.fromMap(map)).toList();
  }

  /// **RÉCUPÉRATION DES CATÉGORIES VISIBLES POUR LE CAROUSEL D'ÉCRITURE**
  Future<List<RedactionCategory>> getVisibleRedactionCategories() async {
    final db = await _database.database;
    final maps = await db.query(
      'redaction_categories',
      where: 'is_display = ?',
      whereArgs: [1],
      orderBy: 'display_order ASC, id ASC',
    );
    return maps.map((map) => RedactionCategory.fromMap(map)).toList();
  }

  Future<List<TagCategory>> getVisibleTagCategories() async {
    final db = await _database.database;
    final maps = await db.query(
      'tag_categories',
      where: 'is_display = ?',
      whereArgs: [1],
      orderBy: 'display_order ASC, id ASC',
    );
    return maps.map((map) => TagCategory.fromMap(map)).toList();
  }

  /// **GESTION DE LA VISIBILITÉ**
  Future<void> toggleRedactionCategoryDisplay(
    int categoryId,
    bool isDisplay,
  ) async {
    final db = await _database.database;
    await db.update(
      'redaction_categories',
      {'is_display': isDisplay ? 1 : 0},
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<void> toggleTagCategoryDisplay(int categoryId, bool isDisplay) async {
    final db = await _database.database;
    await db.update(
      'tag_categories',
      {'is_display': isDisplay ? 1 : 0},
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  /// **RÉORGANISATION DE L'ORDRE**
  Future<void> reorderRedactionCategories(List<int> categoryIds) async {
    final db = await _database.database;
    for (int i = 0; i < categoryIds.length; i++) {
      await db.update(
        'redaction_categories',
        {'display_order': i + 1},
        where: 'id = ?',
        whereArgs: [categoryIds[i]],
      );
    }
  }

  Future<void> reorderTagCategories(List<int> categoryIds) async {
    final db = await _database.database;
    for (int i = 0; i < categoryIds.length; i++) {
      await db.update(
        'tag_categories',
        {'display_order': i + 1},
        where: 'id = ?',
        whereArgs: [categoryIds[i]],
      );
    }
  }

  /// **MODIFICATION DE CATÉGORIE**
  Future<void> updateRedactionCategory(RedactionCategory category) async {
    final db = await _database.database;
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

  Future<void> updateTagCategory(TagCategory category) async {
    final db = await _database.database;
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

  /// **AJOUT DE NOUVELLES CATÉGORIES**
  Future<int> addRedactionCategory({
    required String name,
    required String displayName,
    String? description,
  }) async {
    final db = await _database.database;
    return await db.insert('redaction_categories', {
      'name': name,
      'display_name': displayName,
      'description': description,
      'is_display': 1,
      'display_order': 999, // Mettre à la fin par défaut
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> addTagCategory({
    required String name,
    required String displayName,
    String? description,
    String? color,
  }) async {
    final db = await _database.database;
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
}
