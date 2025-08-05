import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/business/dream_business_service.dart';
import 'package:revato_app/services/utils/graph_service.dart';

class GraphViewModel extends ChangeNotifier {
  final DreamBusinessService _dreamBusinessService;
  final GraphViewService _graphViewService;

  GraphViewModel({
    DreamBusinessService? dreamService,
    GraphViewService? graphViewService,
  }) : _dreamBusinessService = dreamService ?? DreamBusinessService(),
       _graphViewService = graphViewService ?? GraphViewService();

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
      _dreams = await _dreamBusinessService.getAllDreamsWithTagsAndRedactions();
      _nodes = _graphViewService.generateGraphData(_dreams);
      _links = _graphViewService.generateLinks(_dreams);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des rêves: $e';
      _isLoading = false;
      notifyListeners();
    }
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

  /// Retourne les nœuds et liens filtrés selon la liste de rêves
  Map<String, dynamic> getFilteredGraphData(List<Dream> filteredDreams) {
    final filteredNodes =
        _nodes.where((node) {
          final nodeId = int.tryParse(node['id']);
          return nodeId != null &&
              filteredDreams.any((dream) => dream.id == nodeId);
        }).toList();

    final filteredNodeIds = filteredNodes.map((node) => node['id']).toSet();
    final filteredLinks =
        _links
            .where(
              (link) =>
                  filteredNodeIds.contains(link['source']) &&
                  filteredNodeIds.contains(link['target']),
            )
            .toList();

    return {'nodes': filteredNodes, 'links': filteredLinks};
  }
}
