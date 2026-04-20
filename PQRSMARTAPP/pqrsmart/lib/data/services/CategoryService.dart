import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/core/constants/api_service.dart';
import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';

class CategoryService {

  Future<List<CategoryModel>> getCategories() async {
    final storage = AuthStorage();
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
}