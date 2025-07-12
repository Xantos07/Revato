import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revato_app/database/database.dart';
import 'package:revato_app/model/tag_model.dart';

class DreamWritingViewModel extends ChangeNotifier {
  // ViewModel properties and methods
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dreamNoteController = TextEditingController();
  final TextEditingController feelingNoteController = TextEditingController();
  bool isLoading = true;
  Map<String, List<String>> tagsByCategory = {};
  int page = 0; // Current page index in the carousel

  List<TagCategory> _availableCategories = [];
  List<TagCategory> get availableCategories => _availableCategories;

  DreamWritingViewModel() {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();
    try {
      _availableCategories = await AppDatabase().getAllTagCategories();
      print(
        'Catégories chargées: ${_availableCategories.map((c) => c.name).toList()}',
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

  // Method to set tags for a specific category
  void setTagsForCategory(String categoryName, List<String> tags) {
    // Save to DB
  }

  // Method to get existing tags for a specific category
  List<String> getExistingTagsForCategory(String categoryName) {
    return []; // Fetch from DB
  }

  /// Collecte toutes les données dans le format flexible
  Map<String, dynamic> collectData() {
    final data = {
      'title': titleController.text.trim(),
      'dreamNote': dreamNoteController.text.trim(),
      'feelingNote': feelingNoteController.text.trim(),
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
    print('==========================================');

    return data;
  }

  void setPage(int newPage) {
    page = newPage;
    notifyListeners();
  }
}
