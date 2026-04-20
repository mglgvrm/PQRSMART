// person_type_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import '../../core/constants/api_service.dart';

class PersonTypeService {
  Future<List<PersonTypeModal>> getAll() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/person_type/get'),
      headers: {"Content-Type": "application/json"},
    );

    if (kDebugMode) print("Response person_type: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PersonTypeModal.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener tipos de persona");
    }
  }
}