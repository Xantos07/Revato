import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/dream_service.dart';

class DreamListViewModel {
  final DreamService _dreamService;

  /// **CONSTRUCTEUR AVEC INJECTION DE DÉPENDANCE**
  DreamListViewModel({DreamService? dreamService})
    : _dreamService = dreamService ?? DreamService();

  Future<List<Dream>> getAllDreamsWithTagsAndRedactions() {
    return _dreamService.getAllDreamsWithTagsAndRedactions();
  }
}
