// identification_type_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/data/model/IdentificationTypeModal.dart';
import '../../core/constants/api_service.dart';

class IdentificationTypeService {
  Future<List<IdentificationTypeModal>> getAll() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/identification_type/get'),
      headers: {"Content-Type": "application/json"},
    );

    if (kDebugMode) print("Response identification_type: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => IdentificationTypeModal.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener tipos de identificación");
    }
  }
}