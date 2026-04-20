import 'package:pqrsmart/data/model/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserModel> user;
  UserLoaded(this.user);
}
class MyUserLoaded extends UserState {
  final UserModel user;
  MyUserLoaded(this.user);
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}