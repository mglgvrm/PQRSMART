import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/data/model/user_model.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import '../../core/constants/api_service.dart';

class UserService {
  final storage = AuthStorage();

  Future<List<UserModel>> getAll() async {
    final token = await storage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/Usuario/get'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (kDebugMode) {
      print("el response ${response.body}");
    }
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception("Error en al obtener usuarios");
    }
  }

  Future<UserModel> getMyUserEvent() async {
    final token = await storage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/Usuario/profile'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (kDebugMode) {
      print("el response ${response.body}");
    }
    if (response.statusCode == 200) {
      final UserModel data = UserModel.fromJson(jsonDecode(response.body));

      return data;
    } else {
      throw Exception("Error en al obtener usuarios");
    }
  }
  Future<UserModel> cancelUser(
      int id
      ) async {
    final token = await storage.getToken();

    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/Usuario/cancel/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      print("el response ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (kDebugMode) {
        print('Response Usuario: $data');
      }

      return UserModel.fromJson(data);
    } else {
      throw Exception('Error al guardar Usuario: ${response.statusCode}');
    }
  }
}
