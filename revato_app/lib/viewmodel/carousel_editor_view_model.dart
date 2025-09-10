import 'package:flutter/material.dart';
import 'package:revato_app/services/business/category_business_service.dart';
import '../model/redaction_model.dart';
import '../model/tag_model.dart';

class CarouselEditorViewModel extends ChangeNotifier {
  final CategoryBusinessService _categoryBusinessService;

  CarouselEditorViewModel({CategoryBusinessService? categoryBusinessService})
    : _categoryBusinessService =
          categoryBusinessService ?? CategoryBusinessService();

  List<RedactionCategory> _redactionCategories = [];
  List<TagCategory> _tagCategories = [];
  bool _isLoading = true;

  // Getters
  List<RedactionCategory> get redactionCategories => _redactionCategories;
  List<TagCategory> get tagCategories => _tagCategories;
  bool get isLoading => _isLoading;

  /// **INITIALISATION**
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _redactionCategories =
          await _categoryBusinessService.getAllRedactionCategories();
      _tagCategories = await _categoryBusinessService.getAllTagCategories(
        orderBy: 'display_order ASC, id ASC',
      );
    } catch (e) {
      debugPrint('Erreur lors du chargement des catégories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **GESTION DE LA VISIBILITÉ**
  Future<void> toggleRedactionDisplay(int categoryId, bool isDisplay) async {
    await _categoryBusinessService.toggleRedactionCategoryDisplay(
      categoryId,
      isDisplay,
    );

    // Mettre à jour localement
    final index = _redactionCategories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _redactionCategories[index] = RedactionCategory(
        id: _redactionCategories[index].id,
        name: _redactionCategories[index].name,
        displayName: _redactionCategories[index].displayName,
        description: _redactionCategories[index].description,
        isDisplay: isDisplay,
        displayOrder: _redactionCategories[index].displayOrder,
        createdAt: _redactionCategories[index].createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> toggleTagDisplay(int categoryId, bool isDisplay) async {
    await _categoryBusinessService.toggleTagCategoryDisplay(
      categoryId,
      isDisplay,
    );

    // Mettre à jour localement
    final index = _tagCategories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      _tagCategories[index] = TagCategory(
        id: _tagCategories[index].id,
        name: _tagCategories[index].name,
        displayName: _tagCategories[index].displayName,
        description: _tagCategories[index].description,
        color: _tagCategories[index].color,
        isDisplay: isDisplay,
        displayOrder: _tagCategories[index].displayOrder,
        createdAt: _tagCategories[index].createdAt,
      );
      notifyListeners();
    }
  }

  /// **RÉORGANISATION**
  Future<void> reorderRedactionCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final item = _redactionCategories.removeAt(oldIndex);
    _redactionCategories.insert(newIndex, item);

    // Sauvegarder en base
    final categoryIds =
        _redactionCategories
            .map((c) => c.id)
            .where((id) => id != null)
            .cast<int>()
            .toList();
    await _categoryBusinessService.reorderRedactionCategories(categoryIds);

    notifyListeners();
  }

  Future<void> reorderTagCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final item = _tagCategories.removeAt(oldIndex);
    _tagCategories.insert(newIndex, item);

    // Sauvegarder en base
    final categoryIds =
        _tagCategories
            .map((c) => c.id)
            .where((id) => id != null)
            .cast<int>()
            .toList();
    await _categoryBusinessService.reorderTagCategories(categoryIds);

    notifyListeners();
  }

  /// **AJOUT DE NOUVELLES CATÉGORIES**
  Future<void> addRedactionCategory({
    required String name,
    required String displayName,
    String? description,
  }) async {
    final id = await _categoryBusinessService.addRedactionCategory(
      name: name,
      displayName: displayName,
      description: description,
    );

    // Ajouter localement
    _redactionCategories.add(
      RedactionCategory(
        id: id,
        name: name,
        displayName: displayName,
        description: description ?? '',
        isDisplay: true,
        displayOrder: 999,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  Future<void> addTagCategory({
    required String name,
    required String displayName,
    required String description,
    String? color,
  }) async {
    final id = await _categoryBusinessService.addTagCategory(
      name: name,
      displayName: displayName,
      description: description,
      color: color,
    );

    // Ajouter localement
    _tagCategories.add(
      TagCategory(
        id: id,
        name: name,
        displayName: displayName,
        description: description,
        color: color ?? '#7C3AED',
        isDisplay: true,
        displayOrder: 999,
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
  }

  /// **MODIFICATION DE CATÉGORIE TAG**
  Future<void> updateTagCategory(TagCategory updatedCategory) async {
    await _categoryBusinessService.updateTagCategory(updatedCategory);

    // Mettre à jour localement
    final index = _tagCategories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _tagCategories[index] = updatedCategory;
      notifyListeners();
    }
  }

  Future<void> updateRedactionCategory(
    RedactionCategory updatedCategory,
  ) async {
    await _categoryBusinessService.updateRedactionCategory(updatedCategory);

    // Mettre à jour localement
    final index = _redactionCategories.indexWhere(
      (c) => c.id == updatedCategory.id,
    );
    if (index != -1) {
      _redactionCategories[index] = updatedCategory;
      notifyListeners();
    }
  }

  /// **SUPPRESSION DE CATÉGORIES**
  Future<void> deleteTagCategory(int categoryId) async {
    await _categoryBusinessService.deleteTagCategory(categoryId);

    // Supprimer localement
    _tagCategories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  Future<void> deleteRedactionCategory(int categoryId) async {
    await _categoryBusinessService.deleteRedactionCategory(categoryId);

    // Supprimer localement
    _redactionCategories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }
}
