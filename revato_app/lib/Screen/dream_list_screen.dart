import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/Screen/graph_web_view.dart';

import 'package:revato_app/widgets/DreamFilter/filter_panel.dart';
import 'package:revato_app/widgets/DreamFilter/search_bar.dart';
import 'package:revato_app/widgets/DreamList/DreamSummaryCard.dart';
import 'package:revato_app/widgets/dream_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/viewmodel/dream_list_view_model.dart';
import 'package:revato_app/viewmodel/graph_view_model.dart';

class DreamListScreen extends StatefulWidget {
  const DreamListScreen({super.key});

  // Clé globale pour accéder à l'état depuis l'extérieur
  static final GlobalKey<_DreamListScreenState> globalKey =
      GlobalKey<_DreamListScreenState>();

  // Méthode statique pour recharger depuis n'importe où
  static void reloadDreams() {
    print('Tentative de reload depuis méthode statique');

    globalKey.currentState?._loadDreams();
  }

  @override
  State<DreamListScreen> createState() => _DreamListScreenState();
}

class _DreamListScreenState extends State<DreamListScreen> {
  late final DreamFilterViewModel _filterViewModel;
  late final DreamListViewModel _dreamListViewModel;
  List<Dream> _allDreams = [];
  bool _isLoading = true;
  bool _showGraph = false; // Toggle entre liste et graphique

  static const String _showGraphKey = 'showGraphDreamList';

  @override
  void initState() {
    super.initState();
    _filterViewModel = DreamFilterViewModel(); // Créer une seule fois
    _dreamListViewModel = DreamListViewModel();
    _loadDreams();
    _loadShowGraphPref();
  }

  Future<void> _loadShowGraphPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showGraph = prefs.getBool(_showGraphKey) ?? false;
    });
  }

  Future<void> _saveShowGraphPref(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showGraphKey, value);
  }

  @override
  void dispose() {
    _filterViewModel.dispose();
    super.dispose();
  }

  Future<void> _loadDreams() async {
    try {
      print('_loadDreams appelée');

      final dreams =
          await _dreamListViewModel.getAllDreamsWithTagsAndRedactions();
      setState(() {
        _allDreams = dreams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Erreur lors du chargement des rêves: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      key: DreamListScreen.globalKey,

      value: _filterViewModel,
      child: Scaffold(
        appBar: buildDreamAppBar(title: 'Mes rêves', context: context),
        body: Column(
          children: [
            // Search bar for filtering dreams
            DreamSearchBar(
              onOpenFilters: () {
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
                  // Forcer une reconstruction après fermeture du panel
                  debugPrint('📱 Panel fermé - forcer refresh');
                  setState(() {}); // Force rebuild du StatefulWidget
                });
              },
            ),

            //Correction
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _saveShowGraphPref(false);
                    setState(() => _showGraph = false);
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Liste'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_showGraph ? Theme.of(context).primaryColor : null,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _saveShowGraphPref(true);
                    setState(() => _showGraph = true);
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Graphique'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _showGraph ? Theme.of(context).primaryColor : null,
                  ),
                ),
              ],
            ),

            Expanded(
              child:
                  _showGraph
                      ? GraphWebView(
                        viewModel: GraphViewModel(),
                      ) // Afficher le graphique
                      : _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _allDreams.isEmpty
                      ? const Center(child: Text('Aucun rêve enregistré.'))
                      : Consumer<DreamFilterViewModel>(
                        builder: (context, vm, child) {
                          debugPrint(
                            '🔄 Consumer rebuild - Tags: ${vm.selectedTags}',
                          );

                          // Filtrage des rêves en temps réel
                          final filteredDreams = vm.filterDreams(_allDreams);

                          if (filteredDreams.isEmpty &&
                              vm.hasActiveFiltersIncludingSearch) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Aucun rêve ne correspond aux filtres',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => vm.clearAll(),
                                    child: const Text('Effacer les filtres'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredDreams.length,
                            // Optimisations de performance
                            physics: const BouncingScrollPhysics(),
                            cacheExtent: 1000, // Cache plus d'éléments
                            itemBuilder: (context, index) {
                              final dream = filteredDreams[index];
                              return DreamSummaryCard(
                                key: ValueKey(
                                  dream.id,
                                ), // Clé unique pour éviter les rebuilds
                                dream: dream,
                                onDreamUpdated: () {
                                  print(
                                    'Callback reçu - rechargement des rêves',
                                  );
                                  _loadDreams();
                                },
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
