import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/dream_service.dart';
import 'package:revato_app/services/dream_filter_viewmodel.dart';
import 'package:revato_app/widgets/DreamFilter/filter_panel.dart';
import 'package:revato_app/widgets/DreamFilter/search_bar.dart';
import 'package:revato_app/widgets/DreamList/DreamSummaryCard.dart';

class DreamListScreen extends StatelessWidget {
  const DreamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DreamService _dreamService = DreamService();
    return ChangeNotifierProvider(
      create: (_) => DreamFilterViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mon rêve',
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
                // Ici tu ouvres ton panneau, ex:
                showModalBottomSheet(
                  context: context,
                  builder: (context) => FilterPanel(),
                );
              },
            ),
            Expanded(
              child: FutureBuilder<List<Dream>>(
                future: _dreamService.getAllDreamsWithTagsAndRedactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final dreams = snapshot.data ?? [];
                  if (dreams.isEmpty) {
                    return const Center(child: Text('Aucun rêve enregistré.'));
                  }
                  // Filtrage ici avec le texte du ViewModel
                  final vm = Provider.of<DreamFilterViewModel>(context);
                  final filteredDreams =
                      dreams
                          .where(
                            (dream) => dream.title.toLowerCase().contains(
                              vm.searchText.toLowerCase(),
                            ),
                          )
                          .toList();
                  if (filteredDreams.isEmpty) {
                    return const Center(
                      child: Text('Aucun rêve ne correspond à la recherche.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDreams.length,
                    itemBuilder: (context, index) {
                      final dream = filteredDreams[index];
                      return DreamSummaryCard(dream: dream);
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
