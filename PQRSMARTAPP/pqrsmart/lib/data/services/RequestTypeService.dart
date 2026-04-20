import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:pqrsmart/core/constants/api_service.dart';
import 'package:pqrsmart/data/model/RequestTypeModel.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';

class RequestTypeService {
  final storage = AuthStorage();

  Future<List<RequestTypeModel>> getAll() async {
    final token = await storage.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request_type/get'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (kDebugMode) print("Response request: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RequestTypeModel.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener tipos de persona");
    }
  }
}
