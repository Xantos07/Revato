import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_writing_view_model.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamCarouselNavigation.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamCarouselStepper.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamNotePage.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamTagsPage.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamTitlePage.dart';

class DreamWritingCarousel extends StatelessWidget {
  final void Function(Map<String, dynamic> data) onSubmit;

  const DreamWritingCarousel({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DreamWritingViewModel(),
      child: Consumer<DreamWritingViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final pages = <Widget>[
            // Page titre (fixe)
            DreamTitlePage(controller: vm.titleController),

            ...vm.availableCategories.map((category) {
              return FutureBuilder<List<String>>(
                future: vm.getTagsForCategory(category.name),
                builder: (context, snapshot) {
                  final existingTags = snapshot.data ?? [];
                  final localTags = vm.getLocalTagsForCategory(
                    category.name,
                  ); // Tags en cours
                  return DreamTagsPage(
                    title: category.description ?? category.name,
                    label: 'Ajoute des ${category.name}...',
                    tags: localTags, //  Tags locaux, pas ceux de la base
                    onChanged:
                        (tags) => vm.setTagsForCategory(category.name, tags),
                    chipColor: category.getFlutterColor(),
                    chipTextColor: category.getTextColor(),
                    addButtonColor: category.getButtonColor(),
                    existingTags:
                        existingTags, // Tags de la base pour l'autocomplétion
                  );
                },
              );
            }),

            ...vm.availableCategoriesRedaction.map((category) {
              return DreamNotePage(
                title: category.description,
                label: 'écrit sur : ${category.description}...',
                controller: vm.getNoteController(
                  category.name,
                ), // ← Utilise name au lieu de description
              );
            }),
          ];

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),
                DreamCarouselStepper(page: vm.page, total: pages.length),
                const SizedBox(height: 10),
                // Carrousel de pages de saisie (AnimatedSwitcher sur l'index)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (child, animation) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                    child: Card(
                      key: ValueKey(vm.page),
                      elevation: 10,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: Colors.white.withOpacity(0.97),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: pages[vm.page],
                      ),
                    ),
                  ),
                ),
                DreamCarouselNavigation(
                  page: vm.page,
                  totalPages: pages.length,
                  onPrev: () {
                    if (vm.page > 0) vm.setPage(vm.page - 1);
                  },
                  onNext: () {
                    if (vm.page == 0 && vm.titleController.text.isEmpty) {
                      // Si on est sur la première page et que le titre est vide, on ne peut pas
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Le titre ne peut pas être vide.'),
                        ),
                      );
                      return;
                    }
                    if (vm.page < pages.length - 1) {
                      vm.setPage(vm.page + 1);
                    } else {
                      onSubmit(vm.collectData());
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
