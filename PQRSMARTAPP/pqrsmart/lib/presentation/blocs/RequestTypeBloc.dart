import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/repository/RequestTypeRepository.dart';
import 'package:pqrsmart/presentation/states/RequestTypeEvent.dart';
import 'package:pqrsmart/presentation/states/RequestTypeState.dart';

class RequestTypeBloc extends Bloc<RequestTypeEvent, RequestTypeState> {
  final RequestTypeRepository repository;

  RequestTypeBloc(this.repository) : super(RequestTypeInitial()) {

    on<LoadRequestTypeEvent>((event, emit) async {
      emit(RequestTypeLoading());
      try {
        final requestType = await repository.getAll();
        emit(RequestTypeLoaded(requestType));
      } catch (e) {
        emit(RequestTypeError('Error al cargar dependencias'));
      }
    });
  }
}