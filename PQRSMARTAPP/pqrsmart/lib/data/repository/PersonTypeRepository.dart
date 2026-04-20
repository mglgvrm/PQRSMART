// person_type_repository.dart
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import 'package:pqrsmart/data/services/PersonTypeService.dart';

class PersonTypeRepository {
  final PersonTypeService service;

  PersonTypeRepository(this.service);

  Future<List<PersonTypeModal>> getAll() {
    return service.getAll();
  }
}