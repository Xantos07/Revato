import 'package:flutter/material.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/widgets/dream_writing_carousel.dart';
import 'package:revato_app/widgets/DreamDetail/DreamDetail.dart';
import 'package:revato_app/services/dream_service.dart';

class NavigationCore {
  // Gestion du changement d'onglet principal
  static void Function(int)? _tabController;

  /// Enregistre le setter d'onglet (à appeler dans initState du HomeScreen)
  static void registerTabController(void Function(int) setter) {
    _tabController = setter;
  }

  /// Va à l'onglet "Mes rêves"
  void goToDreamListTab() {
    print('Navigating to Dream List Tab');
    if (_tabController != null) {
      print('Oui je suis bien dans Navigating to Dream List Tab');
      _tabController!(1);
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  NavigatorState? get _navigator => navigatorKey.currentState;

  /// Naviguer vers les détails d'un rêve
  void navigateToDreamDetail(Dream dream) {
    print('Service Navigating to dream detail for: ${dream.title}');
    _navigator?.push(
      MaterialPageRoute(builder: (context) => DreamDetail(dream: dream)),
    );
  }

  /// Naviguer vers l'édition d'un rêve
  void navigateToEditDream(Dream dream) {
    _navigator?.push(
      MaterialPageRoute(
        builder:
            (context) => DreamWritingCarousel(
              initialDream: dream,
              onSubmit: (data) async {
                try {
                  await DreamService().UpdateDreamWithData(dream.id, data);
                  _navigator?.pop(); // Retour aux détails
                } catch (e) {
                  debugPrint('Erreur mise à jour: $e');
                }
              },
            ),
      ),
    );
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
