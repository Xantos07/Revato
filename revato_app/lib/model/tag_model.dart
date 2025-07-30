// Imports nécessaires pour la gestion des couleurs et interfaces
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// **MODÈLE TAG CATEGORY**
/// Représente une catégorie de tags dans l'application.
/// Les catégories permettent d'organiser les tags par thème
/// (ex: "location", "actor", "previous_day_event", etc.)
class TagCategory {
  // **PROPRIÉTÉS PRINCIPALES**
  int? id; // Identifiant unique en base de données (optionnel car auto-généré)
  String name; // Nom technique de la catégorie (ex: "dream_location")
  String? displayName; // Nom affiché dans l'UI (ex: "Lieux", "Acteurs")
  String? description; // Description lisible (ex: "Lieux et environnements")
  String? color; // Couleur hex pour l'affichage (ex: "#E57373")
  bool isDisplay = true; // Indique si la catégorie est affichée dans l'UI
  int displayOrder = 0; // Ordre d'affichage des catégories
  DateTime createdAt; // Date de création

  /// **CONSTRUCTEUR**
  /// Crée une instance de TagCategory avec les données obligatoires et optionnelles
  TagCategory({
    this.id, // ID optionnel (géré par la DB)
    required this.name, // Nom obligatoire (clé technique)
    this.displayName, // Nom affiché optionnel (pour l'UI)
    this.description, // Description optionnelle (affichage UI)
    this.color, // Couleur optionnelle (hex)
    this.isDisplay = true, // Par défaut, la catégorie est affichée
    this.displayOrder = 0, // Par défaut, l'ordre est à 0
    DateTime? createdAt, // Date optionnelle
  }) : createdAt = createdAt ?? DateTime.now(); // Date actuelle par défaut

  /// **FACTORY CONSTRUCTOR - DÉSÉRIALISATION**
  /// Convertit les données brutes de la base de données en objet TagCategory
  /// Utilisé quand on récupère les catégories depuis SQLite
  factory TagCategory.fromMap(Map<String, dynamic> map) {
    return TagCategory(
      id: map['id'] as int?, // ID depuis la DB
      name: map['name'] as String, // Nom technique
      displayName: map['display_name'] as String?, // Nom affiché optionnel
      description: map['description'] as String?, // Description optionnelle
      color: map['color'] as String?, // Couleur hex optionnelle
      isDisplay: map['is_display'] as bool, // Affichage optionnel
      displayOrder: map['display_order'] as int? ?? 0, // Ordre d'affichage
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ), // Parse de la date
    );
  }

  /// **SÉRIALISATION**
  /// Convertit l'instance en Map pour la sauvegarde en base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'is_display': isDisplay ? 1 : 0, // Convertit booléen en int
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(), // Format ISO pour la DB
    };
  }

  /// **UTILITAIRE COULEUR - CONVERSION HEX → FLUTTER COLOR**
  /// Convertit la couleur hex stockée en DB en objet Color utilisable par Flutter
  Color getFlutterColor() {
    // Couleur par défaut si aucune couleur définie
    if (color == null || color!.isEmpty) {
      return const Color(0xFF90CAF9); // Bleu clair par défaut
    }

    try {
      // Nettoyer et parser la couleur hex
      final colorString = color!.replaceAll('#', ''); // Supprimer le #
      final colorValue = int.parse(
        'FF$colorString',
        radix: 16,
      ); // Ajouter opacité FF
      return Color(colorValue);
    } catch (e) {
      // Retourner la couleur par défaut en cas d'erreur de parsing
      return const Color(0xFF90CAF9);
    }
  }

  /// **UTILITAIRE COULEUR - BOUTON**
  /// Génère la couleur pour les boutons de cette catégorie
  Color getButtonColor() {
    return getFlutterColor(); // Utilise la même couleur pour les boutons
  }

  /// **UTILITAIRE COULEUR - TEXTE ADAPTATIF**
  /// Détermine automatiquement la couleur du texte (blanc ou noir)
  /// selon la luminance de la couleur de fond pour assurer la lisibilité
  Color getTextColor() {
    final color = getFlutterColor();
    // Calculer la luminance (0.0 = noir, 1.0 = blanc)
    final luminance = color.computeLuminance();
    // Si la couleur est claire (luminance > 0.5) → texte noir
    // Si la couleur est foncée (luminance <= 0.5) → texte blanc

    //return luminance > 0.5 ? Colors.black : .white;Colors
    return const Color(0xFFFFFFFF); // Blanc pour les couleurs foncées
  }
}
