import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/model/tag_individual_model.dart';
import 'package:revato_app/model/redaction_individual_model.dart';
import 'package:revato_app/model/tag_model.dart';
import 'package:revato_app/model/redaction_model.dart';
import 'package:revato_app/services/data/dream_repository.dart';

/// Service contenant la logique métier des rêves
class DreamBusinessService {
  final DreamRepository _dreamRepo;

  DreamBusinessService({DreamRepository? dreamRepo})
    : _dreamRepo = dreamRepo ?? DreamRepository();

  /// **OPÉRATIONS MÉTIER - RÉCUPÉRATION**
  /// Récupère tous les rêves avec validation et transformation
  Future<List<Dream>> getAllDreamsWithTagsAndRedactions() async {
    try {
      final dreams = await _dreamRepo.getAllDreamsWithAssociations();

      return dreams;
    } catch (e) {
      print('Erreur lors de la récupération des rêves: $e');
      rethrow;
    }
  }

  /// Récupère un rêve spécifique avec validation
  Future<Dream?> getDreamWithTagsAndRedactions(int dreamId) async {
    if (dreamId <= 0) {
      throw ArgumentError('ID de rêve invalide: $dreamId');
    }

    try {
      return await _dreamRepo.getDreamWithAssociations(dreamId);
    } catch (e) {
      print('Erreur lors de la récupération du rêve $dreamId: $e');
      rethrow;
    }
  }

  /// **OPÉRATIONS MÉTIER - CRÉATION ET MODIFICATION**
  /// Crée un nouveau rêve avec validation complète
  Future<int> createDream(Map<String, dynamic> data) async {
    // Valider les données avant création
    final validatedData = validateDreamData(data);

    try {
      final dreamId = await _dreamRepo.insertDreamWithData(validatedData);
      print('Nouveau rêve créé avec ID: $dreamId');
      return dreamId;
    } catch (e) {
      print('Erreur lors de la création du rêve: $e');
      rethrow;
    }
  }

  /// Met à jour un rêve existant avec validation
  Future<void> updateDream(int dreamId, Map<String, dynamic> data) async {
    if (dreamId <= 0) {
      throw ArgumentError('ID de rêve invalide: $dreamId');
    }

    // Valider les données avant mise à jour
    final validatedData = validateDreamData(data);

    try {
      await _dreamRepo.updateDreamWithData(dreamId, validatedData);
      print('Rêve $dreamId mis à jour avec succès');
    } catch (e) {
      print('Erreur lors de la mise à jour du rêve $dreamId: $e');
      rethrow;
    }
  }

  /// **OPÉRATIONS MÉTIER - SUPPRESSION**
  /// Supprime un rêve avec validation et nettoyage
  Future<bool> deleteDream(int dreamId) async {
    if (dreamId <= 0) {
      throw ArgumentError('ID de rêve invalide: $dreamId');
    }

    try {
      final success = await _dreamRepo.deleteDream(dreamId);
      if (success) {
        print('Rêve $dreamId supprimé avec succès');
      } else {
        print('Échec de la suppression du rêve $dreamId');
      }
      return success;
    } catch (e) {
      print('Erreur lors de la suppression du rêve $dreamId: $e');
      return false;
    }
  }

  /// **LOGIQUE MÉTIER - VALIDATION**
  /// Valide les données d'un rêve avant sauvegarde
  Map<String, dynamic> validateDreamData(Map<String, dynamic> data) {
    final validatedData = Map<String, dynamic>.from(data);

    // Valider le titre
    final title = data['title']?.toString().trim() ?? '';
    if (title.isEmpty) {
      throw ArgumentError('Le titre du rêve ne peut pas être vide');
    }
    validatedData['title'] = title;

    // Valider les tags par catégorie
    final tagsByCategory =
        data['tagsByCategory'] as Map<String, List<String>>? ?? {};
    final validatedTags = <String, List<String>>{};

    for (final entry in tagsByCategory.entries) {
      final categoryName = entry.key;
      final tags = entry.value;

      // Filtrer les tags vides et doublons
      final validTags =
          tags
              .where((tag) => tag.trim().isNotEmpty)
              .map((tag) => tag.trim())
              .toSet()
              .toList();

      if (validTags.isNotEmpty) {
        validatedTags[categoryName] = validTags;
      }
    }
    validatedData['tagsByCategory'] = validatedTags;

    // Valider les rédactions par catégorie
    final redactionsByCategory =
        data['redactionsByCategory'] as Map<String, String>? ?? {};
    final validatedRedactions = <String, String>{};

    for (final entry in redactionsByCategory.entries) {
      final categoryName = entry.key;
      final content = entry.value.trim();

      if (content.isNotEmpty) {
        validatedRedactions[categoryName] = content;
      }
    }
    validatedData['redactionsByCategory'] = validatedRedactions;

    return validatedData;
  }

