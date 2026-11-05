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

  Future<List<RequestModel>> getAllForAdministration() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/get'),
      headers: {"Authorization": "******", "Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RequestModel.fromJson(e)).toList();
    }
    throw Exception(
      'Error al obtener solicitudes administrativas: ${response.statusCode}',
    );
  }

  Future<List<RequestModel>> getForDependence() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/getForDependence'),
      headers: {"Authorization": "******", "Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RequestModel.fromJson(e)).toList();
    }
    throw Exception(
      'Error al obtener solicitudes de la dependencia: ${response.statusCode}',
    );
  }

  Future<RequestModel> answerRequest(int idRequest, String answer) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/request/update/$idRequest'),
      headers: {"Authorization": "******", "Content-Type": "application/json"},
      body: jsonEncode({"answer": answer}),
    );
    if (response.statusCode == 200) {
      return RequestModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al responder la solicitud: ${response.statusCode}');
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

  Future<void> cancel(int idRequest) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/request/cancel/$idRequest'),
      headers: {'Authorization': '******', 'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al cancelar la solicitud: ${response.statusCode}');
    }
  }
}
