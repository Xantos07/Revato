import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      surface: const Color.fromARGB(255, 43, 43, 43), // Fond des cartes
      primary: const Color.fromARGB(255, 208, 171, 50),
      onPrimary: Colors.white, // Couleur du texte sur les boutons
      secondary: const Color.fromARGB(255, 208, 171, 50),
      onSecondary: Colors.white, // Couleur du texte sur les boutons secondaires
      seedColor: const Color.fromARGB(255, 208, 171, 50),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 57, 57, 57),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 80, 80, 80),
      foregroundColor: Color.fromARGB(255, 208, 171, 50),
      elevation: 0,
    ),
    iconTheme: const IconThemeData(
      color: Color.fromARGB(255, 237, 195, 58), // Couleur par défaut des icônes
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 67, 67, 67),
      selectedItemColor: Color.fromARGB(255, 208, 171, 50),
      unselectedItemColor: Colors.grey,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color.fromARGB(255, 55, 55, 55), // Fond du champ
      filled: true,
      hintStyle: const TextStyle(color: Colors.grey), // Couleur du placeholder
      labelStyle: const TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
      ), // Couleur du label
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.white, // Light
          width: 1.5,
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
      ), // Couleur du texte saisi
    ),
  );
}
