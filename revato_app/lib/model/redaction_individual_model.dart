/// **MODÈLE RÉDACTION INDIVIDUELLE**
/// Représente une rédaction/notation spécifique associée à un rêve.
/// Contrairement à RedactionCategory qui représente les types de notes (ex: "notation du rêve"),
/// Redaction représente le contenu textuel réel écrit par l'utilisateur.
class Redaction {
  // **PROPRIÉTÉS**
  final int? id; // Identifiant unique en base de données (optionnel)
  final String
  content; // Contenu textuel de la rédaction (ce que l'utilisateur a écrit)
  final String
  categoryName; // Nom de la catégorie parente (ex: "dream_notation", "dream_notation_feeling")

  /// **CONSTRUCTEUR**
  /// Crée une instance de Redaction avec les données obligatoires
  Redaction({
    this.id, // ID optionnel (géré par la DB)
    required this.content, // Contenu obligatoire (texte saisi par l'utilisateur)
    required this.categoryName, // Catégorie obligatoire (type de notation)
  });

  /// **FACTORY CONSTRUCTOR - DÉSÉRIALISATION**
  /// Convertit les données brutes de requêtes JOIN en objet Redaction
  /// Utilisé dans DreamService pour assembler les rédactions avec leurs catégories
  factory Redaction.fromMap(Map<String, dynamic> map) {
    return Redaction(
      id: map['id'] as int?, // ID depuis la DB
      content:
          map['content'] as String? ??
          '', // Contenu de la rédaction, vide par défaut
      categoryName:
          map['category_name'] as String? ??
          '', // Nom de catégorie, vide par défaut
    );
  }
}
