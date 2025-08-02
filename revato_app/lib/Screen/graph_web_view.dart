import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/widgets/DreamDetail/DreamDetail.dart';
import 'package:revato_app/widgets/DreamFilter/filter_panel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:revato_app/viewmodel/graph_view_model.dart';

/// Widget pour afficher un graphique interactif D3.js dans une WebView
class GraphWebView extends StatefulWidget {
  final GraphViewModel? viewModel;

  const GraphWebView({Key? key, this.viewModel}) : super(key: key);

  @override
  _GraphWebViewState createState() => _GraphWebViewState();
}

class _GraphWebViewState extends State<GraphWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isInitialized = false;
  late GraphViewModel _viewModel;
  late final DreamFilterViewModel _filterViewModel;
  // ========== LIFECYCLE ==========

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? GraphViewModel();
    _filterViewModel = DreamFilterViewModel();
    _initWebView();
    _loadDreams();
  }

  @override
  void dispose() {
    _filterViewModel.dispose();
    super.dispose();
  }

  /// Charge les rêves depuis la base de données
  Future<void> _loadDreams() async {
    await _viewModel.loadDreams();
    if (_isInitialized) {
      _sendDataToWebView();
    }
  }

  // ========== INITIALISATION WEBVIEW ==========
  /// Initialise la WebView avec le template HTML et configure les communications
  void _initWebView() async {
    // Charger le template HTML depuis les assets
    final htmlContent = await rootBundle.loadString(
      'assets/graph_template.html',
    );

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                  _isInitialized = true;
                });
                // Envoyer les données initiales
                _sendDataToWebView();
              },
            ),
          )
          ..addJavaScriptChannel(
            'FlutterGraph',
            onMessageReceived: (JavaScriptMessage message) {
              _handleWebViewMessage(message.message);
            },
          )
          ..loadHtmlString(htmlContent);
  }

  // ========== COMMUNICATION FLUTTER ↔ WEBVIEW ==========
  /// Envoie les données du graphique vers la WebView
  void _sendDataToWebView() {
    if (_controller == null) return;

    // Appliquer les filtres avec l'instance locale
    final filteredDreams = _filterViewModel.filterDreams(_viewModel.dreams);

    // Filtrer les nœuds selon les rêves filtrés
    final filteredNodes =
        _viewModel.nodes.where((node) {
          final nodeId = int.tryParse(node['id']);
          return nodeId != null &&
              filteredDreams.any((dream) => dream.id == nodeId);
        }).toList();

    // Filtrer les liens pour ne garder que ceux entre les nœuds filtrés
    final filteredNodeIds = filteredNodes.map((node) => node['id']).toSet();
    final filteredLinks =
        _viewModel.links
            .where(
              (link) =>
                  filteredNodeIds.contains(link['source']) &&
                  filteredNodeIds.contains(link['target']),
            )
            .toList();

    final data = {'nodes': filteredNodes, 'links': filteredLinks};

    _controller!.runJavaScript('''
      window.updateGraph(${jsonEncode(data)});
    ''');
  }

  /// Traite les messages reçus de la WebView
  void _handleWebViewMessage(String message) {
    try {
      final data = jsonDecode(message);

      switch (data['type']) {
        case 'nodeClick':
          _onNodeClick(data['nodeId']);
          break;
        case 'nodeHover':
          _onNodeHover(data['nodeId']);
          break;
        case 'graphReady':
          print('Graph is ready!');
          break;
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  // ========== GESTIONNAIRES D'ÉVÉNEMENTS ==========
  /// Gère le clic sur un nœud
  void _onNodeClick(String nodeId) {
    final dream = _viewModel.getDreamById(nodeId);
    if (dream == null) return;

    showDialog(
      context: context,
      builder: (context) => DreamDetail(dream: dream),
    );
  }

  /// Gère le survol d'un nœud
  void _onNodeHover(String nodeId) {
    print('Node hovered: $nodeId');
  }

  // ========== CONTRÔLES DE NAVIGATION ==========

  /// Affiche les statistiques du graphique
  void _showStats() {
    final stats = _viewModel.getGraphStats();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Statistiques du Graphique'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total des rêves: ${stats['totalDreams']}'),
                Text('Connexions trouvées: ${stats['totalConnections']}'),
                Text(
                  'Connexions moyennes par rêve: ${stats['avgConnectionsPerDream'].toStringAsFixed(1)}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fermer'),
              ),
            ],
          ),
    );
  }

  /// Effectue un zoom avant sur le graphique
  void _zoomIn() {
    if (_controller == null) return;

    _controller!.runJavaScript('''
      window.zoomIn();
    ''');
  }

  /// Effectue un zoom arrière sur le graphique
  void _zoomOut() {
    if (_controller == null) return;

    _controller!.runJavaScript('''
      window.zoomOut();
    ''');
  }

  // ========== INTERFACE UTILISATEUR ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graphique des Rêves'),
        actions: [
          IconButton(
            onPressed: () => _showFilterPanel(context),
            icon: Icon(Icons.filter_alt),
            tooltip: 'Filtres',
          ),
          IconButton(
            onPressed: _showStats,
            icon: Icon(Icons.analytics),
            tooltip: 'Statistiques',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_controller != null && _isInitialized)
            WebViewWidget(controller: _controller!)
          else
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Initialisation du graphique...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading && _isInitialized)
            Center(child: CircularProgressIndicator()),
          // Contrôles de navigation flottants
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  onPressed: _zoomIn,
                  heroTag: "zoom_in",
                  tooltip: "Zoomer",
                  child: Icon(Icons.zoom_in),
                ),
                SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: _zoomOut,
                  heroTag: "zoom_out",
                  tooltip: "Dézoomer",
                  child: Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche le panneau de filtres
  void _showFilterPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ChangeNotifierProvider.value(
            value: _filterViewModel,
            child: FilterPanel(),
          ),
    ).then((_) {
      // Rafraîchir le graphe après fermeture du panel de filtres
      _sendDataToWebView();
    });
  }
}
