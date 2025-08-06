import 'package:revato_app/model/dream_model.dart';
import 'package:revato_app/services/business/dream_business_service.dart';

class DreamListViewModel {
  final DreamBusinessService _dreamBusinessService;

  /// **CONSTRUCTEUR AVEC INJECTION DE DÉPENDANCE**
  DreamListViewModel({DreamBusinessService? dreamService})
    : _dreamBusinessService = dreamService ?? DreamBusinessService();

  Future<List<Dream>> getAllDreamsWithTagsAndRedactions() {
    return _dreamBusinessService.getAllDreamsWithTagsAndRedactions();
  }
}
