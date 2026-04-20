import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/repository/DependenceRepository.dart';
import 'package:pqrsmart/presentation/states/DependenceEvent.dart';
import 'package:pqrsmart/presentation/states/DependenceState.dart';

class DependenceBloc extends Bloc<DependenceEvent, DependenceState> {
  final DependenceRepository repository;

  DependenceBloc(this.repository) : super(DependenceInitial()) {

    on<LoadDependenceEvent>((event, emit) async {
      emit(DependenceLoading());
      try {
        final dependence = await repository.getDependences();
        emit(DependenceLoaded(dependence));
      } catch (e) {
        emit(DependenceError('Error al cargar dependencias'));
      }
    });
  }
}