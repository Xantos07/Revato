import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';

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
    final vm = Provider.of<DreamFilterViewModel>(context, listen: false);
    vm.availableTagCategories;
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
          decoration: const BoxDecoration(
            color: Colors.white,
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
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => {Navigator.pop(context)},
                      icon: const Icon(Icons.bookmark_border),
                      tooltip: 'Filtres sauvegardés',
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                      ),
                    ),
                    IconButton(
                      onPressed: () => {Navigator.pop(context)},
                      icon: const Icon(Icons.help_outline),
                      tooltip: 'Aide',
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                      ),
                    ),
                    if (vm.hasActiveFilters)
                      TextButton.icon(
                        onPressed: () => vm.clearAll(),
                        icon: const Icon(Icons.clear),
                        label: const Text('Réinitialiser'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                        ),
                      ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF7C3AED),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF7C3AED),
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
                    _buildDateTab(vm),
                    _buildTagsTab(vm),
                    _buildContentTab(vm),
                  ],
                ),
              ),

              //trier titre

              //filtrer par période

              // Bouton pour fermer le panneau
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateTab(DreamFilterViewModel vm) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Trier par date'),
          value: vm.isSortedByDate,
          onChanged: (value) {
            vm.toggleSortByDate(value);
          },
        ),
        // Autres options de tri...
      ],
    );
  }

  Widget _buildTagsTab(DreamFilterViewModel vm) {
    return Column(children: [Wrap(spacing: 8, runSpacing: 8)]);
  }

  Widget _buildContentTab(DreamFilterViewModel vm) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Trier par date'),
          value: vm.isSortedByDate,
          onChanged: (value) {
            vm.toggleSortByDate(value);
          },
        ),
        // Autres options de tri...
      ],
    );
  }
}
