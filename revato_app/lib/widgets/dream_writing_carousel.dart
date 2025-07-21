import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/viewmodel/dream_writing_view_model.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamCarouselNavigation.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamCarouselStepper.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamNotePage.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamTagsPage.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamTitlePage.dart';

class DreamWritingCarousel extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onSubmit;

  const DreamWritingCarousel({super.key, required this.onSubmit});

  @override
  State<DreamWritingCarousel> createState() => _DreamWritingCarouselState();
}

class _DreamWritingCarouselState extends State<DreamWritingCarousel> {
  // Controllers créés une seule fois et réutilisés
  late final TextEditingController _titleController;
  final Map<String, TextEditingController> _noteControllers = {};
  bool _listenersSetup = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  // Configurer les listeners une seule fois après la création du ViewModel
  void _setupListeners(DreamWritingViewModel vm) {
    if (_listenersSetup) return;

    // Listener pour le titre
    _titleController.addListener(() {
      if (_titleController.text != vm.dreamTitle) {
        vm.updateTitle(_titleController.text);
      }
    });

    // Listeners pour les notes
    for (final category in vm.availableCategoriesRedaction) {
      final controller = _getNoteController(category.name);
      controller.addListener(() {
        if (controller.text != vm.getNoteForCategory(category.name)) {
          vm.setNoteForCategory(category.name, controller.text);
        }
      });
    }

    _listenersSetup = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Méthode pour obtenir ou créer un contrôleur de note
  TextEditingController _getNoteController(String categoryName) {
    if (!_noteControllers.containsKey(categoryName)) {
      _noteControllers[categoryName] = TextEditingController();
    }
    return _noteControllers[categoryName]!;
  }

  // Synchronisation bidirectionnelle entre contrôleurs et ViewModel
  void _synchronizeControllers(DreamWritingViewModel vm) {
    // Synchroniser le titre (Controller → ViewModel)
    if (_titleController.text != vm.dreamTitle &&
        !_titleController.text.isEmpty) {
      vm.updateTitle(_titleController.text);
    }
    // Synchroniser le titre (ViewModel -> Controller)
    else if (_titleController.text != vm.dreamTitle &&
        vm.dreamTitle.isNotEmpty) {
      _titleController.text = vm.dreamTitle;
    }

    // Synchroniser les notes pour chaque catégorie
    for (final category in vm.availableCategoriesRedaction) {
      final controller = _getNoteController(category.name);
      final vmText = vm.getNoteForCategory(category.name);

      // Controller -> ViewModel
      if (controller.text != vmText && controller.text.isNotEmpty) {
        vm.setNoteForCategory(category.name, controller.text);
      }
      // ViewModel -> Controller
      else if (controller.text != vmText && vmText.isNotEmpty) {
        controller.text = vmText;
      }
    }
  }

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

          // Configuration des listeners et synchronisation
          _setupListeners(vm);
          _synchronizeControllers(vm);

          final pages = <Widget>[
            // Page titre avec contrôleur stable
            DreamTitlePage(controller: _titleController),

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
              final noteController = _getNoteController(category.name);
              return DreamNotePage(
                title: category.description,
                label: 'écrit sur : ${category.description}...',
                controller: noteController,
              );
            }),
          ];

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),
                DreamCarouselStepper(page: vm.currentPage, total: pages.length),
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
                      key: ValueKey(vm.currentPage),
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
                        child: pages[vm.currentPage],
                      ),
                    ),
                  ),
                ),
                DreamCarouselNavigation(
                  page: vm.currentPage,
                  totalPages: pages.length,
                  onPrev: () {
                    if (vm.currentPage > 0) vm.setPage(vm.currentPage - 1);
                  },
                  onNext: () {
                    if (vm.currentPage == 0 && vm.dreamTitle.isEmpty) {
                      // Si on est sur la première page et que le titre est vide, on ne peut pas
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Le titre ne peut pas être vide.'),
                        ),
                      );
                      return;
                    }
                    if (vm.currentPage < pages.length - 1) {
                      vm.setPage(vm.currentPage + 1);
                    } else {
                      widget.onSubmit(vm.collectData());
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
