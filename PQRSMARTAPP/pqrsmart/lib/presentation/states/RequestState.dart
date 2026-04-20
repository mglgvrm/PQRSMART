import 'package:pqrsmart/data/model/RequestModel.dart';

abstract class RequestState {}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestLoaded extends RequestState {
  final List<RequestModel> request;

  RequestLoaded(this.request);
}

class RequestError extends RequestState {
  final String message;

  RequestError(this.message);
}



class RequestSaved extends RequestState {
  final RequestModel request;
  RequestSaved(this.request);
}