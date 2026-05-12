import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/core/constants/api_service.dart';
import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';

class CategoryService {
  final storage = AuthStorage();
  Future<List<CategoryModel>> getCategories() async {

    final token   = await storage.getToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/category/get'), // ← ajusta el endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print('Response categories: $data');
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener categorías: ${response.statusCode}');
    }
  }
  Future<CategoryModel> saveCategory(
      CategoryModel categoryModel,
      ) async
  {
    final token = await storage.getToken();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/category/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(categoryModel.toJson()),
    );

    if (kDebugMode) {
      print("el response ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (kDebugMode) {
        print('Response category: $data');
      }

      return CategoryModel.fromJson(data);
    } else {
      throw Exception('Error al guardar categoria: ${response.statusCode}');
    }
  }
  Future<CategoryModel> activateCategory(
      int id
      ) async {
    final token = await storage.getToken();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/category/activate/$id'),
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
        print('Response category: $data');
      }

      return CategoryModel.fromJson(data);
    } else {
      throw Exception('Error al guardar categoria: ${response.statusCode}');
    }
  }
  Future<CategoryModel> cancelCategory(
      int id
      ) async {
    final token = await storage.getToken();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/category/cancel/$id'),
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
        print('Response category: $data');
      }

      return CategoryModel.fromJson(data);
    } else {
      throw Exception('Error al guardar categoria: ${response.statusCode}');
    }
  }
}