// Imports nécessaires pour la gestion de la base de données SQLite et des modèles
import 'package:revato_app/model/redaction_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/tag_model.dart';

/// **GESTIONNAIRE DE BASE DE DONNÉES**
/// Classe singleton responsable de :
/// - La connexion et l'initialisation de la base SQLite
/// - La création et migration du schéma de base de données
/// - La gestion du cycle de vie de la DB (ouverture/fermeture)
/// - L'insertion des données par défaut (catégories, tags initiaux)
class AppDatabase {
  // **PATTERN SINGLETON** - Une seule instance de DB dans toute l'app
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  // Constructeur privé pour empêcher la création d'instances multiples
  AppDatabase._internal();

  // Factory constructor qui retourne toujours la même instance
  factory AppDatabase() => _instance;

  /// **GETTER PRINCIPAL - ACCÈS À LA BASE**
  /// Point d'entrée unique pour obtenir la connexion à la base de données
  /// Lazy loading : crée la DB seulement au premier accès
  Future<Database> get database async {
    if (_database != null) return _database!; // Retourne l'instance existante
    _database = await _initDatabase(); // Sinon, initialise la DB
    return _database!;
  }

  /// **INITIALISATION PRIVÉE**
  /// Configure le chemin et ouvre la base de données SQLite
  Future<Database> _initDatabase() async {
    // Construit le chemin vers le fichier de base de données
    String path = join(await getDatabasesPath(), 'revato_dreams.db');

    // Ouvre ou crée la base avec gestion des versions
    return await openDatabase(
      path,
      version: 2, // Version actuelle du schéma
      onCreate: _createDatabase, // Callback de création si DB n'existe pas
      onUpgrade: _upgradeDatabase,
    );
  }

  /// **CRÉATION DU SCHÉMA DE BASE**
  /// Définit toute la structure des tables et relations de l'application
  /// Appelé automatiquement lors de la première ouverture
  Future<void> _createDatabase(Database db, int version) async {
    // **TABLE PRINCIPALE - DREAMS**
    // Stocke les informations de base de chaque rêve
    await db.execute('''
        CREATE TABLE dreams (
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          title TEXT NOT NULL UNIQUE,                   
          created_at TEXT NOT NULL,              
          updated_at TEXT                        
        )
    ''');

    // **TABLE CATÉGORIES DE RÉDACTIONS**
    // Définit les types de notes possibles (ex: "notation du rêve", "ressenti")
    // is_display et display_order ajouter a la migration V2
    await db.execute('''
      CREATE TABLE redaction_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,  
        display_name TEXT NOT NULL,           
        description TEXT,            
        is_display INTEGER DEFAULT 1,       
        display_order INTEGER DEFAULT 0,         
        created_at TEXT NOT NULL
      )
     ''');

    // **TABLE RÉDACTIONS INDIVIDUELLES**
    // Stocke le contenu textuel des notes utilisateur
    await db.execute('''
        CREATE TABLE redactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          content TEXT NOT NULL,                 
          category_id INTEGER NOT NULL,          
          created_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES redaction_categories (id) ON DELETE CASCADE
        )
    ''');

    // **TABLE DE LIAISON RÊVES-RÉDACTIONS**
    // Relation many-to-many : un rêve peut avoir plusieurs rédactions
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

    // **TABLE CATÉGORIES DE TAGS**
    // Définit les types de tags possibles (ex: "location", "actor", "feeling")
    // is_display et display_order ajouter a la migration V2
    await db.execute('''
        CREATE TABLE tag_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,     
          display_name TEXT NOT NULL,         
          description TEXT,                      
          color TEXT,                     
          is_display INTEGER DEFAULT 1,   
          display_order INTEGER DEFAULT 0,       
          created_at TEXT NOT NULL
        )
    ''');

    // **TABLE TAGS INDIVIDUELS**
    // Stocke les tags spécifiques saisis par l'utilisateur
    await db.execute(''' 
        CREATE TABLE tags (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,                    
          category_id INTEGER NOT NULL,          
          created_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES tag_categories (id) ON DELETE CASCADE,
          UNIQUE(name, category_id)              
        )
    ''');

    // **TABLE DE LIAISON RÊVES-TAGS**
    // Relation many-to-many : un rêve peut avoir plusieurs tags
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

    // **INDEX POUR OPTIMISATION DES PERFORMANCES**
    // Accélère les requêtes fréquentes sur les colonnes clés
    await db.execute(
      'CREATE INDEX idx_dreams_created_at ON dreams(created_at)',
    );
    await db.execute('CREATE INDEX idx_tags_category ON tags(category_id)');
    await db.execute(
      'CREATE INDEX idx_dream_tags_dream ON dream_tags(dream_id)',
    );
    await db.execute('CREATE INDEX idx_dream_tags_tag ON dream_tags(tag_id)');

    // **INSERTION DES DONNÉES PAR DÉFAUT**
    await _insertDefaultCategories(db); // Catégories de tags prédéfinies
    await _insertDefaultNotation(db); // Catégories de rédactions prédéfinies
  }

