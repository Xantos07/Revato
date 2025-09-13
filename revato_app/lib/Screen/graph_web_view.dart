import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/widgets/DreamDetail/DreamDetail.dart';
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
  DreamFilterViewModel? _filterViewModel;
  // ========== LIFECYCLE ==========

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? GraphViewModel();
    // Ne pas créer une nouvelle instance, on récupère celle du Provider
    _initWebView();
    _loadDreams();
  }

  @override
  void didChangeDependencies() {
    // Récupérer le DreamFilterViewModel du Provider parent
    _filterViewModel = Provider.of<DreamFilterViewModel>(
      context,
      listen: false,
    );
    super.didChangeDependencies();
    _sendThemeToWebView();
  }

  @override
  void dispose() {
    // Ne pas disposer le Provider parent ici
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
                _sendThemeToWebView();
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
    if (_filterViewModel == null) return;
    final filteredDreams = _filterViewModel!.filterDreams(_viewModel.dreams);
    final graphData = _viewModel.getFilteredGraphData(filteredDreams);

    _controller!.runJavaScript('''
      window.updateGraph(${jsonEncode(graphData)});
    ''');
  }

  void _sendThemeToWebView() {
    if (_controller == null) return;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Récupérer les vraies couleurs du thème
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;

    // Convertir en hex
    final backgroundColorHex =
        '#${backgroundColor.value.toRadixString(16).substring(2)}';
    final textColorHex = '#${textColor.value.toRadixString(16).substring(2)}';

    print(
      'Sending theme to WebView - Background: $backgroundColorHex, Text: $textColorHex',
    );
    _controller!.runJavaScript(
      "window.setBackgroundColor('$backgroundColorHex');",
    );
    _controller!.runJavaScript("window.setTextNodeColor('$textColorHex');");
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
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Stack(
          children: [
            if (_controller != null && _isInitialized)
              Padding(
                padding: EdgeInsets.only(),
                child: WebViewWidget(controller: _controller!),
              )
            else
              Container(
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
      ),
    );
  }
}
