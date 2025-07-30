/// **MODÈLE REDACTION CATEGORY**
/// Représente une catégorie de rédaction/notation dans l'application.
/// Les catégories permettent d'organiser les différents types de notes qu'un utilisateur
/// peut associer à ses rêves (ex: "notation du rêve", "ressenti du rêve").
class RedactionCategory {
  // **PROPRIÉTÉS**
  int? id; // Identifiant unique en base de données (optionnel car auto-généré)
  final String
  name; // Nom de la catégorie (ex: "dream_notation", "dream_notation_feeling")
  final String
  displayName; // Nom affiché dans l'UI (ex: "Notation du rêve", "Ressenti du rêve")
  final String
  description; // Description lisible (ex: "notation du rêve", "ressenti du rêve")
  final bool isDisplay;
  final int displayOrder;
  DateTime? createdAt; // Date de création (optionnelle)

  /// **CONSTRUCTEUR**
  /// Crée une instance de RedactionCategory avec les données obligatoires et optionnelles
  RedactionCategory({
    this.id, // ID optionnel (géré par la DB)
    required this.name, // Nom obligatoire (clé technique)
    required this.displayName, // Nom affiché obligatoire (pour l'UI)
    required this.description, // Description obligatoire (affichage UI)
    this.isDisplay = true, // Par défaut, la catégorie est affichée
    this.displayOrder = 0, // Par défaut, l'ordre est à 0
    this.createdAt, // Date optionnelle
  });

  /// **FACTORY CONSTRUCTOR - DÉSÉRIALISATION**
  /// Convertit les données brutes de la base de données en objet RedactionCategory
  /// Utilisé quand on récupère les catégories depuis SQLite
  factory RedactionCategory.fromMap(Map<String, dynamic> map) {
    return RedactionCategory(
      id: map['id'] as int?, // ID depuis la DB
      name: map['name'] as String, // Nom technique
      displayName:
          map['display_name'] as String? ?? '', // Nom affiché, vide par défaut
      description:
          map['description'] as String? ?? '', // Description, vide par défaut
      isDisplay: map['is_display'] == 1, // Convertit 1/0 en booléen
      displayOrder:
          map['display_order'] as int? ?? 0, // Ordre d'affichage, 0 par défaut
      createdAt:
          map['created_at'] !=
                  null // Parse de la date
              ? DateTime.parse(map['created_at'])
              : null,
    );
  }
}
