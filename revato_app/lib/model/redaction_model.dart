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
  description; // Description lisible (ex: "notation du rêve", "ressenti du rêve")
  DateTime? createdAt; // Date de création (optionnelle)

  /// **CONSTRUCTEUR**
  /// Crée une instance de RedactionCategory avec les données obligatoires et optionnelles
  RedactionCategory({
    this.id, // ID optionnel (géré par la DB)
    required this.name, // Nom obligatoire (clé technique)
    required this.description, // Description obligatoire (affichage UI)
    this.createdAt, // Date optionnelle
  });

  /// **FACTORY CONSTRUCTOR - DÉSÉRIALISATION**
  /// Convertit les données brutes de la base de données en objet RedactionCategory
  /// Utilisé quand on récupère les catégories depuis SQLite
  factory RedactionCategory.fromMap(Map<String, dynamic> map) {
    return RedactionCategory(
      id: map['id'] as int?, // ID depuis la DB
      name: map['name'] as String, // Nom technique
      description:
          map['description'] as String? ?? '', // Description, vide par défaut
      createdAt:
          map['created_at'] !=
                  null // Parse de la date
              ? DateTime.parse(map['created_at'])
              : null,
    );
  }
}
