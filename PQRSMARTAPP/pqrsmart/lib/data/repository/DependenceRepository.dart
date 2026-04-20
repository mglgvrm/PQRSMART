import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/services/DependenceService.dart';

class DependenceRepository {
  final DependenceService service;
  DependenceRepository(this.service);

  Future<List<DependenceModel>> getDependences() {
    return service.getDependences();
  }
}