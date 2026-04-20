// "user" o "assistant"

class ChatBoxModel {
  final String role;
  final String content;

  ChatBoxModel({
    required this.role,
    required this.content,
  });

  factory ChatBoxModel.fromJson(Map<String, dynamic> json) {
    return ChatBoxModel(
        role: json['role'] ?? 'assistant',
        content: json['content'] ?? '',
    );
  }
  // 👇 Agrega esto
  Map<String, dynamic> toJson() => {
    'role':    role,
    'content': content,
  };
}