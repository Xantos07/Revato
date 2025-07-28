import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/dream_service.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/widgets/DreamFilter/filter_panel.dart';
import 'package:revato_app/widgets/DreamFilter/search_bar.dart';
import 'package:revato_app/widgets/DreamList/DreamSummaryCard.dart';

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
  final DreamService _dreamService = DreamService();
  late final DreamFilterViewModel _filterViewModel;
  List<Dream> _allDreams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filterViewModel = DreamFilterViewModel(); // Créer une seule fois
    _loadDreams();
  }

  @override
  void dispose() {
    _filterViewModel.dispose();
    super.dispose();
  }

  Future<void> _loadDreams() async {
    try {
      print('_loadDreams appelée'); // Pour debug

      final dreams = await _dreamService.getAllDreamsWithTagsAndRedactions();
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
        appBar: AppBar(
          title: const Text(
            'Mes rêves',
            style: TextStyle(
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF7C3AED)),
        ),
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
            Expanded(
              child:
                  _isLoading
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
                                    child: const Text(
                                      'Effacer les filtres',
                                      style: TextStyle(
                                        color: Color(0xFF7C3AED),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredDreams.length,
                            itemBuilder: (context, index) {
                              final dream = filteredDreams[index];
                              return DreamSummaryCard(
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
