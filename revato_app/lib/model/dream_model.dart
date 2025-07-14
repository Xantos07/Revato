// Imports des modèles liés : tags individuels et rédactions individuelles
import 'package:revato_app/model/redaction_individual_model.dart';
import 'package:revato_app/model/tag_individual_model.dart';

/// **MODÈLE DREAM**
/// Représente un rêve dans l'application avec toutes ses données associées.
/// Ce modèle sert de structure de données principale pour stocker et manipuler
/// les informations d'un rêve en mémoire.
class Dream {
  // **PROPRIÉTÉS PRINCIPALES**
  final int id; // Identifiant unique du rêve dans la base de données
  final String title; // Titre du rêve saisi par l'utilisateur
  final DateTime createdAt; // Date et heure de création du rêve

  // **COLLECTIONS LIÉES** (relations avec d'autres entités)
  List<Tag> tags; // Liste des tags associés à ce rêve
  List<Redaction> redactions; // Liste des rédactions/notations

  /// **CONSTRUCTEUR**
  /// Crée une instance de Dream avec les données obligatoires et optionnelles
  Dream({
    required this.id, // ID obligatoire (généré par la DB)
    required this.title, // Titre obligatoire
    required this.createdAt, // Date obligatoire
    List<Tag>? tags, // Tags optionnels (peut être null)
    List<Redaction>? redactions, // Rédactions optionnelles (peut être null)
  }) : tags = tags ?? [], // Si null, crée une liste vide
       redactions = redactions ?? []; // Si null, crée une liste vide

  /// **FACTORY CONSTRUCTOR - DÉSÉRIALISATION**
  /// Convertit les données brutes de la base de données (Map) en objet Dream
  /// Utilisé quand on récupère des données depuis SQLite
  factory Dream.fromMap(Map<String, dynamic> map) {
    return Dream(
      // Récupère l'ID depuis la colonne 'id' de la DB
      id: map['id'] as int,
      // Récupère le titre, ou met "Sans titre" par défaut si null
      title: map['title'] as String? ?? 'Sans titre',
      // Parse la date depuis la chaîne de caractères stockée en DB
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : DateTime.now(), // Date actuelle si pas de date en DB
    );
    // Note: Les tags et redactions sont chargés séparément par le service
    // car ils nécessitent des requêtes JOIN avec d'autres tables
  }
}
