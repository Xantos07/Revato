import 'package:flutter/material.dart';
import 'package:revato_app/services/business/statistics_business_service.dart';

class StatisticsViewModel extends ChangeNotifier {
  final StatisticsBusinessService _statisticsService;

  StatisticsViewModel({StatisticsBusinessService? statisticsService})
    : _statisticsService = statisticsService ?? StatisticsBusinessService() {
    _loadAllStatistics();
  }

  // **ÉTAT PRIVÉ**
  bool _isLoading = true;
  Map<String, dynamic> _generalStats = {};
  Map<String, dynamic> _tagStats = {};
  Map<String, dynamic> _temporalStats = {};

  // **GETTERS PUBLICS**
  bool get isLoading => _isLoading;
  Map<String, dynamic> get generalStats => Map.unmodifiable(_generalStats);
  Map<String, dynamic> get tagStats => Map.unmodifiable(_tagStats);
  Map<String, dynamic> get temporalStats => Map.unmodifiable(_temporalStats);

  // **PROPRIÉTÉS CALCULÉES POUR L'AFFICHAGE**

  /// Nombre total de rêves
  int get totalDreams => _generalStats['totalDreams'] ?? 0;

  /// Rêves par jour (moyenne)
  double get dreamsPerDay => _generalStats['dreamsPerDay'] ?? 0.0;

  /// Rêves par semaine (moyenne)
  double get dreamsPerWeek => _generalStats['dreamsPerWeek'] ?? 0.0;

  /// Rêves par mois (moyenne)
  double get dreamsPerMonth => _generalStats['dreamsPerMonth'] ?? 0.0;

  /// Richesse du contenu (% de rêves avec rédactions)
  int get contentRichness => _generalStats['contentRichness'] ?? 0;

  /// Nombre de rêves avec rédactions
  int get dreamsWithRedactions => _generalStats['dreamsWithRedactions'] ?? 0;

  /// Streak actuel (jours consécutifs)
  int get currentStreak => _generalStats['currentStreak'] ?? 0;

  /// Plus long streak (record)
  int get longestStreak => _generalStats['longestStreak'] ?? 0;

  /// Rêves récents (7 derniers jours)
  int get recentDreams => _generalStats['recentDreams'] ?? 0;

  /// Date du premier rêve
  DateTime? get firstDreamDate => _generalStats['firstDreamDate'];

  /// Date du dernier rêve
  DateTime? get lastDreamDate => _generalStats['lastDreamDate'];

  /// Top tags avec leur nombre d'utilisations
  Map<String, int> get topTags =>
      Map<String, int>.from(_tagStats['topTags'] ?? {});

  /// Nombre total de tags différents
  int get totalTags => _tagStats['totalTags'] ?? 0;

  /// Moyenne de tags par rêve
  double get avgTagsPerDream => _tagStats['avgTagsPerDream'] ?? 0.0;

  /// Rêves par mois
  Map<String, int> get dreamsByMonth =>
      Map<String, int>.from(_temporalStats['dreamsByMonth'] ?? {});

  /// Rêves par jour de la semaine
  Map<String, int> get dreamsByWeekday =>
      Map<String, int>.from(_temporalStats['dreamsByWeekday'] ?? {});

  /// **CHARGEMENT DES DONNÉES**

  Future<void> _loadAllStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger toutes les statistiques en parallèle
      final results = await Future.wait([
        _statisticsService.getGeneralStats(),
        _statisticsService.getTagStats(),
        _statisticsService.getTemporalStats(),
      ]);

      _generalStats = results[0];
      _tagStats = results[1];
      _temporalStats = results[2];

      debugPrint('Statistiques chargées:');
      debugPrint('- ${totalDreams} rêves au total');
      debugPrint('- ${totalTags} tags différents');
      debugPrint('- ${topTags.length} top tags');
    } catch (e) {
      debugPrint('Erreur lors du chargement des statistiques: $e');
      _generalStats = {};
      _tagStats = {};
      _temporalStats = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// **MÉTHODES PUBLIQUES**

  /// Recharge toutes les statistiques
  Future<void> refreshStatistics() async {
    await _loadAllStatistics();
  }

  /// Formate un nombre décimal pour l'affichage
  String formatDecimal(double value, {int decimals = 1}) {
    return value.toStringAsFixed(decimals);
  }

  /// Formate une date pour l'affichage
  String formatDate(DateTime? date) {
    if (date == null) return 'Aucune donnée';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Retourne le pourcentage d'un tag par rapport au total
  double getTagPercentage(String tagName) {
    if (topTags.isEmpty) return 0.0;
    final tagCount = topTags[tagName] ?? 0;
    final totalTagsUsed = _tagStats['totalTagsUsed'] ?? 1;
    return (tagCount / totalTagsUsed) * 100;
  }

  /// Retourne la couleur pour un graphique basée sur l'index
  Color getChartColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.deepOrange,
    ];
    return colors[index % colors.length];
  }
}
