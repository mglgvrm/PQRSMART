import 'package:pqrsmart/data/model/ChatBoxModel.dart';
import 'package:pqrsmart/data/services/ChatBoxService.dart';

class ChatBoxRepository {
  final ChatBoxService chatBoxService;
  ChatBoxRepository(this.chatBoxService);

  Future<String> sendMessage(List<ChatBoxModel> messages) {
    return chatBoxService.sendMessage(messages);
  }
}