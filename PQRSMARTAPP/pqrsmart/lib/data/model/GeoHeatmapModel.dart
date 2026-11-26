// ==========================================
// MODELOS DEL MAPA DE CALOR Y SUS ZONAS
// ==========================================
// Representan la respuesta agregada del heatmap, las celdas y sus solicitudes.
// Los índices usan floor(coordenada / tamaño) para coincidir con Spring Boot.
int heatmapGridIndex(double coordinate, double gridCellSizeDegrees) =>
    (coordinate / gridCellSizeDegrees).floor();

// Respuesta general del endpoint /geo/heatmap, con filtros y celdas agregadas.
class GeoHeatmapModel {
  final bool boundaryAvailable;
  final String? message;
  final String period;
  final int totalRequests;
  final double gridCellSizeDegrees;
  final Map<String, int> typeDistribution;
  final List<GeoHeatmapCellModel> cells;

  const GeoHeatmapModel({
    required this.boundaryAvailable,
    required this.period,
    required this.totalRequests,
    required this.cells,
    this.gridCellSizeDegrees = 0.01,
    this.typeDistribution = const {},
    this.message,
  });

  factory GeoHeatmapModel.fromJson(Map<String, dynamic> json) {
    final cells = json['cells'] as List<dynamic>? ?? const [];
    return GeoHeatmapModel(
      boundaryAvailable: json['boundaryAvailable'] == true,
      message: json['message']?.toString(),
      period: json['period']?.toString() ?? 'Todas las fechas',
      totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
      gridCellSizeDegrees:
          (json['gridCellSizeDegrees'] as num?)?.toDouble() ?? 0.01,
      typeDistribution:
          (json['typeDistribution'] as Map<String, dynamic>? ?? {}).map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ),
      cells: cells
          .whereType<Map<String, dynamic>>()
          .map(GeoHeatmapCellModel.fromJson)
          .toList(),
    );
  }
}

// Centro, conteo y desgloses de una celda geográfica del heatmap.
class GeoHeatmapCellModel {
  final double latitude;
  final double longitude;
  final int latitudeIndex;
  final int longitudeIndex;
  final int count;
  final String mostFrequentType;
  final Map<String, int> statusDistribution;
  final Map<String, int> typeDistribution;
  final Map<String, int> categoryDistribution;
  final Map<String, int> dependenceDistribution;

  const GeoHeatmapCellModel({
    required this.latitude,
    required this.longitude,
    this.latitudeIndex = 0,
    this.longitudeIndex = 0,
    required this.count,
    required this.mostFrequentType,
    required this.statusDistribution,
    this.typeDistribution = const {},
    this.categoryDistribution = const {},
    this.dependenceDistribution = const {},
  });

  factory GeoHeatmapCellModel.fromJson(Map<String, dynamic> json) {
    final statuses = json['statusDistribution'] as Map<String, dynamic>? ?? {};
    Map<String, int> countMap(String key) =>
        (json[key] as Map<String, dynamic>? ?? {}).map(
          (name, value) => MapEntry(name, (value as num).toInt()),
        );
    return GeoHeatmapCellModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      latitudeIndex: (json['latitudeIndex'] as num?)?.toInt() ?? 0,
      longitudeIndex: (json['longitudeIndex'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      mostFrequentType: json['mostFrequentType']?.toString() ?? 'Sin tipo',
      statusDistribution: statuses.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      typeDistribution: countMap('typeDistribution'),
      categoryDistribution: countMap('categoryDistribution'),
      dependenceDistribution: countMap('dependenceDistribution'),
    );
  }
}

// Resumen y lista de solicitudes devueltos al seleccionar una celda.
class HeatmapZoneDetailsModel {
  const HeatmapZoneDetailsModel({
    required this.latitudeIndex,
    required this.longitudeIndex,
    required this.totalRequests,
    required this.requests,
    this.typeDistribution = const {},
    this.categoryDistribution = const {},
    this.dependenceDistribution = const {},
    this.statusDistribution = const {},
  });

  final int latitudeIndex;
  final int longitudeIndex;
  final int totalRequests;
  final Map<String, int> typeDistribution;
  final Map<String, int> categoryDistribution;
  final Map<String, int> dependenceDistribution;
  final Map<String, int> statusDistribution;
  final List<HeatmapZoneRequestModel> requests;

  factory HeatmapZoneDetailsModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> countMap(String key) =>
        (json[key] as Map<String, dynamic>? ?? {}).map(
          (name, value) => MapEntry(name, (value as num).toInt()),
        );
    return HeatmapZoneDetailsModel(
      latitudeIndex: (json['latitudeIndex'] as num?)?.toInt() ?? 0,
      longitudeIndex: (json['longitudeIndex'] as num?)?.toInt() ?? 0,
      totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
      typeDistribution: countMap('typeDistribution'),
      categoryDistribution: countMap('categoryDistribution'),
      dependenceDistribution: countMap('dependenceDistribution'),
      statusDistribution: countMap('statusDistribution'),
      requests: (json['requests'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(HeatmapZoneRequestModel.fromJson)
          .toList(),
    );
  }
}

// Campos no personales que el administrador necesita para identificar una PQRS.
class HeatmapZoneRequestModel {
  const HeatmapZoneRequestModel({
    required this.idRequest,
    required this.radicado,
    required this.requestType,
    required this.category,
    required this.dependence,
    required this.date,
    required this.state,
    required this.description,
    this.answer,
  });

  final int? idRequest;
  final String? radicado;
  final String requestType;
  final String category;
  final String dependence;
  final String date;
  final String state;
  final String description;
  final String? answer;

  factory HeatmapZoneRequestModel.fromJson(Map<String, dynamic> json) =>
      HeatmapZoneRequestModel(
        idRequest: (json['idRequest'] as num?)?.toInt(),
        radicado: json['radicado']?.toString(),
        requestType: json['requestType']?.toString() ?? 'Sin tipo',
        category: json['category']?.toString() ?? 'Sin categoría',
        dependence: json['dependence']?.toString() ?? 'Sin dependencia',
        date: json['date']?.toString() ?? '',
        state: json['state']?.toString() ?? 'Sin estado',
        description: json['description']?.toString() ?? '',
        answer: json['answer']?.toString(),
      );
}
