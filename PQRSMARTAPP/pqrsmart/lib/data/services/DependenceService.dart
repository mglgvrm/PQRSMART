import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/core/constants/api_service.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';

class DependenceService {
  // ← cambia por tu URL
  final storage = AuthStorage();

  Future<List<DependenceModel>> getDependences() async {
    final token = await storage.getToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/dependence/get'),
      // ← ajusta el endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (kDebugMode) {
      print("el response ${response.body}");
    }
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print('Response dependences: $data');
      return data.map((e) => DependenceModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener dependencias: ${response.statusCode}');
    }
  }

  Future<DependenceModel> saveDependence(
    DependenceModel dependenceModel,
  ) async {
    final token = await storage.getToken();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/dependence/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dependenceModel.toJson()),
    );

    if (kDebugMode) {
      print("el response ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (kDebugMode) {
        print('Response dependence: $data');
      }

      return DependenceModel.fromJson(data);
    } else {
      throw Exception('Error al guardar dependencia: ${response.statusCode}');
    }
  }
  Future<DependenceModel> activateDependence(
      int id
      ) async {
    final token = await storage.getToken();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/dependence/activate/$id'),
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
        print('Response dependence: $data');
      }

      return DependenceModel.fromJson(data);
    } else {
      throw Exception('Error al guardar dependencia: ${response.statusCode}');
    }
  }
  Future<DependenceModel> cancelDependence(
      int id
      ) async {
    final token = await storage.getToken();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/dependence/cancel/$id'),
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
        print('Response dependence: $data');
      }

      return DependenceModel.fromJson(data);
    } else {
      throw Exception('Error al guardar dependencia: ${response.statusCode}');
    }
  }
}
