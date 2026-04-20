import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pqrsmart/data/model/AuthResponse.dart';
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import 'package:pqrsmart/data/model/user_model.dart';

abstract class AuthStates {}

class AuthInitial extends AuthStates {}

class AuthLoading extends AuthStates {}

class AuthAuthenticated extends AuthStates {}

class AuthLoggedOut extends AuthStates {}

class AuthFailure extends AuthStates {
  final String errorMessage;

  AuthFailure(this.errorMessage);
}


class AuthSuccess extends AuthStates {
  final AuthResponse data;


  AuthSuccess(this.data);
}

class AuthRegisterSuccess extends AuthStates {
  final UserModel user;

  AuthRegisterSuccess({required this.user});

  @override
  List<Object> get props => [user];
}
class AuthRegisterLoaded extends AuthStates {
  final List<IdentificationTypeModal> identificationTypes;
  final List<PersonTypeModal> personTypes;

  AuthRegisterLoaded({
    required this.identificationTypes,
    required this.personTypes,
  });
}
class AuthError extends AuthStates {
  final String message;

  AuthError(this.message);
}

class ResetPasswordSent extends AuthStates {}

class AuthProfileUpdated extends AuthStates {}
