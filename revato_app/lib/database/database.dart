import 'package:revato_app/model/redaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/tag_model.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  factory AppDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'revato_dreams.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Nouvelle structure normalisée
    await db.execute('''
        CREATE TABLE dreams (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
    ''');
    // Table de redaction_categories
    await db.execute('''
      CREATE TABLE redaction_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        created_at TEXT NOT NULL
      )
     ''');

    // Table des redactions
    await db.execute('''
        CREATE TABLE redactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,
          category_id INTEGER NOT NULL, 
          created_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES redaction_categories (id) ON DELETE CASCADE
        )
    ''');

    // Table de liaison entre rêves et redactions
    await db.execute('''
        CREATE TABLE dream_redactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dream_id INTEGER NOT NULL,
          redaction_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (dream_id) REFERENCES dreams (id) ON DELETE CASCADE,
          FOREIGN KEY (redaction_id) REFERENCES redactions (id) ON DELETE CASCADE,
          UNIQUE(dream_id, redaction_id)
        )
    ''');

    // Table des catégories de tags
    await db.execute('''
        CREATE TABLE tag_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          description TEXT,
          color TEXT,
          created_at TEXT NOT NULL
        )
    ''');

    // Table des tags
    await db.execute('''
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          category_id INTEGER NOT NULL,          created_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES tag_categories (id) ON DELETE CASCADE,
          UNIQUE(name, category_id)
        )
    ''');

    // Table de liaison entre rêves et tags
    await db.execute('''
        CREATE TABLE dream_tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dream_id INTEGER NOT NULL,
          tag_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (dream_id) REFERENCES dreams (id) ON DELETE CASCADE,
          FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE,
          UNIQUE(dream_id, tag_id)
        )
    ''');

    // Index pour améliorer les performances
    await db.execute(
      'CREATE INDEX idx_dreams_created_at ON dreams(created_at)',
    );
    await db.execute('CREATE INDEX idx_tags_category ON tags(category_id)');
    await db.execute(
      'CREATE INDEX idx_dream_tags_dream ON dream_tags(dream_id)',
    );
    await db.execute('CREATE INDEX idx_dream_tags_tag ON dream_tags(tag_id)');

    // Insérer les catégories par défaut
    await _insertDefaultCategories(db);
    // Insérer les notations par défaut
    await _insertDefaultNotation(db);
  }

  /// Insère les notations par défaut
  Future<void> _insertDefaultNotation(Database db) async {
    final now = DateTime.now().toIso8601String();

    final notations = [
      {'name': 'dream_notation', 'description': 'notation du rêve'},
      {'name': 'dream_notation_feeling', 'description': 'ressenti du rêve'},
    ];

    for (final notation in notations) {
      await db.insert('redaction_categories', {...notation, 'created_at': now});
    }
  }

  /// Insère les catégories de tags par défaut
  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    final categories = [
      {
        'name': 'location',
        'description': 'Lieux et environnements',
        'color': '#E57373',
      },
      {
        'name': 'actor',
        'description': 'Personnes et personnages',
        'color': '#64B5F6',
      },
      {
        'name': 'previous_day_event',
        'description': 'Événements de la veille',
        'color': '#81C784',
      },
      {
        'name': 'previous_day_feeling',
        'description': 'Ressentis de la veille',
        'color': '#BA68C8',
      },
      {
        'name': 'dream_feeling',
        'description': 'Ressentis du rêve',
        'color': '#FFD54F',
      },
    ];

    for (final category in categories) {
      await db.insert('tag_categories', {...category, 'created_at': now});
    }
  }

  ///=========== FUNCTIONS =============== ///

  /// Insère un rêve avec ses données associées
  Future<void> insertDreamWithData(Map<String, dynamic> data) async {
    final db = await database;
    final batch = db.batch();

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
    final db = await database;
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
    final db = await database;
    final results = await db.query('tag_categories', orderBy: 'name');
    return results.map((row) => TagCategory.fromMap(row)).toList();
  }

  // Méthode pour récupérer toutes les catégories de rédaction
  Future<List<RedactionCategory>> getAllRedactionCategories() async {
    final db = await database;
    final results = await db.query('redaction_categories', orderBy: 'name');
    return results
        .map(
          (row) => RedactionCategory(
            name: row['name'] as String,
            description: row['description'] as String? ?? '',
          ),
        )
        .toList();
  }
}
