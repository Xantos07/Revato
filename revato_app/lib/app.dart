import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/services/dream_service.dart';
import 'package:revato_app/widgets/dream_list_screen.dart';
import 'package:revato_app/database/database.dart';
import 'widgets/dream_writing_carousel.dart';

class RevatoApp extends StatelessWidget {
  const RevatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revato',
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

  static void goToDreamList(BuildContext context) {
    final state = context.findAncestorStateOfType<_DreamHomeScreenState>();
    if (state != null) {
      state.setState(() => state._selectedIndex = 1);
    }
  }

  @override
  void initState() {
    super.initState();
    print('>>> Test début');
    AppDatabase().database
        .then((db) async {
          print('>>> DB ouverte');
          final tagCategories = await db.query('tag_categories');
          final notations = await db.query('redaction_categories');
          print('Catégories de tags: $tagCategories');
          print('Notations: $notations');
        })
        .catchError((e, s) {
          print('>>> ERREUR DB: $e');
          print(s);
        });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [DreamWritingScreen(), DreamListScreen()];
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

class DreamWritingScreen extends StatelessWidget {
  const DreamWritingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon rêve',
          style: TextStyle(
            color: Color(0xFF7C3AED),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: DreamWritingCarousel(
            onSubmit: (data) async {
              try {
                await DreamService().insertDreamWithData(data);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rêve enregistré !')),
                );
                _DreamHomeScreenState.goToDreamList(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'enregistrement : $e'),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
