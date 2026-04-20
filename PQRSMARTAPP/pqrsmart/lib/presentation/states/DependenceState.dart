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