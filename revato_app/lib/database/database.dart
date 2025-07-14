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
      version: 1, // Version actuelle du schéma
      onCreate: _createDatabase, // Callback de création si DB n'existe pas
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
          title TEXT NOT NULL,                   
          created_at TEXT NOT NULL,              
          updated_at TEXT                        
        )
    ''');

    // **TABLE CATÉGORIES DE RÉDACTIONS**
    // Définit les types de notes possibles (ex: "notation du rêve", "ressenti")
    await db.execute('''
      CREATE TABLE redaction_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,             
        description TEXT,                     
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
    await db.execute('''
        CREATE TABLE tag_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,             
          description TEXT,                      
          color TEXT,                            
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
      {'name': 'dream_notation', 'description': 'notation du rêve'},
      {'name': 'dream_notation_feeling', 'description': 'ressenti du rêve'},
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
        'description': 'Lieux et environnements',
        'color': '#E57373', // Rouge clair
      },
      {
        'name': 'actor', // Personnes présentes
        'description': 'Personnes et personnages',
        'color': '#64B5F6', // Bleu clair
      },
      {
        'name': 'previous_day_event', // Événements récents influents
        'description': 'Événements de la veille',
        'color': '#81C784', // Vert clair
      },
      {
        'name': 'previous_day_feeling', // État émotionnel précédent
        'description': 'Ressentis de la veille',
        'color': '#BA68C8', // Violet clair
      },
      {
        'name': 'dream_feeling', // Émotions dans le rêve
        'description': 'Ressentis du rêve',
        'color': '#FFD54F', // Jaune clair
      },
    ];

    // **INSERTION EN BASE**
    for (final category in categories) {
      await db.insert('tag_categories', {...category, 'created_at': now});
    }
  }
}
