import 'dart:ui';

import 'package:revato_app/model/dream_model.dart';

class GraphViewService {
  List<Map<String, dynamic>> generateGraphData(List<Dream> dreams) {
    return dreams.map((dream) {
      final description = getDreamDescription(dream);
      return {
        'id': dream.id.toString(),
        'label':
            dream.title.length > 15
                ? '${dream.title.substring(0, 15)}...'
                : dream.title,
        'fullTitle': dream.title,
        'description': description,
        'date': dream.createdAt.toIso8601String(),
        'size': getDreamSize(dream),
        'tagsCount': dream.tags.length,
        'redactionsCount': dream.redactions.length,
        'allTags': dream.tags.map((tag) => tag.name).toList(),
        'color': getDreamColor(dream),
      };
    }).toList();
  }

  List<Map<String, dynamic>> generateLinks(List<Dream> dreams) {
    final links = <Map<String, dynamic>>[];
    for (int i = 0; i < dreams.length; i++) {
      for (int j = i + 1; j < dreams.length; j++) {
        if (areRelated(dreams[i], dreams[j])) {
          links.add({
            'source': dreams[i].id.toString(),
            'target': dreams[j].id.toString(),
            'strength': getRelationStrength(dreams[i], dreams[j]),
          });
        }
      }
    }
    return links;
  }

  /// Calcule la force de la relation entre deux rêves
  double getRelationStrength(Dream dream1, Dream dream2) {
    double strength = 0.1;

    // Plus proche temporellement = plus fort
    final daysDiff = dream1.createdAt.difference(dream2.createdAt).inDays.abs();
    if (daysDiff <= 1)
      strength += 0.8;
    else if (daysDiff <= 3)
      strength += 0.5;
    else if (daysDiff <= 7)
      strength += 0.3;

    // Tags communs = plus fort
    final tags1 = dream1.tags.map((tag) => tag.name.toLowerCase()).toSet();
    final tags2 = dream2.tags.map((tag) => tag.name.toLowerCase()).toSet();
    final commonTags = tags1.intersection(tags2);

    // Plus il y a de tags en commun, plus la connexion est forte
    strength += commonTags.length * 0.3;

    return strength.clamp(0.1, 1.0);
  }

  /// Extrait la description principale d'un rêve depuis ses rédactions
  String getDreamDescription(Dream dream) {
    if (dream.redactions.isEmpty) return dream.title;

    // Chercher une rédaction de type "dream_notation" en priorité
    for (final redaction in dream.redactions) {
      return redaction.content;
    }

    // Sinon, prendre la première rédaction disponible
    return dream.redactions.first.content;
  }

  /// Détermine si deux rêves sont liés
  bool areRelated(Dream dream1, Dream dream2) {
    // Vérifier si ils ont des tags en commun
    return haveCommonTags(dream1, dream2);
  }

  /// Vérifie si deux rêves ont des tags en commun
  bool haveCommonTags(Dream dream1, Dream dream2) {
    final tags1 = dream1.tags.map((tag) => tag.name.toLowerCase()).toSet();
    final tags2 = dream2.tags.map((tag) => tag.name.toLowerCase()).toSet();
    final commonTags = tags1.intersection(tags2);

    return commonTags.isNotEmpty;
  }

  String getDreamColor(Dream dream) {
    if (dream.tags.isEmpty) {
      return '#BDBDBD';
    }

    final Map<String, int> categoryCount = {};
    final Map<String, Color> categoryColors = {};

    for (final tag in dream.tags) {
      categoryCount[tag.categoryName] =
          (categoryCount[tag.categoryName] ?? 0) + 1;
      categoryColors[tag.categoryName] =
          tag.color.isNotEmpty
              ? Color(int.parse(tag.color.replaceAll('#', '0xFF')))
              : const Color(0xFFBDBDBD);
    }

    String dominantCategory =
        categoryCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    final Color color =
        categoryColors[dominantCategory] ?? const Color(0xFFBDBDBD);

    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  /// Détermine la taille d'un nœud (basée sur la longueur de la description)
  int getDreamSize(Dream dream) {
    final baseSize = 20;

    // Taille basée sur le nombre de tags
    final sizeBonus = dream.tags.length * 2;

    return baseSize + sizeBonus;
  }
}
