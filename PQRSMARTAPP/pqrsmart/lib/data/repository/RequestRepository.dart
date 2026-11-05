import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/services/RequestService.dart';

class RequestRepository {
  final RequestService requestService;

  RequestRepository(this.requestService);
  Future<List<RequestModel>> getAll() {
    return requestService.getAll();
  }

  Future<List<RequestModel>> getAllForAdministration() {
    return requestService.getAllForAdministration();
  }

  Future<List<RequestModel>> getForDependence() {
    return requestService.getForDependence();
  }

  Future<RequestModel> answerRequest(int idRequest, String answer) {
    return requestService.answerRequest(idRequest, answer);
  }

  Future<RequestModel> save(RequestModel requestModel) {
    print("EVENTO RECIBIDO ${requestModel}");
    return requestService.save(requestModel);
  }

  Future<void> cancel(int idRequest) {
    return requestService.cancel(idRequest);
  }
}
