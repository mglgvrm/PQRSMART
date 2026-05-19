abstract class ChatBoxEvent {}

class LoadChatBox extends ChatBoxEvent {}
class LoadChatBoxUser extends ChatBoxEvent {}
class SendMessageChatBox extends ChatBoxEvent {
  final String message;
  SendMessageChatBox(this.message);
}

class SendMessageChatBoxUser extends ChatBoxEvent {
  final String message;
  SendMessageChatBoxUser(this.message);
}