  /// **LOGIQUE MÉTIER - TRANSFORMATION**
  /// Prépare les données pour l'affichage dans l'UI
  Map<String, dynamic> formatDreamForDisplay(Dream dream) {
    return {
      'id': dream.id,
      'title': dream.title,
      'createdAt': dream.createdAt,
      'tagsByCategory': _groupTagsByCategory(dream.tags),
      'redactionsByCategory': _groupRedactionsByCategory(dream.redactions),
      'hasContent': dream.redactions.isNotEmpty || dream.tags.isNotEmpty,
    };
  }

  /// **LOGIQUE MÉTIER - RECHERCHE ET FILTRAGE**
  /// Filtre les rêves selon des critères
  List<Dream> filterDreams(
    List<Dream> dreams, {
    String? searchText,
    List<String>? requiredTags,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return dreams.where((dream) {
      // Filtre par texte
      if (searchText != null && searchText.isNotEmpty) {
        final searchLower = searchText.toLowerCase();
        final titleMatch = dream.title.toLowerCase().contains(searchLower);
        final contentMatch = dream.redactions.any(
          (r) => r.content.toLowerCase().contains(searchLower),
        );
        if (!titleMatch && !contentMatch) return false;
      }

      // Filtre par tags requis
      if (requiredTags != null && requiredTags.isNotEmpty) {
        final dreamTagNames = dream.tags.map((t) => t.name).toSet();
        if (!requiredTags.every((tag) => dreamTagNames.contains(tag))) {
          return false;
        }
      }

      // Filtre par date
      if (fromDate != null && dream.createdAt.isBefore(fromDate)) return false;
      if (toDate != null && dream.createdAt.isAfter(toDate)) return false;

      return true;
    }).toList();
  }

  /// **LOGIQUE MÉTIER - STATISTIQUES**
  /// Calcule des statistiques sur les rêves
  Map<String, dynamic> calculateDreamStatistics(List<Dream> dreams) {
    if (dreams.isEmpty) {
      return {
        'totalDreams': 0,
        'averageTagsPerDream': 0.0,
        'mostUsedTags': <String>[],
        'dreamsPerMonth': <String, int>{},
      };
    }

    // Tags les plus utilisés
    final tagCount = <String, int>{};
    var totalTags = 0;

    for (final dream in dreams) {
      totalTags += dream.tags.length;
      for (final tag in dream.tags) {
        tagCount[tag.name] = (tagCount[tag.name] ?? 0) + 1;
      }
    }

    final sortedTags =
        tagCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // Rêves par mois
    final dreamsPerMonth = <String, int>{};
    for (final dream in dreams) {
      final monthKey =
          '${dream.createdAt.year}-${dream.createdAt.month.toString().padLeft(2, '0')}';
      dreamsPerMonth[monthKey] = (dreamsPerMonth[monthKey] ?? 0) + 1;
    }

    return {
      'totalDreams': dreams.length,
      'averageTagsPerDream': totalTags / dreams.length,
      'mostUsedTags': sortedTags.take(10).map((e) => e.key).toList(),
      'dreamsPerMonth': dreamsPerMonth,
    };
  }

  /// **MÉTHODES PRIVÉES - UTILITAIRES**
  Map<String, List<String>> _groupTagsByCategory(List<Tag> tags) {
    final grouped = <String, List<String>>{};
    for (final tag in tags) {
      grouped.putIfAbsent(tag.categoryName, () => []).add(tag.name);
    }
    return grouped;
  }

  Map<String, String> _groupRedactionsByCategory(List<Redaction> redactions) {
    final grouped = <String, String>{};
    for (final redaction in redactions) {
      grouped[redaction.categoryName] = redaction.content;
    }
    return grouped;
  }

  /// **MÉTHODES D'ÉDITION - EX-DREAMWRITINGSERVICE**

  /// Formate les données pour la sauvegarde
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

  /// Convertit un Dream en état d'édition pour l'UI
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

    // Mapping des rédactions
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

    // Mapping des tags par catégorie
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

  /// Met à jour les tags localement (pour l'UI)
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

  /// Filtre les tags valides (supprime doublons et vides)
  List<String> filterValidTags(List<String> tags) {
    return tags
        .where((tag) => tag.trim().isNotEmpty)
        .map((tag) => tag.trim())
        .toSet()
        .toList();
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
}
