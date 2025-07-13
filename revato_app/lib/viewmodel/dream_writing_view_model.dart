import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revato_app/database/database.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';

class DreamWritingViewModel extends ChangeNotifier {
  // ViewModel properties and methods
  final TextEditingController titleController = TextEditingController();

  bool isLoading = true;
  Map<String, List<String>> tagsByCategory = {};
  Map<String, TextEditingController> noteControllers = {};
  int page = 0; // Current page index in the carousel

  List<TagCategory> _availableCategories = [];
  List<TagCategory> get availableCategories => _availableCategories;
  List<RedactionCategory> _availableCategoriesRedaction = [];
  List<RedactionCategory> get availableCategoriesRedaction =>
      _availableCategoriesRedaction;
  DreamWritingViewModel() {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();
    try {
      _availableCategories = await AppDatabase().getAllTagCategories();
      _availableCategoriesRedaction =
          await AppDatabase().getAllRedactionCategories();
      print(
        'Catégories chargées: ${_availableCategories.map((c) => c.name).toList()}',
      );
      print(
        'Catégories de rédaction chargées: ${_availableCategoriesRedaction.map((c) => c.name).toList()}',
      );
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // Method to get available categories from the database
  // List<TagCategory> get availableCategories => []; // Fetch from DB

  // Method to get tags for a specific category
  Future<List<String>> getTagsForCategory(String categoryName) {
    return AppDatabase().getTagsForCategory(categoryName);
  }

  List<String> getLocalTagsForCategory(String categoryName) {
    return tagsByCategory[categoryName] ?? [];
  }

  // Method to get existing tags for a specific category
  List<String> getExistingTagsForCategory(String categoryName) {
    return []; // Fetch from DB
  }

  TextEditingController getNoteController(String category) {
    return noteControllers.putIfAbsent(category, () => TextEditingController());
  }

  void setTagsForCategory(String category, List<String> tags) {
    tagsByCategory[category] = tags;
    notifyListeners();
  }

  void setNoteForCategory(String category, String note) {
    noteControllers[category]?.text = note;
    notifyListeners();
  }

  /// Collecte toutes les données dans le format flexible
  Map<String, dynamic> collectData() {
    final data = {
      'title': titleController.text.trim(),
      'redactionByCategory': noteControllers.map(
        (key, controller) => MapEntry(key, controller.text.trim()),
      ),
      'tagsByCategory': Map<String, List<String>>.from(tagsByCategory),
    };

    print('=== DONNÉES COLLECTÉES POUR SAUVEGARDE ===');
    print('Titre: ${data['title']}');
    print('Tags par catégorie:');
    for (final entry
        in (data['tagsByCategory'] as Map<String, List<String>>).entries) {
      if (entry.value.isNotEmpty) {
        print(' - ${entry.key}: ${entry.value}');
      }
    }
    print('Rédactions par catégorie:');
    for (final entry
        in (data['redactionByCategory'] as Map<String, String>).entries) {
      if (entry.value.isNotEmpty) {
        print(' - ${entry.key}: ${entry.value}');
      }
    }
    print('==========================================');

    // Retourne les données collectées
    return data;
  }

  void setPage(int newPage) {
    page = newPage;
    notifyListeners();
  }
}
