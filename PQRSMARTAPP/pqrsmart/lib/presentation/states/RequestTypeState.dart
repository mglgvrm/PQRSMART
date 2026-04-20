import 'package:pqrsmart/data/model/RequestTypeModel.dart';

abstract class RequestTypeState {}

class RequestTypeInitial  extends RequestTypeState {}

class RequestTypeLoading  extends RequestTypeState {}

class RequestTypeLoaded   extends RequestTypeState {
  final List<RequestTypeModel> requestTypeModel;
  RequestTypeLoaded(this.requestTypeModel);
}
class RequestTypeError    extends RequestTypeState {
  final String message;
  RequestTypeError(this.message);
}