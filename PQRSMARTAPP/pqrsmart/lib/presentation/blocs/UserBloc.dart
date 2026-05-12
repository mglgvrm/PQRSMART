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
    on<GetMyUserEvent>((event, emit) async{
      emit(UserLoading());
      try{
        final user = await userRepository.getMyUserEvent();
        emit(MyUserLoaded(user));
      } catch(e){
        emit(UserError(e.toString()));
      }
    });


    /*on<ActivarUsuarioEvent>((event, emit) async {
      await service.activarUsuario(event.id);
      add(GetUsuariosEvent()); // refresca lista
    });
*/
    on<DesactivarUsuarioEvent>((event, emit) async {
      try{
        final user = await userRepository.cancelUser(event.id);
        emit(CancelUserLoaded(user));
      } catch (e) {
        emit(UserError('Error al guardar usuario'));
      }


    });
  }
}