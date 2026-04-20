import 'package:urbanestia/domain/model/user_model.dart';

abstract class AuthStates {}

class AuthInitial extends AuthStates {}

class AuthLoading extends AuthStates {}

class AuthAuthenticated extends AuthStates {}

class date extends AuthStates {
  final UserModel user;

  date(this.user);
}

class AuthLoggedOut extends AuthStates {}

class AuthFailure extends AuthStates {
  final String errorMessage;

  AuthFailure(this.errorMessage);
}

class AuthSuccess extends AuthStates {
  final String userId;
  final String token;
  final String? email;

  AuthSuccess(this.userId, this.token, this.email);
}

class AuthNeedsProfileCompletion extends AuthStates {
  final String userId;

  AuthNeedsProfileCompletion(this.userId);
}

class AuthError extends AuthStates {
  final String message;

  AuthError(this.message);
}

class ResetPasswordSent extends AuthStates {}

class AuthProfileUpdated extends AuthStates {}
