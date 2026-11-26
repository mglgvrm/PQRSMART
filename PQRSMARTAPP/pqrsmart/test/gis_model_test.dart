import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pqrsmart/data/model/GeoHeatmapModel.dart';
import 'package:pqrsmart/data/model/MunicipalityBoundaryModel.dart';
import 'package:pqrsmart/presentation/widgets/geo_heatmap_raster.dart';

// Comprueba GeoJSON, modelos de respuesta, índices y raster del mapa geográfico.
void main() {
  group('MunicipalityBoundaryModel', () {
    test('parses GeoJSON coordinates in longitude-latitude order', () {
      final boundary = MunicipalityBoundaryModel.fromGeoJson({
        'type': 'Polygon',
        'coordinates': [
          [
            [0, 0],
            [1, 0],
            [1, 1],
            [0, 1],
            [0, 0],
          ],
          [
            [0.4, 0.4],
            [0.6, 0.4],
            [0.6, 0.6],
            [0.4, 0.6],
            [0.4, 0.4],
          ],
        ],
      });

      expect(boundary.contains(const LatLng(0.2, 0.2)), isTrue);
      expect(boundary.contains(const LatLng(0.5, 0.5)), isFalse);
      expect(boundary.contains(const LatLng(1.5, 0.5)), isFalse);
    });

    test('accepts a MultiPolygon boundary', () {
      final boundary = MunicipalityBoundaryModel.fromGeoJson({
        'type': 'MultiPolygon',
        'coordinates': [
          [
            [
              [0, 0],
              [1, 0],
              [1, 1],
              [0, 1],
              [0, 0],
            ],
          ],
          [
            [
              [2, 2],
              [3, 2],
              [3, 3],
              [2, 3],
              [2, 2],
            ],
          ],
        ],
      });

      expect(boundary.polygons, hasLength(2));
    });

    test('parses the FeatureCollection returned by the boundary endpoint', () {
      final boundary = MunicipalityBoundaryModel.fromGeoJson({
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [-75.3, 10.4],
                  [-75.2, 10.4],
                  [-75.2, 10.5],
                  [-75.3, 10.5],
                  [-75.3, 10.4],
                ],
              ],
            },
          },
        ],
      });

      expect(boundary.polygons, hasLength(1));
      expect(boundary.contains(const LatLng(10.45, -75.25)), isTrue);
    });
  });

  test('parses privacy-safe heatmap cell summaries', () {
    final heatmap = GeoHeatmapModel.fromJson({
      'boundaryAvailable': true,
      'period': 'Todas las fechas',
      'totalRequests': 4,
      'gridCellSizeDegrees': 0.01,
      'typeDistribution': {'Petición': 3, 'Queja': 1},
      'cells': [
        {
          'latitude': 0.5,
          'longitude': 0.5,
          'latitudeIndex': 50,
          'longitudeIndex': 50,
          'count': 4,
          'mostFrequentType': 'Petición',
          'statusDistribution': {'Pendiente': 2, 'Finalizado': 2},
          'typeDistribution': {'Petición': 3, 'Queja': 1},
          'categoryDistribution': {'Alumbrado': 3, 'Vías': 1},
          'dependenceDistribution': {
            'Dependencia agregada dinámicamente': 3,
            'Obras': 1,
          },
        },
      ],
    });

    expect(heatmap.totalRequests, 4);
    expect(heatmap.cells.single.count, 4);
    expect(heatmap.cells.single.statusDistribution['Pendiente'], 2);
    expect(heatmap.typeDistribution['Petición'], 3);
    expect(heatmap.gridCellSizeDegrees, 0.01);
    expect(heatmap.cells.single.latitudeIndex, 50);
    expect(
      heatmap
          .cells
          .single
          .dependenceDistribution['Dependencia agregada dinámicamente'],
      3,
    );
  });

  test(
    'heatmap grid indices match backend flooring for negative coordinates',
    () {
      expect(heatmapGridIndex(10.123, 0.01), 1012);
      expect(heatmapGridIndex(-75.123, 0.01), -7513);
    },
  );

  test(
    'parses a zone detail response with dynamic category and dependence',
    () {
      final zone = HeatmapZoneDetailsModel.fromJson({
        'latitudeIndex': 1012,
        'longitudeIndex': -7513,
        'totalRequests': 1,
        'typeDistribution': {'Queja': 1},
        'categoryDistribution': {'Alumbrado': 1},
        'dependenceDistribution': {'Secretaría dinámica': 1},
        'statusDistribution': {'Pendiente': 1},
        'requests': [
          {
            'idRequest': 42,
            'radicado': 'PQR-42',
            'requestType': 'Queja',
            'category': 'Alumbrado',
            'dependence': 'Secretaría dinámica',
            'date': '2026-11-19',
            'state': 'Pendiente',
            'description': 'Luminaria fuera de servicio',
          },
        ],
      });

      expect(zone.totalRequests, 1);
      expect(zone.dependenceDistribution['Secretaría dinámica'], 1);
      expect(zone.requests.single.radicado, 'PQR-42');
      expect(zone.requests.single.description, 'Luminaria fuera de servicio');
    },
  );

  test('rasterizes a continuous density with a stronger center', () {
    final pixels = rasterizeHeatmapForTest(
      cells: const [
        GeoHeatmapCellModel(
          latitude: 0,
          longitude: 0,
          count: 4,
          mostFrequentType: 'Petición',
          statusDistribution: {},
        ),
      ],
      boundary: _squareBoundary(),
    );

    int alphaAt(int x, int y) => pixels[(y * 128 + x) * 4 + 3];

    expect(alphaAt(64, 64), 220);
    expect(alphaAt(74, 64), greaterThan(0));
    expect(alphaAt(74, 64), lessThan(alphaAt(64, 64)));
    expect(alphaAt(94, 64), 0);
  });

  test('does not render cells outside the municipality bounds', () {
    final pixels = rasterizeHeatmapForTest(
      cells: const [
        GeoHeatmapCellModel(
          latitude: 2,
          longitude: 2,
          count: 1,
          mostFrequentType: 'Petición',
          statusDistribution: {},
        ),
      ],
      boundary: _squareBoundary(),
    );

    expect(pixels.every((channel) => channel == 0), isTrue);
  });

  test('clips the raster to the municipal polygon', () {
    final boundary = MunicipalityBoundaryModel.fromGeoJson({
      'type': 'Polygon',
      'coordinates': [
        [
          [-1, -1],
          [1, -1],
          [-1, 1],
          [-1, -1],
        ],
      ],
    });
    final pixels = rasterizeHeatmapForTest(
      cells: const [
        GeoHeatmapCellModel(
          latitude: -0.1,
          longitude: -0.1,
          count: 1,
          mostFrequentType: 'Petición',
          statusDistribution: {},
        ),
      ],
      boundary: boundary,
    );

    int alphaAt(int x, int y) => pixels[(y * 128 + x) * 4 + 3];

    expect(alphaAt(58, 70), greaterThan(0));
    expect(alphaAt(67, 60), 0);
  });
}

MunicipalityBoundaryModel _squareBoundary() =>
    MunicipalityBoundaryModel.fromGeoJson({
      'type': 'Polygon',
      'coordinates': [
        [
          [-1, -1],
          [1, -1],
          [1, 1],
          [-1, 1],
          [-1, -1],
        ],
      ],
    });
