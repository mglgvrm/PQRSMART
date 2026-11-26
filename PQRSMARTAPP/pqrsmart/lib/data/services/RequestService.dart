import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pqrsmart/core/constants/api_service.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/model/GeoHeatmapModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/data/model/RequestStateHistoryModel.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';

// ==========================================
// SERVICIO API - MAPA Y CONSULTA GEOGRÁFICA
// ==========================================
// Adjunta autenticación, envía filtros y convierte las respuestas del backend.
class RequestService {
  final storage = AuthStorage();

  Future<Map<String, String>> _authorizedHeaders() async {
    final token = await storage.getToken();
    if (token == null || token.isEmpty) {
      throw StateError('La sesión expiró. Inicia sesión nuevamente.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> getMunicipalityBoundary() async {
    // Descarga el GeoJSON oficial utilizado por ambos mapas del Dashboard.
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/geo/municipality'),
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'No fue posible cargar el límite municipal (${response.statusCode}).',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<GeoHeatmapModel> getHeatmap({
    DateTime? from,
    DateTime? to,
    int? requestTypeId,
    int? requestStateId,
  }) async {
    // Consulta conteos y celdas; se omiten los filtros que no fueron seleccionados.
    final uri = Uri.parse('${ApiConstants.baseUrl}/request/geo/heatmap')
        .replace(
          queryParameters: _heatmapQueryParameters(
            from: from,
            to: to,
            requestTypeId: requestTypeId,
            requestStateId: requestStateId,
          ),
        );
    final response = await http.get(uri, headers: await _authorizedHeaders());
    if (response.statusCode == 200) {
      return GeoHeatmapModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      response.body.isNotEmpty
          ? response.body
          : 'No fue posible cargar el mapa de calor (${response.statusCode}).',
    );
  }

  Future<HeatmapZoneDetailsModel> getHeatmapZoneDetails({
    required int latitudeIndex,
    required int longitudeIndex,
    DateTime? from,
    DateTime? to,
    int? requestTypeId,
    int? requestStateId,
  }) async {
    // Reutiliza filtros del heatmap y agrega los índices de la celda seleccionada.
    final parameters =
        _heatmapQueryParameters(
          from: from,
          to: to,
          requestTypeId: requestTypeId,
          requestStateId: requestStateId,
        )..addAll({
          'latitudeIndex': latitudeIndex.toString(),
          'longitudeIndex': longitudeIndex.toString(),
        });
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/request/geo/heatmap/cell',
    ).replace(queryParameters: parameters);
    final response = await http.get(uri, headers: await _authorizedHeaders());
    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'No fue posible consultar las PQRS de esta zona (${response.statusCode}).',
      );
    }
    return HeatmapZoneDetailsModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Map<String, String> _heatmapQueryParameters({
    DateTime? from,
    DateTime? to,
    int? requestTypeId,
    int? requestStateId,
  }) {
    // Serializa las fechas ISO y los IDs de tipo/estado para ambos endpoints.
    final parameters = <String, String>{};
    if (from != null) parameters['from'] = _dateOnly(from);
    if (to != null) parameters['to'] = _dateOnly(to);
    if (requestTypeId != null) {
      parameters['requestTypeId'] = requestTypeId.toString();
    }
    if (requestStateId != null) {
      parameters['requestStateId'] = requestStateId.toString();
    }
    return parameters;
  }

  Future<List<RequestStateModel>> getRequestStates() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request_state/get'),
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'No fue posible cargar los estados (${response.statusCode}).',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => RequestStateModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RequestStateHistoryModel>> getStateHistory(int requestId) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/$requestId/history'),
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception(
        response.body.isNotEmpty
            ? response.body
            : 'No fue posible consultar el historial (${response.statusCode}).',
      );
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (item) =>
              RequestStateHistoryModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  Future<RequestModel> saveAssisted(RequestModel requestModel) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/request/save/assisted'),
      headers: await _authorizedHeaders(),
      body: jsonEncode(requestModel.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RequestModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      response.body.isNotEmpty
          ? response.body
          : 'No fue posible registrar la solicitud (${response.statusCode}).',
    );
  }

  Future<List<RequestModel>> getAll() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/get/pqrs'),
      headers: await _authorizedHeaders(),
    );
    if (kDebugMode) {
      print("el response ${response.body}");
    }
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RequestModel.fromJson(e)).toList();
    } else {
      throw Exception("Error en al obtener usuarios");
    }
  }

  Future<List<RequestModel>> getAllForAdministration() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/get'),
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RequestModel.fromJson(e)).toList();
    }
    throw Exception(
      'Error al obtener solicitudes administrativas: ${response.statusCode}',
    );
  }

  Future<List<RequestModel>> getForDependence() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/request/getForDependence'),
      headers: await _authorizedHeaders(),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => RequestModel.fromJson(e)).toList();
    }
    throw Exception(
      'Error al obtener solicitudes de la dependencia: ${response.statusCode}',
    );
  }

  Future<RequestModel> answerRequest(int idRequest, String answer) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/request/update/$idRequest'),
      headers: await _authorizedHeaders(),
      body: jsonEncode({"answer": answer}),
    );
    if (response.statusCode == 200) {
      return RequestModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al responder la solicitud: ${response.statusCode}');
  }

  Future<void> updateRequestState(
    int idRequest, {
    required int stateId,
    String? observation,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/request/$idRequest/state'),
      headers: await _authorizedHeaders(),
      body: jsonEncode({'idRequestState': stateId, 'observation': observation}),
    );
    if (response.statusCode == 200) return;
    final message = response.body.trim();
    throw Exception(
      message.isNotEmpty
          ? message
          : 'No fue posible actualizar el estado (${response.statusCode}).',
    );
  }

  Future<RequestModel> save(RequestModel requestModel) async {
    print("EVENTO RECIBIDO ${requestModel}");
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/request/save'),
      headers: await _authorizedHeaders(),
      body: jsonEncode(requestModel.toJson()), // ✅
    );
    print("response ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      print("exito ${response.body}");
      return RequestModel.fromJson(jsonDecode(response.body));
    } else {
      final detail = response.body.trim();
      throw Exception(
        detail.isNotEmpty
            ? detail
            : 'Error al guardar la solicitud: ${response.statusCode}',
      );
    }
  }

  Future<void> cancel(int idRequest) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/request/cancel/$idRequest'),
      headers: await _authorizedHeaders(),
      body: jsonEncode(<String, dynamic>{}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al cancelar la solicitud: ${response.statusCode}');
    }
  }
}
