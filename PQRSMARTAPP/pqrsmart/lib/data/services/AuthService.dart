import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/data/model/AuthResponse.dart';
import 'package:pqrsmart/data/model/user_model.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import '../../core/constants/api_service.dart';

class AuthService {
  final storage = AuthStorage();

  String _responseErrorMessage(http.Response response, String fallback) {
    final body = response.body.trim();
    if (body.isEmpty ||
        response.headers['content-type']?.toLowerCase().contains('text/html') ==
            true ||
        body.startsWith('<')) {
      return '$fallback (HTTP ${response.statusCode}).';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        for (final key in ['message', 'detail', 'error']) {
          final value = decoded[key]?.toString().trim();
          if (value != null && value.isNotEmpty) return value;
        }
      } else if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }
    } on FormatException {
      return body;
    }
    return '$fallback (HTTP ${response.statusCode}).';
  }

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

    throw Exception(
      _responseErrorMessage(
        response,
        'No fue posible solicitar la recuperación de contraseña',
      ),
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
      throw Exception(
        _responseErrorMessage(response, 'No fue posible crear la cuenta'),
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
    if (token == null || token.isEmpty) {
      throw StateError(
        'La sesión administrativa expiró. Inicia sesión nuevamente.',
      );
    }
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
      dynamic json;
      try {
        json = jsonDecode(response.body);
      } on FormatException {
        throw const FormatException(
          'El servidor no confirmó el registro con una respuesta JSON válida.',
        );
      }
      return UserModel.fromJson(json);
    } else {
      throw Exception(
        _responseErrorMessage(response, 'No fue posible registrar el usuario'),
      );
    }
  }
}
