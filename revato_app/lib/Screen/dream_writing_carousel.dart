import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/viewmodel/dream_writing_view_model.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamCarouselNavigation.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamCarouselStepper.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamNotePage.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamTagsPage.dart';
import 'package:revato_app/widgets/Dream_Carousel/DreamTitlePage.dart';
import 'package:revato_app/services/utils/navigation_core.dart';
import 'package:revato_app/widgets/dream_app_bar.dart';

/// **CAROUSEL PRINCIPAL** - Responsabilité : Structure et navigation
class DreamWritingCarousel extends StatefulWidget {
  final Dream? initialDream;
  final void Function(Map<String, dynamic> data)? onSubmit;

  const DreamWritingCarousel({super.key, this.onSubmit, this.initialDream});

  @override
  State<DreamWritingCarousel> createState() => _DreamWritingCarouselState();
}

class _DreamWritingCarouselState extends State<DreamWritingCarousel> {
  late final _dataSynchronizer = _DreamDataSynchronizer();
  late final _pageBuilder = _DreamPageBuilder();
  bool _initialized = false;

  @override
  void dispose() {
    _dataSynchronizer.dispose();
    super.dispose();
  }

  /// Gère la soumission avec logique par défaut
  Future<void> _handleSubmit(Map<String, dynamic> data) async {
    //edit dream
    if (widget.onSubmit != null) {
      // Utilise le callback fourni
      widget.onSubmit!(data);
    }
    // new dream
    else {
      // Logique par défaut : sauvegarder et naviguer
      try {
        await DreamWritingViewModel().insertDreamWithData(data);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Rêve enregistré !')));
          NavigationCore().goToDreamListTab();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
          );
        }
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

          // Initialisation pour l'édition (une seule fois)
          if (!_initialized && widget.initialDream != null) {
            _DreamEditingInitializer.initialize(vm, widget.initialDream!);
            _dataSynchronizer.fillControllersFromViewModel(vm);
            _initialized = true;
          }

          // Configuration des listeners et synchronisation
          _dataSynchronizer.setupListeners(vm);

          // Construction des pages
          final pages = _pageBuilder.buildPages(vm, _dataSynchronizer);

          return Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  DreamCarouselStepper(
                    page: vm.currentPage,
                    total: pages.length,
                  ),
                  const SizedBox(height: 10),
                  _buildCarouselContent(vm, pages),
                  _buildNavigation(vm, pages.length),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construit l'AppBar en fonction de l'état d'édition sinon rien
  AppBar? _buildAppBar() {
    return widget.initialDream != null
        ? buildDreamAppBar(title: 'Modifier mon rêve', context: context)
        : buildDreamAppBar(title: 'Mon rêve', context: context);
  }

  Widget _buildCarouselContent(DreamWritingViewModel vm, List<Widget> pages) {
    return Expanded(
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Theme.of(context).cardColor.withOpacity(0.97),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: pages[vm.currentPage],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(DreamWritingViewModel vm, int totalPages) {
    return DreamCarouselNavigation(
      page: vm.currentPage,
      totalPages: totalPages,
      onPrev: () {
        if (vm.currentPage > 0) {
          vm.setPage(vm.currentPage - 1);
          // 🔧 FIX : Force rebuild en mode release
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        }
      },
      onNext: () {
        if (vm.currentPage == 0 && vm.dreamTitle.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Le titre ne peut pas être vide.')),
          );
          return;
        }
        if (vm.currentPage < totalPages - 1) {
          vm.setPage(vm.currentPage + 1);
          // 🔧 FIX : Force rebuild en mode release
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        } else {
          _handleSubmit(vm.collectData());
        }
      },
    );
  }
}

///================================
/// **INITIALISATION D'ÉDITION**
/// Responsabilité : Préparation des données
///=================================

/// **SYNCHRONISATEUR DE DONNÉES** - Responsabilité : Gestion des contrôleurs
class _DreamDataSynchronizer {
  final TextEditingController _titleController = TextEditingController();
  final Map<String, TextEditingController> _noteControllers = {};
  bool _listenersSetup = false;

  void dispose() {
    _titleController.dispose();
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
  }

  TextEditingController get titleController => _titleController;

  TextEditingController getNoteController(String categoryName) {
    if (!_noteControllers.containsKey(categoryName)) {
      _noteControllers[categoryName] = TextEditingController();
    }
    return _noteControllers[categoryName]!;
  }

  void fillControllersFromViewModel(DreamWritingViewModel vm) {
    _titleController.text = vm.dreamTitle;
    for (final category in vm.availableCategoriesRedaction) {
      final controller = getNoteController(category.name);
      controller.text = vm.getNoteForCategory(category.name);
    }
  }

  void setupListeners(DreamWritingViewModel vm) {
    if (_listenersSetup) return;

    // Listener pour le titre
    _titleController.addListener(() {
      if (_titleController.text != vm.dreamTitle) {
        vm.updateTitle(_titleController.text);
      }
    });

    // Listeners pour les notes
    for (final category in vm.availableCategoriesRedaction) {
      final controller = getNoteController(category.name);
      controller.addListener(() {
        if (controller.text != vm.getNoteForCategory(category.name)) {
          vm.setNoteForCategory(category.name, controller.text);
        }
      });
    }

    _listenersSetup = true;
  }
}

/// **CONSTRUCTEUR DE PAGES** - Responsabilité : Génération des pages du carousel
class _DreamPageBuilder {
  List<Widget> buildPages(
    DreamWritingViewModel vm,
    _DreamDataSynchronizer synchronizer,
  ) {
    return [
      // Page titre
      DreamTitlePage(controller: synchronizer.titleController),

      // Pages de tags par catégorie
      ...vm.availableCategories.map((category) {
        return FutureBuilder<List<String>>(
          future: vm.getTagsForCategory(category.name),
          builder: (context, snapshot) {
            final existingTags = snapshot.data ?? [];
            final localTags = vm.getLocalTagsForCategory(category.name);
            return DreamTagsPage(
              title: category.displayName,
              label: 'Ajoute des ${category.description}...',
              tags: localTags,
              onChanged: (tags) => vm.setTagsForCategory(category.name, tags),
              chipColor: category.getFlutterColor(),
              chipTextColor: category.getTextColor(),
              addButtonColor: category.getButtonColor(),
              existingTags: existingTags,
            );
          },
        );
      }),

      // Pages de notes par catégorie
      ...vm.availableCategoriesRedaction.map((category) {
        final noteController = synchronizer.getNoteController(category.name);
        return DreamNotePage(
          title: category.displayName,
          label: 'écrit sur : ${category.description}...',
          controller: noteController,
        );
      }),
    ];
  }
}

/// **INITIALISATEUR D'ÉDITION** - Responsabilité : Logique d'initialisation
class _DreamEditingInitializer {
  static void initialize(DreamWritingViewModel vm, Dream dream) {
    vm.initializeWithDream(dream);
  }
}
