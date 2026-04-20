import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/services/RequestService.dart';

class RequestRepository {
  final RequestService requestService;

  RequestRepository(this.requestService);
  Future<List<RequestModel>> getAll(){
    return requestService.getAll();
  }
  Future <RequestModel> save(RequestModel requestModel){
    print("EVENTO RECIBIDO ${requestModel}");
    return requestService.save(requestModel);
  }

}