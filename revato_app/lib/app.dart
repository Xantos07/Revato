import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/Screen/dream_editor_carousel.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/Screen/dream_analysis.dart';
import 'package:revato_app/Screen/dream_list_screen.dart';
import 'package:revato_app/services/navigation_core.dart';
import 'themes/theme_provider.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'Screen/dream_writing_carousel.dart';

class RevatoApp extends StatelessWidget {
  const RevatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Revato',
            navigatorKey: NavigationCore.navigatorKey,
            themeMode: themeProvider.themeMode,

            // Thème clair
            theme: LightTheme.theme,

            // Thème sombre
            darkTheme: DarkTheme.theme,

            home: const DreamHomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class DreamHomeScreen extends StatefulWidget {
  const DreamHomeScreen({super.key});

  @override
  State<DreamHomeScreen> createState() => _DreamHomeScreenState();
}

class _DreamHomeScreenState extends State<DreamHomeScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    NavigationCore.registerTabController(setTab);
  }

  void setTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DreamEditorCarousel(),
      DreamWritingCarousel(),
      DreamListScreen(),
      DreamAnalysis(),
    ];

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DreamFilterViewModel()),
      ],
      child: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.panorama_rounded),
              label: 'Editer',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Rédiger'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'Mes rêves',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analyses',
            ),
          ],
          // Ces propriétés sont maintenant définies dans le thème
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
