import 'package:pqrsmart/data/model/RequestModel.dart';

abstract class RequestEvent{}

class LoadRequestEvent extends RequestEvent{}

class SaveRequestEvent extends RequestEvent {
  final RequestModel requestModel;
  SaveRequestEvent(this.requestModel);
}