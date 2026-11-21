// person_type_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/data/model/PersonTypeModal.dart';
import '../../core/constants/api_service.dart';

class PersonTypeService {
  Future<List<PersonTypeModal>> getAll() async {
    late final http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/person_type/get'),
            headers: {"Content-Type": "application/json"},
          )
          .timeout(ApiConstants.requestTimeout);
    } on TimeoutException {
      throw Exception(
        'Tiempo de espera agotado al consultar los tipos de persona en ${ApiConstants.baseUrl}.',
      );
    } on Exception catch (error) {
      final detail = error.toString();
      if (detail.toLowerCase().contains('timed out')) {
        throw Exception(
          'Tiempo de espera agotado al conectar con la API '
          '(${ApiConstants.baseUrl}). Comprueba el backend y la dirección '
          'de red. Detalle: $detail',
        );
      }
      throw Exception(
        'No fue posible conectar con la API (${ApiConstants.baseUrl}). '
        'Verifica que el backend esté iniciado y que la dirección corresponda '
        'a este dispositivo. Detalle: $detail',
      );
    }

    if (kDebugMode) print("Response person_type: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List<dynamic>) {
        throw const FormatException(
          'El backend devolvió un formato inválido para los tipos de persona.',
        );
      }
      final data = decoded;
      return data.map((e) => PersonTypeModal.fromJson(e)).toList();
    } else {
      throw Exception(
        'Error al obtener tipos de persona (${response.statusCode}).',
      );
    }
  }
}
