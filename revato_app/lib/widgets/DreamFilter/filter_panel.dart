import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';
import 'package:revato_app/widgets/DreamFilter/tab/filter_content_tab.dart';
import 'package:revato_app/widgets/DreamFilter/tab/filter_date_tab.dart';
import 'package:revato_app/widgets/DreamFilter/tab/filter_tags_tab.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel>
    with TickerProviderStateMixin {
  bool isChecked = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Charger les catégories de tags au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<DreamFilterViewModel>(context, listen: false);
      if (vm.availableTagCategories.isEmpty) {
        vm.loadTagCategories();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DreamFilterViewModel>(
      builder: (context, vm, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle du bottom sheet
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filtres avancés',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (vm.hasActiveFilters)
                      TextButton.icon(
                        onPressed: () => vm.clearAll(),
                        icon: const Icon(Icons.clear),
                        label: const Text('Réinitialiser'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Date & Tri'),
                  Tab(text: 'Tags'),
                  Tab(text: 'Contenu'),
                ],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    buildDateTab(context, vm),
                    buildTagsTab(context, vm),
                    buildContentTab(vm),
                  ],
                ),
              ),

              //trier titre

              //filtrer par période
            ],
          ),
        );
      },
    );
  }
}
