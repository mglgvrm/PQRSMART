import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<GetUserEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.getAll();
        emit(UserLoaded(user));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
    on<GetMyUserEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await userRepository.getMyUserEvent();
        emit(MyUserLoaded(user));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });

    on<ActivarUsuarioEvent>((event, emit) async {
      emit(UserLoading());
      try {
        await userRepository.setUserStatus(event.id, active: true);
        emit(UserStatusUpdated(true));
      } catch (e) {
        emit(UserError('Error al activar el usuario: $e'));
      }
    });
    on<DesactivarUsuarioEvent>((event, emit) async {
      emit(UserLoading());
      try {
        await userRepository.setUserStatus(event.id, active: false);
        emit(UserStatusUpdated(false));
      } catch (e) {
        emit(UserError('Error al desactivar el usuario: $e'));
      }
    });
  }
}
