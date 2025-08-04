import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/model/tag_model.dart';

class DreamWritingService {
  Map<String, dynamic> formatDreamData(
    String title,
    Map<String, String> redactions,
    Map<String, List<String>> tags,
  ) {
    return {
      'title': title.trim().isEmpty ? "Rêve sans titre" : title.trim(),
      'redactionsByCategory': Map<String, String>.from(redactions),
      'tagsByCategory': Map<String, List<String>>.from(tags),
    };
  }

  Map<String, dynamic> mapDreamToEditingState(
    Dream dream,
    List<TagCategory> tagCategories,
    List<RedactionCategory> redactionCategories,
  ) {
    final state = <String, dynamic>{
      'title': dream.title,
      'redactionsByCategory': <String, String>{},
      'tagsByCategory': <String, List<String>>{},
    };

    // Logique de mapping dream ->état d'édition
    for (final category in redactionCategories) {
      try {
        final redaction = dream.redactions.firstWhere(
          (r) => r.categoryName == category.name,
        );
        state['redactionsByCategory'][category.name] = redaction.content;
      } catch (e) {
        state['redactionsByCategory'][category.name] = '';
      }
    }

    // Construire les tags par catégorie à partir des tags du rêve
    for (final category in tagCategories) {
      final tagsForCategory =
          dream.tags
              .where((t) => t.categoryName == category.name)
              .map((t) => t.name)
              .toList();
      state['tagsByCategory'][category.name] = tagsForCategory;
    }

    return state;
  }

  void addTagLocally(
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

  // DreamWritingService
  List<String> filterValidTags(List<String> tags) {
    return tags.toSet().toList();
  }
}
