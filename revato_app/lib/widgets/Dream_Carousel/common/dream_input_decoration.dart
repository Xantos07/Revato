import 'package:flutter/material.dart';

// ================================
// DÉCORATION COMMUNE POUR LES CHAMPS
// ================================

/// Décoration standard pour tous les champs de saisie du carrousel de rêves
/// Utilisée dans tous les composants de saisie pour maintenir la cohérence visuelle
InputDecoration dreamInputDecoration(BuildContext context, String label) {
  // Récupère la couleur de bordure depuis le thème
  final borderColor =
      Theme.of(context).inputDecorationTheme.border?.borderSide.color ??
      (Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black);

  // Récupère la couleur du label depuis le thème
  final labelColor =
      Theme.of(context).inputDecorationTheme.labelStyle?.color ??
      (Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black);

  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    ),
    filled: true,
    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
    labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w300),
    floatingLabelStyle: TextStyle(color: labelColor),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderColor, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderColor, width: 2),
    ),
  );
}
