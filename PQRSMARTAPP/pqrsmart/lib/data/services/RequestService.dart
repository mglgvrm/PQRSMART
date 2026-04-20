import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/core/constants/api_service.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';

class RequestService {
  final storage = AuthStorage();

  Future<List<RequestModel>> getAll() async {
    final token = await storage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/get/pqrs'),
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
      return data.map((e) => RequestModel.fromJson(e)).toList();
    } else {
      throw Exception("Error en al obtener usuarios");
    }
  }

  Future<RequestModel> save(RequestModel requestModel) async {
    final token = await storage.getToken();
    print("EVENTO RECIBIDO ${requestModel}");
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/request/save'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestModel.toJson()), // ✅
    );
    print("response ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("exito ${response.body}");
      return RequestModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al guardar la solicitud: ${response.statusCode}');
    }
  }
}
