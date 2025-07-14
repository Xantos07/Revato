// Imports nécessaires pour accéder à la base de données et aux modèles
import 'package:revato_app/database/database.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/model/redaction_individual_model.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_individual_model.dart';
import 'package:revato_app/model/tag_model.dart';
import 'package:sqflite/sqflite.dart';

/// **SERVICE DREAM**
/// Couche de service qui fait le pont entre l'interface utilisateur et la base de données.
/// Responsable de :
/// - Récupérer les données depuis SQLite
/// - Effectuer les requêtes complexes avec JOIN
/// - Transformer les données brutes en objets métier
/// - Centraliser la logique d'accès aux données
class DreamService {
  /// **MÉTHODE PRINCIPALE - RÉCUPÉRATION COMPLÈTE**
  /// Récupère tous les rêves avec leurs tags et rédactions associés
  /// Utilise des requêtes JOIN pour récupérer les données liées en une seule opération
  Future<List<Dream>> getAllDreamsWithTagsAndRedactions() async {
    // **1. CONNEXION À LA BASE DE DONNÉES**
    final db = await AppDatabase().database;

    // **2. REQUÊTE PRINCIPALE - RÉCUPÉRATION DES RÊVES**
    // Récupère tous les rêves triés par date de création (plus récent en premier)
    final results = await db.query('dreams', orderBy: 'created_at DESC');

    List<Dream> dreams = [];

    // **DEBUG - VÉRIFICATION DES DONNÉES** (à supprimer en production)
    final allRedactions = await db.query('redactions');
    final allDreamRedactions = await db.query('dream_redactions');
    print('Toutes les rédactions dans la DB: $allRedactions');
    print('Toutes les liaisons dream_redactions: $allDreamRedactions');

    // **3. TRAITEMENT DE CHAQUE RÊVE**
    for (final row in results) {
      // Création de l'objet Dream depuis les données brutes
      final dream = Dream.fromMap(row);

      // **4. RÉCUPÉRATION DES TAGS ASSOCIÉS**
      // Requête JOIN complexe : dreams -> dream_tags -> tags -> tag_categories
      // Permet de récupérer le nom du tag ET le nom de sa catégorie
      final tagRows = await db.rawQuery(
        '''
      SELECT tags.id, tags.name, tag_categories.name as category_name, tag_categories.color as color
      FROM tags
      INNER JOIN dream_tags ON tags.id = dream_tags.tag_id
      INNER JOIN tag_categories ON tags.category_id = tag_categories.id
      WHERE dream_tags.dream_id = ?
    ''',
        [dream.id], // Paramètre sécurisé pour éviter les injections SQL
      );

      // Transformation des données brutes en objets Tag
      dream.tags =
          tagRows
              .map(
                (tagRow) => Tag.fromMap({
                  'id': tagRow['id'],
                  'name': tagRow['name'] as String? ?? '',
                  'category_name': tagRow['category_name'] as String? ?? '',
                  'color':
                      tagRow['color'] as String? ??
                      '#FFFFFF', // Ajout de la couleur
                }),
              )
              .toList();

      // **5. RÉCUPÉRATION DES RÉDACTIONS ASSOCIÉES**
      // Requête JOIN similaire pour les rédactions/notations
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

      // **DEBUG - VÉRIFICATION DES RÉDACTIONS** (à supprimer en production)
      print('Rédactions brutes pour dream ${dream.id}: $redactionRows');

      // Transformation des données brutes en objets Redaction
      dream.redactions =
          redactionRows
              .map(
                (r) => Redaction.fromMap({
                  'id': r['id'],
                  'content': r['content'] as String? ?? '',
                  'category_name': r['category_name'] as String? ?? '',
                  'display_name':
                      r['display_name'] as String? ??
                      '', // Ajout du displayName
                }),
              )
              .toList();

      // **DEBUG - AFFICHAGE FINAL** (à supprimer en production)
      print('Dream ${dream.id}: ${dream.title}');
      print('Tags récupérés: ${dream.tags.map((t) => t.name).toList()}');
      print(
        'Rédactions récupérées: ${dream.redactions.map((r) => '${r.categoryName}: ${r.content}').toList()}',
      );

      // **6. AJOUT DU RÊVE COMPLET À LA LISTE**
      dreams.add(dream);
    }

    // **7. RETOUR DES DONNÉES COMPLÈTES**
    return dreams;
  }

  ///=========== FUNCTIONS =============== ///

  /// Insère un rêve avec ses données associées
  Future<void> insertDreamWithData(Map<String, dynamic> data) async {
    final db = await AppDatabase().database;

    // 1. Insérer le rêve
    final dreamId = await db.insert('dreams', {
      'title': data['title'],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // 2. Insérer les tags et liaisons
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

      for (final tag in tags) {
        // Insérer le tag s'il n'existe pas
        final tagId = await db.insert('tags', {
          'name': tag,
          'category_id': categoryId,
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        // Récupérer l'id du tag (si déjà existant)
        final tagRow = await db.query(
          'tags',
          where: 'name = ? AND category_id = ?',
          whereArgs: [tag, categoryId],
          limit: 1,
        );
        final realTagId = tagRow.first['id'];

        // Insérer la liaison rêve-tag
        await db.insert('dream_tags', {
          'dream_id': dreamId,
          'tag_id': realTagId,
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    // 3. Insérer les rédactions et liaisons
    final redactionsByCategory =
        data['redactionByCategory'] as Map<String, String>;
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

      // Insérer la rédaction
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

  // Méthode pour récupérer toutes les catégories de tags
  Future<List<TagCategory>> getAllTagCategories() async {
    final db = await AppDatabase().database;
    final results = await db.query('tag_categories', orderBy: 'name');
    return results.map((row) => TagCategory.fromMap(row)).toList();
  }

  // Méthode pour récupérer toutes les catégories de rédaction
  Future<List<RedactionCategory>> getAllRedactionCategories() async {
    final db = await AppDatabase().database;
    final results = await db.query('redaction_categories', orderBy: 'name');
    return results
        .map(
          (row) => RedactionCategory(
            name: row['name'] as String,
            displayName: row['display_name'] as String,
            description: row['description'] as String? ?? '',
          ),
        )
        .toList();
  }

  // Méyhdoe pour récupérer les couleurs des catégories de tags
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
}
