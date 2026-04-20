abstract class UserEvent {}

class GetUserEvent extends UserEvent {}

class GetMyUserEvent extends UserEvent{}

class ActivarUsuarioEvent extends UserEvent {
  final int id;
  ActivarUsuarioEvent(this.id);
}

class DesactivarUsuarioEvent extends UserEvent {
  final int id;
  DesactivarUsuarioEvent(this.id);
}