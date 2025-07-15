import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_filter_view_model.dart';

class DreamSearchBar extends StatefulWidget {
  final VoidCallback? onOpenFilters; // Callback pour ouvrir les filtres avancés

  const DreamSearchBar({super.key, this.onOpenFilters});

  @override
  State<DreamSearchBar> createState() => _DreamSearchBarState();
}

class _DreamSearchBarState extends State<DreamSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Utiliser WidgetsBinding.instance.addPostFrameCallback pour s'assurer
    // que le context est complètement initialisé avant d'accéder au Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<DreamFilterViewModel>(context, listen: false);
      _searchController.text = vm.searchText;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DreamFilterViewModel>(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche principale
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => vm.updateSearchText(value),
              decoration: InputDecoration(
                hintText: 'Rechercher dans mes rêves...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          vm.updateSearchText('');
                        },
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                      ),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: () {
                          // Ouvrir les filtres avancés
                          widget.onOpenFilters?.call();
                        },
                        icon: Icon(Icons.tune, color: Colors.grey[400]),
                        tooltip: 'Filtres avancés',
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
