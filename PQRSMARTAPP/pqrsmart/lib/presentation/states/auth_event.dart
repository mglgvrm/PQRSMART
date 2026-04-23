import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String user;
  final String password;

  LoginEvent(this.user, this.password);

  @override
  List<Object> get props => [user, password];
}

class SignInEvent extends AuthEvent {
  final String user;
  final String name;
  final String lastName;
  final String email;
  final String password;
  final int identificationType; // ID del objeto relacional
  final int identificationNumber;
  final int personType;          // ID del objeto relacional
  final int number;        // ID del objeto relacional

  SignInEvent({
    required this.user,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.identificationType,
    required this.identificationNumber,
    required this.personType,
    required this.number,
  });

  @override
  List<Object> get props => [
    user, name, lastName, email, password,
    identificationType, identificationNumber,
    personType, number,
  ];
}

class SignInEventAmin extends AuthEvent {
  final String user;
  final String name;
  final String lastName;
  final String email;
  final String password;
  final int identificationType; // ID del objeto relacional
  final int identificationNumber;
  final int personType;          // ID del objeto relacional
  final int number;
  final int dependence;
  final String role;// ID del objeto relacional

  SignInEventAmin({
    required this.user,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.identificationType,
    required this.identificationNumber,
    required this.personType,
    required this.number,
    required this.dependence,
    required this.role
  });

  @override
  List<Object> get props => [
    user, name, lastName, email, password,
    identificationType, identificationNumber,
    personType, number, dependence, role
  ];
}

class LogoutEvent extends AuthEvent {}

class LoadFormDataEvent extends AuthEvent {}