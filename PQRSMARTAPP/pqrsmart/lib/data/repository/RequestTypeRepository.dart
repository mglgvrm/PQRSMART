import 'package:pqrsmart/data/model/RequestTypeModel.dart';
import 'package:pqrsmart/data/services/RequestTypeService.dart';

class RequestTypeRepository {
  final RequestTypeService service;

  RequestTypeRepository(this.service);

  Future<List<RequestTypeModel>> getAll() {
    return service.getAll();
  }
}