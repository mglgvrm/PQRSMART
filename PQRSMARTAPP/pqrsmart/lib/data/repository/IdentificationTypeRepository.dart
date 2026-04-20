// identification_type_repository.dart
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';
import 'package:pqrsmart/data/services/IdentificationTypeService.dart';

class IdentificationTypeRepository {
  final IdentificationTypeService service;

  IdentificationTypeRepository(this.service);

  Future<List<IdentificationTypeModal>> getAll() {
    return service.getAll();
  }
}