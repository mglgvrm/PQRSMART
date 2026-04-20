import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/model/user_model.dart';
import 'package:pqrsmart/data/repository/IdentificationTypeRepository.dart';
import 'package:pqrsmart/data/repository/PersonTypeRepository.dart';
import 'package:pqrsmart/data/repository/auth_repositories.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStates> {
  final AuthRepository repository;
  final storage = AuthStorage();


  AuthBloc(this.repository, ) : super(AuthInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());

      try {
        final response = await repository.login(event.user, event.password);
        await storage.saveToken(response.token);
        await storage.saveAuthorities(response.authorities);
        emit(AuthSuccess(response));
      } catch (e) {
        emit(AuthFailure("Credenciales incorrectas"));
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await storage.clear(); // limpia token y authorities
        emit(AuthLoggedOut());
      } catch (e) {
        emit(AuthFailure("Error al cerrar sesión"));
      }
    });
    on<SignInEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final UserModel user = await repository.register(
          // ← corregido
          user: event.user,
          name: event.name,
          lastName: event.lastName,
          email: event.email,
          password: event.password,
          identificationType: event.identificationType,
          identificationNumber: event.identificationNumber,
          personType: event.personType,
          number: event.number,
        );
        emit(AuthRegisterSuccess(user: user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    // Carga los dropdowns al abrir el formulario
    on<LoadFormDataEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final data = await repository.getRegisterFormData();
        emit(AuthRegisterLoaded(
          identificationTypes: data['identificationTypes'],
          personTypes: data['personTypes'],
        ));
      } catch (e) {
        emit(AuthError( "Error al cargar formulario: ${e.toString()}"));
      }
    });
  }
}
