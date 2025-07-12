import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TagCategory {
  int? id;
  String name;
  String? description;
  String? color;
  DateTime createdAt;

  TagCategory({
    this.id,
    required this.name,
    this.description,
    this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Crée une instance TagCategory depuis les données de la base
  factory TagCategory.fromMap(Map<String, dynamic> map) {
    return TagCategory(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convertit l'instance en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convertit la couleur hex de la DB en Color Flutter
  Color getFlutterColor() {
    if (color == null || color!.isEmpty) {
      return const Color(0xFF90CAF9);
    }

    try {
      // Enlever le # si présent et ajouter l'opacité FF
      final colorString = color!.replaceAll('#', '');
      final colorValue = int.parse('FF$colorString', radix: 16);
      return Color(colorValue);
    } catch (e) {
      return const Color(0xFF90CAF9); // Couleur par défaut en cas d'erreur
    }
  }

  /// Génère automatiquement une couleur de bouton plus foncée
  Color getButtonColor() {
    return getFlutterColor();
  }

  /// Détermine automatiquement la couleur du texte (blanc ou noir)
  Color getTextColor() {
    final color = getFlutterColor();
    // Calculer la luminance pour déterminer si utiliser du texte blanc ou noir
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
