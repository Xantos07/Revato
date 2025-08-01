import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/dream_service.dart';

class GraphViewModel extends ChangeNotifier {
  final DreamService _dreamService;

  GraphViewModel({DreamService? dreamService})
    : _dreamService = dreamService ?? DreamService();

  // État privé
  bool _isLoading = true;
  String? _errorMessage;
  List<Dream> _dreams = [];
  List<Map<String, dynamic>> _nodes = [];
  List<Map<String, dynamic>> _links = [];

  // Getters publics
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Dream> get dreams => _dreams;
  List<Map<String, dynamic>> get nodes => _nodes;
  List<Map<String, dynamic>> get links => _links;

  /// Charge tous les rêves et génère les données du graphique
  Future<void> loadDreams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dreams = await _dreamService.getAllDreamsWithTagsAndRedactions();
      _generateGraphData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des rêves: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Génère les données du graphique à partir des rêves
  void _generateGraphData() {
    _nodes.clear();
    _links.clear();

    // Créer les nœuds à partir des rêves
    for (int i = 0; i < _dreams.length; i++) {
      final dream = _dreams[i];
      final description = _getDreamDescription(dream);

      _nodes.add({
        'id': dream.id.toString(),
        'label':
            dream.title.length > 15
                ? '${dream.title.substring(0, 15)}...'
                : dream.title,
        'fullTitle': dream.title,
        'description': description,
        'date': dream.createdAt.toIso8601String(),
        'size': _getDreamSize(dream),
        'tagsCount': dream.tags.length,
        'redactionsCount': dream.redactions.length,
        'allTags': dream.tags.map((tag) => tag.name).toList(),
        'color': _getDreamColorHex(),
      });
    }

    // Créer des liens basés sur des critères (exemple: proximité temporelle, mots-clés similaires)
    _generateLinks();
  }

  /// Obtient la couleur d'un rêve pour le nœud
  /// Utilise une logique simple basée sur le nombre de tags
  String _getDreamColorHex() {
    // Exemple : retourne "#FF4AB1" (rose)
    return '#FF4AB1';
  }

  /// Extrait la description principale d'un rêve depuis ses rédactions
  String _getDreamDescription(Dream dream) {
    if (dream.redactions.isEmpty) return dream.title;

    // Chercher une rédaction de type "dream_notation" en priorité
    for (final redaction in dream.redactions) {
      return redaction.content;
    }

    // Sinon, prendre la première rédaction disponible
    return dream.redactions.first.content;
  }

  /// Détermine la taille d'un nœud (basée sur la longueur de la description)
  int _getDreamSize(Dream dream) {
    final baseSize = 20;

    // Taille basée sur le nombre de tags
    final sizeBonus = dream.tags.length * 2;

    return baseSize + sizeBonus;
  }

  /// Génère des liens entre les rêves basés sur des critères
  void _generateLinks() {
    for (int i = 0; i < _dreams.length; i++) {
      for (int j = i + 1; j < _dreams.length; j++) {
        if (_areRelated(_dreams[i], _dreams[j])) {
          _links.add({
            'source': _dreams[i].id.toString(),
            'target': _dreams[j].id.toString(),
            'strength': _getRelationStrength(_dreams[i], _dreams[j]),
          });
        }
      }
    }
  }

  /// Détermine si deux rêves sont liés
  bool _areRelated(Dream dream1, Dream dream2) {
    // Vérifier si ils ont des tags en commun
    return _haveCommonTags(dream1, dream2);
  }

  /// Vérifie si deux rêves ont des tags en commun
  bool _haveCommonTags(Dream dream1, Dream dream2) {
    final tags1 = dream1.tags.map((tag) => tag.name.toLowerCase()).toSet();
    final tags2 = dream2.tags.map((tag) => tag.name.toLowerCase()).toSet();
    final commonTags = tags1.intersection(tags2);

    return commonTags.isNotEmpty;
  }

  /// Calcule la force de la relation entre deux rêves
  double _getRelationStrength(Dream dream1, Dream dream2) {
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

  /// Obtient les informations détaillées d'un rêve par son ID
  Dream? getDreamById(String dreamId) {
    try {
      final id = int.parse(dreamId);
      return _dreams.firstWhere((dream) => dream.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtient les statistiques du graphique
  Map<String, dynamic> getGraphStats() {
    return {
      'totalDreams': _dreams.length,
      'totalConnections': _links.length,
      'avgConnectionsPerDream':
          _dreams.isNotEmpty ? _links.length / _dreams.length : 0.0,
    };
  }
}
