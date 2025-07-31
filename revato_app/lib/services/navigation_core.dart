import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/Screen/dream_writing_carousel.dart';
import 'package:revato_app/widgets/DreamDetail/DreamDetail.dart';
import 'package:revato_app/services/dream_service.dart';

// A refactoriser :)

class NavigationCore {
  // Gestion du changement d'onglet principal
  static void Function(int)? _tabController;

  /// Enregistre le setter d'onglet (à appeler dans initState du HomeScreen)
  static void registerTabController(void Function(int) setter) {
    _tabController = setter;
  }

  /// Va à l'onglet "Mon rêve"
  void goToDreamWritting() {
    if (_tabController != null) {
      _tabController!(0);
    }
  }

  /// Va à l'onglet "Mes rêves"
  void goToDreamListTab() {
    print('Navigating to Dream List Tab');
    if (_tabController != null) {
      print('Oui je suis bien dans Navigating to Dream List Tab');
      _tabController!(1);
    }
  }

  /// Va à l'onglet "Analyse"
  void goToDreamAnalyse() {
    if (_tabController != null) {
      _tabController!(2);
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  NavigatorState? get _navigator => navigatorKey.currentState;

  /// Naviguer vers les détails d'un rêve
  void navigateToDreamDetail(Dream dream, {VoidCallback? onDreamUpdated}) {
    print('Service Navigating to dream detail for: ${dream.title}');
    _navigator!.push(
      MaterialPageRoute(
        builder:
            (context) =>
                DreamDetail(dream: dream, onDreamUpdated: onDreamUpdated),
      ),
    );
  }

  /// Naviguer vers l'édition d'un rêve
  void navigateToEditDream(Dream dream, {VoidCallback? onDreamUpdated}) async {
    final result = await _navigator?.push<Dream>(
      MaterialPageRoute(
        builder:
            (context) => DreamWritingCarousel(
              initialDream: dream,
              onSubmit: (data) async {
                try {
                  await DreamService().UpdateDreamWithData(dream.id, data);
                  // Récupère le rêve à jour
                  final updatedDream = await DreamService()
                      .getDreamWithTagsAndRedactions(dream.id);
                  // Ferme la page d'édition et retourne le rêve à jour
                  Navigator.of(context).pop(updatedDream);
                } catch (e) {
                  debugPrint('Erreur mise à jour: $e');
                }
              },
            ),
      ),
    );
    // Si on a bien un rêve modifié, on remplace la page de détail par la nouvelle version
    if (result != null) {
      _navigator?.pushReplacement(
        MaterialPageRoute(
          builder:
              (context) =>
                  DreamDetail(dream: result, onDreamUpdated: onDreamUpdated),
        ),
      );
    }
  }

  /// Retour en arrière
  void goBack() {
    _navigator?.pop();
  }

  /// Retour à l'écran racine
  void goToRoot() {
    _navigator?.popUntil((route) => route.isFirst);
  }
}