  /// **INSERTION DES CATÉGORIES DE RÉDACTION PAR DÉFAUT**
  /// Prépare les types de notes standard disponibles pour tous les rêves
  Future<void> _insertDefaultNotation(Database db) async {
    final now = DateTime.now().toIso8601String();

    final notations = [
      {
        'name': 'dream_notation',
        'display_name': 'Notation du rêve',
        'description': 'notation du rêve',
        'is_display': 1,
        'display_order': 1,
      },
      {
        'name': 'dream_notation_feeling',
        'display_name': 'Notation du ressenti du rêve',
        'description': 'ressenti du rêve',
        'is_display': 1,
        'display_order': 2,
      },
    ];

    for (final notation in notations) {
      await db.insert('redaction_categories', {...notation, 'created_at': now});
    }
  }

  /// **INSERTION DES CATÉGORIES DE TAGS PAR DÉFAUT**
  /// Prépare les types de tags standard avec leurs couleurs d'affichage
  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    // **CATÉGORIES PRÉDÉFINIES** avec couleurs pour l'interface
    final categories = [
      {
        'name': 'location', // Lieux du rêve
        'display_name': 'Lieux du rêve',
        'description': 'Lieux et environnements du rêve',
        'color': '#E57373', // Rouge clair
        'is_display': 1,
        'display_order': 1,
      },
      {
        'name': 'actor', // Personnes présentes
        'display_name': 'Personnes dans le rêve',
        'description': 'Personnes et personnages',
        'color': '#64B5F6', // Bleu clair
        'is_display': 1,
        'display_order': 2,
      },
      {
        'name': 'previous_day_event', // Événements récents influents
        'display_name': 'Événements récents',
        'description': 'Événements de la veille',
        'color': '#81C784', // Vert clair
        'is_display': 1,
        'display_order': 3,
      },
      {
        'name': 'previous_day_feeling', // État émotionnel précédent
        'display_name': 'État émotionnel de la veille',
        'description': 'Ressentis de la veille',
        'color': '#BA68C8', // Violet clair
        'is_display': 1,
        'display_order': 4,
      },
      {
        'name': 'dream_feeling', // Émotions dans le rêve
        'display_name': 'Émotions du rêve',
        'description': 'Ressentis du rêve',
        'color': '#FFD54F', // Jaune clair
        'is_display': 1,
        'display_order': 5,
      },
    ];

    // **INSERTION EN BASE**
    for (final category in categories) {
      await db.insert('tag_categories', {...category, 'created_at': now});
    }
  }

  /// **MIGRATION DE SCHÉMA**

  /// **GESTIONNAIRE DE MIGRATIONS**
  /// Applique les modifications de schéma selon la version
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration de v1 vers v2 : ajout des colonnes de personnalisation
    if (oldVersion < 2) {
      await _migrateToVersion2(db);
    }

    // Future migrations...
    // if (oldVersion < 3) {
    //   await _migrateToVersion3(db);
    // }
  }

  /// **MIGRATION VERS VERSION 2 (non public donc pourra être modifiée)**
  /// Ajoute les colonnes de personnalisation du carousel
  Future<void> _migrateToVersion2(Database db) async {
    // Ajout des colonnes pour les catégories de rédaction
    await db.execute('''
      ALTER TABLE redaction_categories 
      ADD COLUMN is_display INTEGER DEFAULT 1
    ''');

    await db.execute('''
      ALTER TABLE redaction_categories 
      ADD COLUMN display_order INTEGER DEFAULT 0
    ''');

    // Ajout des colonnes pour les catégories de tags
    await db.execute('''
      ALTER TABLE tag_categories 
      ADD COLUMN is_display INTEGER DEFAULT 1
    ''');

    await db.execute('''
      ALTER TABLE tag_categories 
      ADD COLUMN display_order INTEGER DEFAULT 0
    ''');

    // Mise à jour des ordres par défaut
    await _setDefaultDisplayOrders(db);
  }

  /// **DÉFINITION DES ORDRES D'AFFICHAGE PAR DÉFAUT**
  /// Assigne un ordre logique aux catégories existantes
  Future<void> _setDefaultDisplayOrders(Database db) async {
    // Ordre des catégories de rédaction
    final redactionOrders = {'dream_notation': 1, 'dream_notation_feeling': 2};

    for (final entry in redactionOrders.entries) {
      await db.update(
        'redaction_categories',
        {'display_order': entry.value},
        where: 'name = ?',
        whereArgs: [entry.key],
      );
    }

    // Ordre des catégories de tags
    final tagOrders = {
      'location': 1,
      'actor': 2,
      'previous_day_event': 3,
      'previous_day_feeling': 4,
      'dream_feeling': 5,
    };

    for (final entry in tagOrders.entries) {
      await db.update(
        'tag_categories',
        {'display_order': entry.value},
        where: 'name = ?',
        whereArgs: [entry.key],
      );
    }
  }
}
