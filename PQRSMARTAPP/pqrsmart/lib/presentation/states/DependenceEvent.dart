import 'package:pqrsmart/data/model/DependenceModel.dart';

abstract class DependenceEvent {}

class LoadDependenceEvent extends DependenceEvent {}

class SaveDependenceEvent extends DependenceEvent {
  final DependenceModel dependence;

  SaveDependenceEvent(this.dependence);
}

class ActivateDependenceEvent extends DependenceEvent{
  final int id;
  ActivateDependenceEvent(this.id);
}
class CancelDependenceEvent extends DependenceEvent{
  final int id;
  CancelDependenceEvent(this.id);
}