/// **MODÈLE TAG INDIVIDUEL**
/// Représente un tag spécifique associé à un rêve.
/// Contrairement à TagCategory qui représente les catégories (ex: "location"),
/// Tag représente une instance concrète (ex: "plage", "forêt", "maison").
class Tag {
  // **PROPRIÉTÉS**
  final int? id; // Identifiant unique en base de données (optionnel)
  final String name; // Nom du tag (ex: "plage", "maman", "stress")
  final String
  categoryName; // Nom de la catégorie parente (ex: "location", "actor")
  final String color; // Couleur hex pour l'affichage (optionnelle)

  /// **CONSTR  UCTEUR**
  /// Crée une instance de Tag avec les données obligatoires
  Tag({
    this.id, // ID optionnel (géré par la DB)
    required this.name, // Nom obligatoire (valeur saisie par l'utilisateur)
    required this.categoryName, // Catégorie obligatoire (pour l'organisation)
    required this.color, // Couleur obligatoire (pour l'affichage)
  });

  /// **FACTORY CONSTRUCTOR - DÉSÉRIALISATION**
  /// Convertit les données brutes de requêtes JOIN en objet Tag
  /// Utilisé dans DreamService pour assembler les tags avec leurs catégories
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?, // ID depuis la DB
      name: map['name'] as String? ?? '', // Nom du tag, vide par défaut
      categoryName:
          map['category_name'] as String? ??
          '', // Nom de catégorie, vide par défaut
      color:
          map['color'] as String? ?? '#FFFFFF', // Couleur hex, blanc par défaut
    );
  }
}
