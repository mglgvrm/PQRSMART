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

    on<SaveDependenceEvent>((event, emit) async {
      emit(DependenceLoading());

      try {
        final dependence = await repository.saveDependence(event.dependence);

        emit(SaveDependenceLoaded(dependence));
      } catch (e) {
        emit(DependenceError('Error al guardar dependencia'));
      }
    });
    on<ActivateDependenceEvent>((event, emit) async {
      emit(DependenceLoading());

      try {
        final dependence = await repository.activateDependence(event.id);

        emit(ActivateDependenceLoaded(dependence));
      } catch (e) {
        emit(DependenceError('Error al guardar dependencia'));
      }
    });
    on<CancelDependenceEvent>((event, emit) async {
      emit(DependenceLoading());

      try {
        final dependence = await repository.cancelDependence(event.id);

        emit(CancelDependenceLoaded(dependence));
      } catch (e) {
        emit(DependenceError('Error al guardar dependencia'));
      }
    });
  }



}