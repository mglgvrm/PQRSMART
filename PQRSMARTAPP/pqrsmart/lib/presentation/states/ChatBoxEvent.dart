abstract class ChatBoxEvent {}

class LoadChatBox extends ChatBoxEvent {}

class SendMessageChatBox extends ChatBoxEvent {
  final String message;
  SendMessageChatBox(this.message);
}