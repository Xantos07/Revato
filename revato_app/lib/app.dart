import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/widgets/dream_analysis.dart';
import 'package:revato_app/widgets/dream_list_screen.dart';
import 'package:revato_app/services/navigation_core.dart';
import 'widgets/dream_writing_carousel.dart';

class RevatoApp extends StatelessWidget {
  const RevatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revato',
      navigatorKey: NavigationCore.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        useMaterial3: true,
      ),
      home: const DreamHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DreamHomeScreen extends StatefulWidget {
  const DreamHomeScreen({super.key});

  @override
  State<DreamHomeScreen> createState() => _DreamHomeScreenState();
}

class _DreamHomeScreenState extends State<DreamHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    NavigationCore.registerTabController(setTab);
  }

  // Permet à NavigationService de changer l'onglet courant
  void setTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
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
          selectedItemColor: Color(0xFF7C3AED),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
