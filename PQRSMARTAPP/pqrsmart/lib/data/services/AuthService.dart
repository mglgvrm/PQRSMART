import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/data/model/AuthResponse.dart';
import 'package:pqrsmart/data/model/user_model.dart';
import '../../core/constants/api_service.dart';

class AuthService {

  Future<AuthResponse> login(String user, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/authenticate'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user": user,
        "password": password,
      }),
    );
    if (kDebugMode) {
      print("el response ${response.body}");
    }
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error en login");
    }
  }
  Future<UserModel> register({
    required String user,
    required String name,
    required String lastName,
    required String email,
    required String password,
    required int identificationType,
    required int identificationNumber,
    required int personType,
    required int number,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/registerUser');

    // El backend espera los objetos relacionales como { "id": X }
    final body = jsonEncode({
      "user": user,
      "name": name,
      "lastName": lastName,
      "email": email,
      "password": password,
      "identificationType": {"idIdentificationType": identificationType},
      "identificationNumber": identificationNumber,
      "personType": {"idPersonType": personType},
      "number": number,
      "dependence":{"idDependence": 7 },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (kDebugMode) print("Response register: ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error en el registro');
    }
  }



}