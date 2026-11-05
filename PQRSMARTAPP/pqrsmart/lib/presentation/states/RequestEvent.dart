import 'package:pqrsmart/data/model/RequestModel.dart';

abstract class RequestEvent {}

class LoadRequestEvent extends RequestEvent {}

class LoadAllRequestsEvent extends RequestEvent {}

class LoadRequestsForDependenceEvent extends RequestEvent {}

class SaveRequestEvent extends RequestEvent {
  final RequestModel requestModel;
  SaveRequestEvent(this.requestModel);
}

class AnswerRequestEvent extends RequestEvent {
  final int idRequest;
  final String answer;

  AnswerRequestEvent(this.idRequest, this.answer);
}

class CancelRequestEvent extends RequestEvent {
  final int idRequest;
  CancelRequestEvent(this.idRequest);
}
