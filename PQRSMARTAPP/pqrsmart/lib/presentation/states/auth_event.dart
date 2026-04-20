// lib/presentation/auth/bloc/auth_event.dart
abstract class AuthEvent {}

class LogoutRequested extends AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class MetaSignInRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class SignInRequestedEmail extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String lastname;
  final String role;
  final String? nit;
  final String? identification;
  final String? img;
  final String? phoneNumber;
  final String? nameCompany;
  final String? selectedTypePerson;

  SignInRequestedEmail({
    required this.email,
    required this.password,
    required this.name,
    required this.lastname,
    required this.role,
    required this.nit,
    required this.identification,
    required this.img,
    required this.phoneNumber,
    required this.nameCompany,
    required this.selectedTypePerson,
  });
}

class CreateUserProfile extends AuthEvent {
  final String userId;
  final String email;
  final String name;
  final String lastname;
  final String role;
  final String? nit;
  final String? identification;
  final String? img;
  final String phoneNumber;
  final String? nameCompany;
  final String? selectedTypePerson;

  CreateUserProfile({
    required this.userId,
    required this.email,
    required this.name,
    required this.lastname,
    required this.role,
    required this.nit,
    required this.identification,
    required this.img,
    required this.phoneNumber,
    required this.nameCompany,
    required this.selectedTypePerson,
  });
}

class SendResetPasswordEmail extends AuthEvent {
  final String email;
  SendResetPasswordEmail(this.email);
}

class UpdateProfileRequested extends AuthEvent {
  final String userId;
  final String phone;
  final String email;
  final String name;
  final String lastname;

  UpdateProfileRequested({
    required this.userId,
    required this.phone,
    required this.email,
    required this.name,
    required this.lastname,
  });
}
