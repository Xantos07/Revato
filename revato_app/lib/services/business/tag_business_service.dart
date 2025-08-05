import 'package:revato_app/services/data/tag_repository.dart';
import 'package:revato_app/services/data/category_repository.dart';

/// Service contenant la logique métier des tags
class TagBusinessService {
  final TagRepository _tagRepo;
  final CategoryRepository _categoryRepo;

  TagBusinessService({TagRepository? tagRepo, CategoryRepository? categoryRepo})
    : _tagRepo = tagRepo ?? TagRepository(),
      _categoryRepo = categoryRepo ?? CategoryRepository();

  // Logique métier pure
  List<String> filterValidTags(List<String> tags) {
    return tags.where((tag) => tag.trim().isNotEmpty).toSet().toList();
  }

  Future<bool> renameTagGlobally(String oldName, String newName) async {
    try {
      final category = await _tagRepo.getTagCategory(oldName);
      if (category == null) {
        print('Tag "$oldName" not found in any category');
        return false;
      }

      await _tagRepo.renameTag(oldName, newName, category);
      print(
        'Tag renamed globally: "$oldName" -> "$newName" in category "$category"',
      );
      return true;
    } catch (e) {
      print('Error renaming tag globally: $e');
      return false;
    }
  }

  Future<List<String>> searchTags(String searchText) async {
    if (searchText.isEmpty) return [];

    final allTags = await _tagRepo.getAllAvailableTags();
    return allTags
        .where((tag) => tag.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  Future<List<String>> getTagsForCategory(String categoryName) async {
    return await _tagRepo.getTagsForCategory(categoryName);
  }

  Future<List<String>> getAllAvailableTags() async {
    return await _tagRepo.getAllAvailableTags();
  }

  Future<Map<String, String>> getTagsWithCategories() async {
    final categories = await _categoryRepo.getVisibleTagCategories();
    final Map<String, String> tagToCategory = {};

    for (final category in categories) {
      final tagsInCategory = await _tagRepo.getTagsForCategory(category.name);
      for (final tag in tagsInCategory) {
        tagToCategory[tag] = category.name;
      }
    }

    return tagToCategory;
  }

  void updateTagsLocally(
    Map<String, List<String>> tagsByCategory,
    String oldName,
    String newName,
  ) {
    for (final category in tagsByCategory.keys) {
      final tags = tagsByCategory[category] ?? [];
      final updatedTags =
          tags.map((tag) => tag == oldName ? newName : tag).toList();
      tagsByCategory[category] = updatedTags;
    }
  }
}
