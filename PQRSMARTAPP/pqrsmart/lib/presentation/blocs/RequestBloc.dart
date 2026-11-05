import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';

class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final RequestRepository requestRepository;

  RequestBloc(this.requestRepository) : super(RequestInitial()) {
    on<LoadRequestEvent>((event, emit) async {
      emit(RequestLoading());
      try {
        final user = await requestRepository.getAll();
        emit(RequestLoaded(user));
      } catch (e) {
        emit(RequestError(e.toString()));
      }
    });
    on<LoadAllRequestsEvent>((event, emit) async {
      emit(RequestLoading());
      try {
        final requests = await requestRepository.getAllForAdministration();
        emit(RequestLoaded(requests));
      } catch (e) {
        emit(RequestError(e.toString()));
      }
    });
    on<LoadRequestsForDependenceEvent>((event, emit) async {
      emit(RequestLoading());
      try {
        final requests = await requestRepository.getForDependence();
        emit(RequestLoaded(requests));
      } catch (e) {
        emit(RequestError(e.toString()));
      }
    });
    on<SaveRequestEvent>((event, emit) async {
      // 👈 toma el modelo del evento
      emit(RequestLoading());
      try {
        print("EVENTO RECIBIDO ${event.requestModel}");
        final request = await requestRepository.save(event.requestModel);

        emit(RequestSaved(request)); // 👈 emite un estado, no un evento
      } catch (e) {
        emit(RequestError(e.toString()));
      }
    });
    on<CancelRequestEvent>((event, emit) async {
      emit(RequestLoading());
      try {
        await requestRepository.cancel(event.idRequest);
        emit(RequestCancelled());
      } catch (e) {
        emit(RequestError(e.toString()));
      }
    });
    on<AnswerRequestEvent>((event, emit) async {
      emit(RequestLoading());
      try {
        final request = await requestRepository.answerRequest(
          event.idRequest,
          event.answer,
        );
        emit(RequestAnswered(request));
      } catch (e) {
        emit(RequestError(e.toString()));
      }
    });
  }
}
