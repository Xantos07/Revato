import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      surface: const Color(0xFFF6F6F6), // Couleur de fond des cartes
      primary: const Color(0xFF7C3AED), // Couleur principale
      onPrimary: Colors.white, // Couleur du texte sur les boutons
      secondary: const Color(0xFF7C3AED), // Couleur secondaire
      onSecondary: Colors.white, // Couleur du texte sur les boutons secondaires
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F6F6),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF7C3AED),
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF7C3AED), // Couleur par défaut des icônes
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF7C3AED),
      unselectedItemColor: Colors.grey,
    ),
    cardColor: Colors.white, // Blanc pur au lieu du défaut
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color.fromARGB(255, 255, 255, 255), // Fond du champ
      filled: true,
      hintStyle: const TextStyle(color: Colors.grey), // Couleur du placeholder
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
      ), // Couleur du label
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.black, // Light
          width: 1.5,
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black), // Couleur du texte saisi
    ),
  );
}
