import 'package:pqrsmart/data/model/ChatBoxModel.dart';

abstract class ChatBoxState {}

class ChatBoxInitial extends ChatBoxState {}

class ChatBoxLoading extends ChatBoxState {}

class ChatBoxLoaded extends ChatBoxState {
  final List<ChatBoxModel> messages;
  ChatBoxLoaded(this.messages);
}

class ChatBoxSending extends ChatBoxState {
  final List<ChatBoxModel> messages; // muestra mensajes mientras espera respuesta
  ChatBoxSending(this.messages);
}

class ChatBoxError extends ChatBoxState {
  final String message;
  ChatBoxError(this.message);
}