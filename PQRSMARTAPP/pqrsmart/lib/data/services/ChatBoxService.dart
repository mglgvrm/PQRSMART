import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/core/constants/api_service.dart';
import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/model/ChatBoxModel.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';

class ChatBoxService {
  final AuthStorage _storage = AuthStorage();
  // ── POST: enviar mensajes y recibir respuesta IA ────────
  // Igual que la web: manda la lista completa de mensajes
  Future<String> sendMessage(List<ChatBoxModel> messages) async {
    final token = await _storage.getToken();

    // Convierte a formato [{role, content}] igual que la web
    final body = jsonEncode({
      'messages': messages.map((m) => m.toJson()).toList(),
    });

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/chat/box'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      // El backend devuelve texto plano — igual que la web
      final rawText = response.body;

      // Misma limpieza que hace la web
      final textoLimpio = rawText
          .replaceAll(RegExp(r'(\*\*|__|--|\*)'), '\n')
          .trim();

      return textoLimpio;
    } else {
      throw Exception('Error al enviar mensaje: ${response.statusCode}');
    }
  }
}