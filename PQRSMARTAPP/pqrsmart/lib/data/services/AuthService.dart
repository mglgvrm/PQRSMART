import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/data/model/AuthResponse.dart';
import 'package:pqrsmart/data/model/user_model.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import '../../core/constants/api_service.dart';

class AuthService {
  final storage = AuthStorage();

  Future<AuthResponse> login(String user, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/authenticate'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user": user, "password": password}),
    );
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error en login");
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) return;

    var message = response.body.trim();
    try {
      final error = jsonDecode(response.body);
      if (error is Map<String, dynamic>) {
        message = error['message']?.toString() ?? message;
      } else if (error is String) {
        message = error;
      }
    } on FormatException {
      // The Spring endpoint may return a plain-text error.
    }
    throw Exception(
      message.isEmpty
          ? 'No fue posible solicitar la recuperación de contraseña.'
          : message,
    );
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
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/registerUserApp');

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
      "dependence": {"idDependence": 7},
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else {
      var message = response.body.trim();
      try {
        final error = jsonDecode(response.body);
        if (error is Map<String, dynamic>) {
          message = error['message']?.toString() ?? message;
        } else if (error is String) {
          message = error;
        }
      } on FormatException {
        // Some existing Spring endpoints return plain-text validation errors.
      }
      throw Exception(
        message.isEmpty ? 'No fue posible crear la cuenta.' : message,
      );
    }
  }

  Future<UserModel> registerAdmin({
    required String user,
    required String name,
    required String lastName,
    required String email,
    required String password,
    required int identificationType,
    required int identificationNumber,
    required int personType,
    required int number,
    required String role,
    required int dependence,
  }) async {
    final token = await storage.getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/registerApp');

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
      "dependence": {"idDependence": dependence},
      "role": role,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error en el registro');
    }
  }
}
