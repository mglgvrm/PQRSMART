import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/services/DependenceService.dart';

class DependenceRepository {
  final DependenceService service;
  DependenceRepository(this.service);

  Future<List<DependenceModel>> getDependences() {
    return service.getDependences();
  }
  Future<DependenceModel> saveDependence(DependenceModel dependence){
    return service.saveDependence(dependence);
  }
  Future<DependenceModel> activateDependence(int id){
    return service.activateDependence(id);
  }
  Future<DependenceModel> cancelDependence(int id){
    return service.cancelDependence(id);
  }
}