import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/themes/theme_provider.dart';

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
    iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
    actions: [
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
