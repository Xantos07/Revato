import 'package:flutter/foundation.dart';
import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/dream_service.dart';
import 'package:revato_app/services/navigation_core.dart';

class DreamDetailViewModel extends ChangeNotifier {
  final DreamService _dreamService;
  final NavigationCore _navigationService;

  DreamDetailViewModel({
    DreamService? dreamService,
    NavigationCore? navigationService,
  }) : _dreamService = dreamService ?? DreamService(),
       _navigationService = navigationService ?? NavigationCore();

  // État privé
  bool _isLoading = false;
  String? _errorMessage;

  // Getters publics
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Éditer un rêve
  Future<void> editDream(Dream dream) async {
    _navigationService.navigateToEditDream(dream);
  }

  Future<void> viewDream(Dream dream) async {
    // Navigation vers les détails du rêve
    print('Navigating to dream details for: ${dream.title}');
    _navigationService.navigateToDreamDetail(dream);
  }

  /// Supprimer un rêve
  Future<bool> deleteDream(int dreamId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _dreamService.deleteDream(dreamId);
      if (success) {
        _navigationService.goBack();
      } else {
        _errorMessage = 'Erreur lors de la suppression du rêve';
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
