import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
          FOREIGN KEY (category_id) REFERENCES redaction_categories (id) ON DELETE CASCADE,
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
    await db.execute(
      'CREATE INDEX idx_tags_usage_count ON tags(usage_count DESC)',
    );

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
}
