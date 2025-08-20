import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/themes/theme_provider.dart';
import 'package:revato_app/Screen/about_screen.dart';

AppBar buildDreamAppBar({
  required String title,
  required BuildContext context,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: 1.2,
      ),
    ),
    elevation: 0,
    centerTitle: true,

    actions: [
      // Menu hamburger avec À propos
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'about') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          }
        },
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('À propos'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
      ),
      // Bouton thème
      Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color:
                  themeProvider.isDarkMode
                      ? Colors.white
                      : const Color(0xFF7C3AED),
            ),
            onPressed: () {
              final newMode =
                  themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark;
              themeProvider.setThemeMode(newMode);
            },
          );
        },
      ),
    ],
  );
}
