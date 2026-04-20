import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urbanestia/domain/use_cases/auth_usecase.dart';
import 'package:urbanestia/presentation/states/auth_event.dart';
import 'package:urbanestia/presentation/states/auth_state.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStates> {
  final AuthUseCase _authUseCase = AuthUseCase();

  AuthBloc() : super(AuthInitial()) {
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final loggedIn = await _authUseCase.loginWithGoogle();
        print('📱 Google Sign-In resultado: $loggedIn');
        // Verificar si el login fue exitoso
        if (!loggedIn) {
          print('❌ Google Sign-In falló');
          emit(AuthError('Error al iniciar sesión con Google'));
          return;
        }

        final session = Supabase.instance.client.auth.currentSession;
        final userId = session?.user?.id;
        print('👤 userId: $userId');
        print('🔐 session exists: ${session != null}');

        // Verificar que userId no sea null antes de continuar
        if (userId == null) {
          print('❌ userId es null después del login');
          emit(AuthError('No se pudo obtener información del usuario'));
          return;
        }
        final supabase = Supabase.instance.client;

        final response =
            await supabase
                .from('user_profile')
                .select()
                .eq('user_id', userId!)
                .maybeSingle();
        print(
          '##################################### $response ##########################################',
        );
        // response es un Map<String, dynamic> (lo que devuelve Supabase)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile', jsonEncode(response));

        if (response == null) {
          emit(AuthNeedsProfileCompletion(userId));
        } else if (loggedIn) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthError('Error al iniciar sesión con Google'));
        }
      } catch (e) {
        emit(AuthError('Inicio de sesión fallido'));
        print('Error en BLoC: $e');
        print('📍 Error details: ${e.runtimeType}');
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final loggedIn = await _authUseCase.loginWithEmail(
          email: event.email,
          password: event.password,
        );
        loggedIn
            ? emit(AuthAuthenticated())
            // Si el inicio de sesión es exitoso, emitimos AuthAuthenticated con el usuario
            : emit(AuthError('Error al iniciar sesión'));
      } catch (e) {
        emit(AuthError('Usuario y/o contraseña incorrectos'));
        print('Error en BLoC: $e');
      }
    });
    on<SignInRequestedEmail>((SignInRequestedEmail event, emit) async {
      emit(AuthLoading());
      try {
        final loggedIn = await _authUseCase.singInWithEmail(
          email: event.email,
          password: event.password,
          name: event.name,
          lastName: event.lastname,
          role: event.role,
          nit: event.nit,
          identification: event.identification,
          img: event.img,
          nameCompany: event.nameCompany,
          phoneNumber: event.phoneNumber,
          selectedTypePerson: event.selectedTypePerson,
        );
        loggedIn
            ? emit(AuthAuthenticated())
            // Si el inicio de sesión es exitoso, emitimos AuthAuthenticated con el usuario
            : emit(AuthError('Error al iniciar sesión'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CreateUserProfile>((event, emit) async {
      emit(AuthLoading());
      try {
        final respose = await _authUseCase.createUserProfile(
          userId: event.userId,
          email: event.email,
          name: event.name,
          lastName: event.lastname,
          role: event.role,
          nit: event.nit,
          identification: event.identification,
          picture: event.img,
          phone: event.phoneNumber,
          nameCompany: event.nameCompany,
          selectedTypePerson: event.selectedTypePerson,
        );
        respose
            ? emit(AuthAuthenticated())
            // Si la creación del perfil es exitosa, emitimos AuthAuthenticated con el usuario
            : emit(AuthError('Error al crear el perfil'));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authUseCase.logoutRequested();
        emit(AuthLoggedOut());
        print("Estado AuthLoggedOut emitido correctamente");
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (e) {
        emit(AuthError('Error al cerrar sesión: ${e.toString()}'));
        print("Error en BLoC al cerrar sesión: $e");
      }
    });

    on<SendResetPasswordEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authUseCase.sendResetPasswordEmail(event.email);

        emit(ResetPasswordSent());
      } catch (e) {
        emit(AuthError("Error al enviar el correo: ${e.toString()}"));
      }
    });

    on<UpdateProfileRequested>((event, emit) async {
      // Emitir estado de carga
      emit(AuthLoading());

      try {
        // Llamar al caso de uso para actualizar el perfil
        await _authUseCase.updateUserProfile(
          userId: event.userId,
          phone: event.phone,
          email: event.email,
          name: event.name,
          lastname: event.lastname,
        );

        emit(AuthProfileUpdated());
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_profile',
          jsonEncode({
            'user_id': event.userId,
            'phone_number': event.phone,
            'email': event.email,
            'name': event.name,
            'lastname': event.lastname,
          }),
        );
      } catch (e) {
        print('❌ Error actualizando perfil: $e');
        emit(AuthError('Error al actualizar el perfil'));
      }
    });
  }
}
