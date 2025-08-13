import 'package:revato_app/services/business/dream_business_service.dart';
import 'package:revato_app/model/dream_model.dart';

/// Service pour calculer les statistiques de l'application
class StatisticsBusinessService {
  final DreamBusinessService _dreamService;

  StatisticsBusinessService({DreamBusinessService? dreamService})
    : _dreamService = dreamService ?? DreamBusinessService();

  /// **STATISTIQUES GÉNÉRALES**

  /// Calcule les statistiques de base des rêves
  Future<Map<String, dynamic>> getGeneralStats() async {
    try {
      final dreams = await _dreamService.getAllDreamsWithTagsAndRedactions();

      if (dreams.isEmpty) {
        return _getEmptyStats();
      }

      // Calcul des statistiques de base
      final totalDreams = dreams.length;
      final firstDream = dreams.reduce(
        (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
      );
      final daysSinceFirst =
          DateTime.now().difference(firstDream.createdAt).inDays + 1;

      // Calcul de la fréquence moyenne
      final dreamsPerDay = totalDreams / daysSinceFirst;
      final dreamsPerWeek = dreamsPerDay * 7;
      final dreamsPerMonth = dreamsPerDay * 30;

      // Calcul de la richesse du contenu
      final dreamsWithRedactions =
          dreams.where((d) => d.redactions.isNotEmpty).length;
      final contentRichness = (dreamsWithRedactions / totalDreams) * 100;

      // Calcul du streak actuel (jours consécutifs avec au moins un rêve)
      final currentStreak = _calculateCurrentStreak(dreams);
      final longestStreak = _calculateLongestStreak(dreams);

      // Calcul de la régularité (rêves dans les 7 derniers jours)
      final recentDreams =
          dreams
              .where((d) => DateTime.now().difference(d.createdAt).inDays <= 7)
              .length;

      return {
        'totalDreams': totalDreams,
        'daysSinceFirst': daysSinceFirst,
        'dreamsPerDay': dreamsPerDay,
        'dreamsPerWeek': dreamsPerWeek,
        'dreamsPerMonth': dreamsPerMonth,
        'contentRichness': contentRichness.round(),
        'dreamsWithRedactions': dreamsWithRedactions,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'recentDreams': recentDreams,
        'firstDreamDate': firstDream.createdAt,
        'lastDreamDate':
            dreams
                .reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
                .createdAt,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques générales: $e');
      return _getEmptyStats();
    }
  }

  /// **STATISTIQUES DES TAGS**

  /// Calcule les statistiques des tags les plus utilisés
  Future<Map<String, dynamic>> getTagStats() async {
    try {
      final dreams = await _dreamService.getAllDreamsWithTagsAndRedactions();

      if (dreams.isEmpty) {
        return {
          'topTags': <String, int>{},
          'totalTags': 0,
          'avgTagsPerDream': 0.0,
        };
      }

      // Compter les occurrences de chaque tag
      final Map<String, int> tagCounts = {};
      int totalTagsUsed = 0;

      for (final dream in dreams) {
        for (final tag in dream.tags) {
          tagCounts[tag.name] = (tagCounts[tag.name] ?? 0) + 1;
          totalTagsUsed++;
        }
      }

      // Trier les tags par fréquence (top 10)
      final sortedTags =
          tagCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      final topTags = Map.fromEntries(sortedTags.take(10));
      final avgTagsPerDream = totalTagsUsed / dreams.length;

      return {
        'topTags': topTags,
        'totalTags': tagCounts.length,
        'totalTagsUsed': totalTagsUsed,
        'avgTagsPerDream': avgTagsPerDream,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques de tags: $e');
      return {
        'topTags': <String, int>{},
        'totalTags': 0,
        'avgTagsPerDream': 0.0,
      };
    }
  }

  /// **STATISTIQUES TEMPORELLES**

  /// Calcule la distribution des rêves par mois
  Future<Map<String, dynamic>> getTemporalStats() async {
    try {
      final dreams = await _dreamService.getAllDreamsWithTagsAndRedactions();

      if (dreams.isEmpty) {
        return {
          'dreamsByMonth': <String, int>{},
          'dreamsByWeekday': <String, int>{},
        };
      }

      // Rêves par mois
      final Map<String, int> dreamsByMonth = {};
      final Map<String, int> dreamsByWeekday = {
        'Lundi': 0,
        'Mardi': 0,
        'Mercredi': 0,
        'Jeudi': 0,
        'Vendredi': 0,
        'Samedi': 0,
        'Dimanche': 0,
      };

      final weekdays = [
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi',
        'Dimanche',
      ];

      for (final dream in dreams) {
        // Grouper par mois
        final monthKey =
            '${dream.createdAt.year}-${dream.createdAt.month.toString().padLeft(2, '0')}';
        dreamsByMonth[monthKey] = (dreamsByMonth[monthKey] ?? 0) + 1;

        // Grouper par jour de la semaine
        final weekdayIndex = dream.createdAt.weekday - 1; // weekday starts at 1
        final weekdayName = weekdays[weekdayIndex];
        dreamsByWeekday[weekdayName] = dreamsByWeekday[weekdayName]! + 1;
      }

      return {
        'dreamsByMonth': dreamsByMonth,
        'dreamsByWeekday': dreamsByWeekday,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques temporelles: $e');
      return {
        'dreamsByMonth': <String, int>{},
        'dreamsByWeekday': <String, int>{},
      };
    }
  }

  /// **MÉTHODES PRIVÉES**

  Map<String, dynamic> _getEmptyStats() {
    return {
      'totalDreams': 0,
      'daysSinceFirst': 0,
      'dreamsPerDay': 0.0,
      'dreamsPerWeek': 0.0,
      'dreamsPerMonth': 0.0,
      'contentRichness': 0,
      'dreamsWithRedactions': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'recentDreams': 0,
      'firstDreamDate': null,
      'lastDreamDate': null,
    };
  }

  /// Calcule le streak actuel (jours consécutifs avec au moins un rêve)
  int _calculateCurrentStreak(List<Dream> dreams) {
    if (dreams.isEmpty) return 0;

    // Organiser les rêves par date (jour seulement)
    final dreamDates = <DateTime>{};
    for (final dream in dreams) {
      final dateOnly = DateTime(
        dream.createdAt.year,
        dream.createdAt.month,
        dream.createdAt.day,
      );
      dreamDates.add(dateOnly);
    }

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    int streak = 0;
    DateTime currentDate = today;

    // Vérifier si on a un rêve aujourd'hui ou hier pour démarrer le streak
    if (!dreamDates.contains(today) &&
        !dreamDates.contains(today.subtract(const Duration(days: 1)))) {
      return 0;
    }

    // Si pas de rêve aujourd'hui, commencer par hier
    if (!dreamDates.contains(today)) {
      currentDate = today.subtract(const Duration(days: 1));
    }

    // Compter les jours consécutifs en remontant
    while (dreamDates.contains(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calcule le plus long streak (record de jours consécutifs)
  int _calculateLongestStreak(List<Dream> dreams) {
    if (dreams.isEmpty) return 0;

    // Organiser les rêves par date (jour seulement)
    final dreamDates = <DateTime>{};
    for (final dream in dreams) {
      final dateOnly = DateTime(
        dream.createdAt.year,
        dream.createdAt.month,
        dream.createdAt.day,
      );
      dreamDates.add(dateOnly);
    }

    final sortedDates = dreamDates.toList()..sort();

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;

      if (diff == 1) {
        // Jour consécutif
        currentStreak++;
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      } else {
        // Interruption du streak
        currentStreak = 1;
      }
    }

    return maxStreak;
  }
}
