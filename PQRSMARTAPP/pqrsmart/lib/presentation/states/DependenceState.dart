import 'package:pqrsmart/data/model/DependenceModel.dart';

abstract class DependenceState {}

class DependenceInitial  extends DependenceState {}

class DependenceLoading  extends DependenceState {}

class DependenceLoaded   extends DependenceState {
  final List<DependenceModel> dependence;
  DependenceLoaded(this.dependence);
}
class DependenceError    extends DependenceState {
  final String message;
  DependenceError(this.message);
}

class SaveDependenceLoaded extends DependenceState {
  final DependenceModel dependence;

  SaveDependenceLoaded(this.dependence);
}

class ActivateDependenceLoaded extends DependenceState {
  final DependenceModel dependence;

  ActivateDependenceLoaded(this.dependence);
}

class CancelDependenceLoaded extends DependenceState {
  final DependenceModel dependence;

  CancelDependenceLoaded(this.dependence);
}