// Imports nécessaires pour accéder à la base de données et aux modèles
import 'package:revato_app/database/database.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/model/redaction_individual_model.dart';
import 'package:revato_app/model/tag_individual_model.dart';
import 'package:sqflite/sqflite.dart';

/// **SERVICE DREAM**
class DreamService {
  /// Récupère tous les rêves avec leurs données associées
  Future<List<Dream>> getAllDreamsWithTagsAndRedactions() async {
    final db = await AppDatabase().database;
    final results = await db.query('dreams', orderBy: 'created_at DESC');

    List<Dream> dreams = [];
    for (final row in results) {
      final dream = await _buildDreamWithAssociations(db, Dream.fromMap(row));
      dreams.add(dream);
    }

    print('Récupération de ${dreams.length} rêves avec tags et rédactions');
    return dreams;
  }

  /// Récupère un rêve spécifique avec ses données associées
  Future<Dream?> getDreamWithTagsAndRedactions(int dreamId) async {
    final db = await AppDatabase().database;

    final results = await db.query(
      'dreams',
      where: 'id = ?',
      whereArgs: [dreamId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final dream = Dream.fromMap(results.first);
    return await _buildDreamWithAssociations(db, dream);
  }

  /// Insère un nouveau rêve avec ses données associées
  Future<void> insertDreamWithData(Map<String, dynamic> data) async {
    final db = await AppDatabase().database;

    //Insérer le rêve
    final dreamId = await db.insert('dreams', {
      'title': data['title'],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Sauvegarder les données associées
    await _saveDreamAssociations(db, dreamId, data, isUpdate: false);
  }

  /// Met à jour un rêve existant avec ses données associées
  Future<void> UpdateDreamWithData(
    int dreamId,
    Map<String, dynamic> data,
  ) async {
    final db = await AppDatabase().database;

    // Mettre à jour le rêve
    await db.update(
      'dreams',
      {'title': data['title'], 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [dreamId],
    );

    // Sauvegarder les données associées
    await _saveDreamAssociations(db, dreamId, data, isUpdate: true);
  }

  /// DREAM Service
  Future<bool> deleteDream(int dreamId) async {
    try {
      final db = await AppDatabase().database;

      // Supprimer les liaisons rêve-tag
      await db.delete(
        'dream_tags',
        where: 'dream_id = ?',
        whereArgs: [dreamId],
      );

      // Supprimer les liaisons rêve-rédaction
      await db.delete(
        'dream_redactions',
        where: 'dream_id = ?',
        whereArgs: [dreamId],
      );

      // Supprimer le rêve lui-même
      await db.delete('dreams', where: 'id = ?', whereArgs: [dreamId]);

      return true;
    } catch (e) {
      print('Erreur lors de la suppression du rêve: $e');
      return false;
    }
  }

  /// **FONCTION PRIVÉE COMMUNE**
  /// Charge les tags et rédactions pour un rêve donné
  Future<Dream> _buildDreamWithAssociations(Database db, Dream dream) async {
    // **RÉCUPÉRATION DES TAGS**
    final tagRows = await db.rawQuery(
      '''
      SELECT tags.id, tags.name, tag_categories.name as category_name, tag_categories.color as color
      FROM tags
      INNER JOIN dream_tags ON tags.id = dream_tags.tag_id
      INNER JOIN tag_categories ON tags.category_id = tag_categories.id
      WHERE dream_tags.dream_id = ?
      ''',
      [dream.id],
    );

    dream.tags =
        tagRows
            .map(
              (tagRow) => Tag.fromMap({
                'id': tagRow['id'],
                'name': tagRow['name'] as String? ?? '',
                'category_name': tagRow['category_name'] as String? ?? '',
                'color': tagRow['color'] as String? ?? '#FFFFFF',
              }),
            )
            .toList();

    // **RÉCUPÉRATION DES RÉDACTIONS**
    final redactionRows = await db.rawQuery(
      '''
      SELECT redactions.id, redactions.content, redaction_categories.name as category_name, redaction_categories.display_name as display_name
      FROM redactions
      INNER JOIN dream_redactions ON redactions.id = dream_redactions.redaction_id
      INNER JOIN redaction_categories ON redactions.category_id = redaction_categories.id
      WHERE dream_redactions.dream_id = ?
      ''',
      [dream.id],
    );

    dream.redactions =
        redactionRows
            .map(
              (r) => Redaction.fromMap({
                'id': r['id'],
                'content': r['content'] as String? ?? '',
                'category_name': r['category_name'] as String? ?? '',
                'display_name': r['display_name'] as String? ?? '',
              }),
            )
            .toList();

    return dream;
  }

  /// **FONCTION PRIVÉE COMMUNE**
  /// Sauvegarde les tags et rédactions pour un rêve
  Future<void> _saveDreamAssociations(
    Database db,
    int dreamId,
    Map<String, dynamic> data, {
    required bool isUpdate,
  }) async {
    // **GESTION DES TAGS**
    await _saveDreamTags(db, dreamId, data, isUpdate: isUpdate);

    // **GESTION DES RÉDACTIONS**
    await _saveDreamRedactions(db, dreamId, data, isUpdate: isUpdate);
  }

  /// **FONCTION PRIVÉE - GESTION DES TAGS**
  Future<void> _saveDreamTags(
    Database db,
    int dreamId,
    Map<String, dynamic> data, {
    required bool isUpdate,
  }) async {
    final tagsByCategory = data['tagsByCategory'] as Map<String, List<String>>;

    for (final entry in tagsByCategory.entries) {
      final categoryName = entry.key;
      final tags = entry.value;

      // Récupérer l'id de la catégorie
      final categoryResult = await db.query(
        'tag_categories',
        where: 'name = ?',
        whereArgs: [categoryName],
        limit: 1,
      );
      if (categoryResult.isEmpty) continue;
      final categoryId = categoryResult.first['id'];

      // **DIFFÉRENCE INSERT vs UPDATE**
      if (isUpdate) {
        // Supprimer les anciennes liaisons pour cette catégorie
        await db.delete(
          'dream_tags',
          where:
              'dream_id = ? AND tag_id IN (SELECT id FROM tags WHERE category_id = ?)',
          whereArgs: [dreamId, categoryId],
        );
      }

      // **LOGIQUE COMMUNE** - Insérer les nouveaux tags
      for (final tag in tags) {
        // Vérifier si le tag existe déjà
        final existingTag = await db.query(
          'tags',
          where: 'name = ? AND category_id = ?',
          whereArgs: [tag, categoryId],
          limit: 1,
        );

        int tagId;
        if (existingTag.isNotEmpty) {
          // Tag existant
          tagId = existingTag.first['id'] as int;
        } else {
          // Tag nouveau
          tagId = await db.insert('tags', {
            'name': tag,
            'category_id': categoryId,
            'created_at': DateTime.now().toIso8601String(),
          });
        }

        // Insérer la liaison rêve-tag
        await db.insert('dream_tags', {
          'dream_id': dreamId,
          'tag_id': tagId,
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }
  }

  /// **FONCTION PRIVÉE - GESTION DES RÉDACTIONS**
  Future<void> _saveDreamRedactions(
    Database db,
    int dreamId,
    Map<String, dynamic> data, {
    required bool isUpdate,
  }) async {
    final redactionsByCategory =
        data['redactionsByCategory'] as Map<String, String>;

    for (final entry in redactionsByCategory.entries) {
      final categoryName = entry.key;
      final content = entry.value;
      if (content.isEmpty) continue;

      // Récupérer l'id de la catégorie de rédaction
      final categoryResult = await db.query(
        'redaction_categories',
        where: 'name = ?',
        whereArgs: [categoryName],
        limit: 1,
      );
      if (categoryResult.isEmpty) continue;
      final categoryId = categoryResult.first['id'];

      // **DIFFÉRENCE INSERT vs UPDATE**
      if (isUpdate) {
        // Supprimer les anciennes liaisons pour cette catégorie
        await db.delete(
          'dream_redactions',
          where:
              'dream_id = ? AND redaction_id IN (SELECT id FROM redactions WHERE category_id = ?)',
          whereArgs: [dreamId, categoryId],
        );
      }

      // **LOGIQUE COMMUNE** - Insérer la nouvelle rédaction
      final redactionId = await db.insert('redactions', {
        'content': content,
        'category_id': categoryId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Insérer la liaison rêve-rédaction
      await db.insert('dream_redactions', {
        'dream_id': dreamId,
        'redaction_id': redactionId,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}
