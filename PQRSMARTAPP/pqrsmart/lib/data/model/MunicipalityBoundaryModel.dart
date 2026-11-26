import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ==========================================
// MODELO DEL LÍMITE MUNICIPAL
// ==========================================
// Interpreta GeoJSON, calcula los límites del mapa y verifica puntos en polígonos.
class MunicipalityBoundaryModel {
  final List<MunicipalityPolygon> polygons;

  const MunicipalityBoundaryModel(this.polygons);

  factory MunicipalityBoundaryModel.fromGeoJson(Map<String, dynamic> geoJson) {
    // Acepta GeoJSON en forma de FeatureCollection, Feature o geometría directa.
    final polygons = <MunicipalityPolygon>[];
    final type = geoJson['type']?.toString();
    if (type == 'FeatureCollection') {
      for (final feature in geoJson['features'] as List<dynamic>? ?? const []) {
        final geometry = feature['geometry'] as Map<String, dynamic>?;
        if (geometry != null) _addGeometry(polygons, geometry);
      }
    } else if (type == 'Feature') {
      final geometry = geoJson['geometry'] as Map<String, dynamic>?;
      if (geometry != null) _addGeometry(polygons, geometry);
    } else {
      _addGeometry(polygons, geoJson);
    }

    if (polygons.isEmpty) {
      throw const FormatException(
        'El límite municipal oficial no contiene polígonos válidos.',
      );
    }
    return MunicipalityBoundaryModel(polygons);
  }

  List<LatLng> get allPoints =>
      polygons.expand((polygon) => polygon.outer).toList();

  LatLngBounds get bounds => LatLngBounds.fromPoints(allPoints);

  bool contains(LatLng point) {
    // Incluye el anillo exterior y excluye los huecos definidos en cada polígono.
    for (final polygon in polygons) {
      if (_containsRing(polygon.outer, point) &&
          !polygon.holes.any((hole) => _containsRing(hole, point))) {
        return true;
      }
    }
    return false;
  }
}

class MunicipalityPolygon {
  final List<LatLng> outer;
  final List<List<LatLng>> holes;

  const MunicipalityPolygon({required this.outer, required this.holes});
}

bool _containsRing(List<LatLng> ring, LatLng point) {
  var inside = false;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final current = ring[i];
    final previous = ring[j];
    final crossesLatitude =
        (current.latitude > point.latitude) !=
        (previous.latitude > point.latitude);
    if (crossesLatitude) {
      final crossingLongitude =
          (previous.longitude - current.longitude) *
              (point.latitude - current.latitude) /
              (previous.latitude - current.latitude) +
          current.longitude;
      if (point.longitude < crossingLongitude) inside = !inside;
    }
  }
  return inside;
}

void _addGeometry(
  List<MunicipalityPolygon> polygons,
  Map<String, dynamic> geometry,
) {
  // Convierte Polygon y MultiPolygon al modelo que usan los mapas.
  final coordinates = geometry['coordinates'] as List<dynamic>?;
  if (geometry['type'] == 'Polygon' && coordinates != null) {
    _addPolygon(polygons, coordinates);
  } else if (geometry['type'] == 'MultiPolygon' && coordinates != null) {
    for (final polygon in coordinates) {
      _addPolygon(polygons, polygon as List<dynamic>);
    }
  } else {
    throw const FormatException(
      'El GeoJSON municipal debe contener Polygon o MultiPolygon.',
    );
  }
}

void _addPolygon(List<MunicipalityPolygon> polygons, List<dynamic> rings) {
  final parsedRings = rings.map((ring) {
    final coordinates = ring as List<dynamic>;
    final points = coordinates.map((coordinate) {
      final pair = coordinate as List<dynamic>;
      if (pair.length < 2) {
        throw const FormatException(
          'El GeoJSON contiene una coordenada incompleta.',
        );
      }
      final longitude = (pair[0] as num).toDouble();
      final latitude = (pair[1] as num).toDouble();
      if (!latitude.isFinite ||
          !longitude.isFinite ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        throw const FormatException(
          'El GeoJSON contiene una coordenada inválida.',
        );
      }
      return LatLng(latitude, longitude);
    }).toList();
    if (points.length < 4) {
      throw const FormatException('El GeoJSON contiene un anillo incompleto.');
    }
    return points;
  }).toList();

  if (parsedRings.isNotEmpty) {
    polygons.add(
      MunicipalityPolygon(
        outer: parsedRings.first,
        holes: parsedRings.skip(1).toList(),
      ),
    );
  }
}
