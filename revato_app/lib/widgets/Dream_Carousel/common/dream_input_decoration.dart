import 'package:flutter/material.dart';

// ================================
// DÉCORATION COMMUNE POUR LES CHAMPS
// ================================

/// Décoration standard pour tous les champs de saisie du carrousel de rêves
/// Utilisée dans tous les composants de saisie pour maintenir la cohérence visuelle
InputDecoration dreamInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 1.5,
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(
      color: Color.fromARGB(255, 0, 0, 0),
      fontWeight: FontWeight.w300,
    ),
    floatingLabelStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 0, 0, 0),
        width: 2,
      ),
    ),
  );
}
