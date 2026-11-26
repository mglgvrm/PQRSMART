import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pqrsmart/data/model/GeoHeatmapModel.dart';
import 'package:pqrsmart/data/model/MunicipalityBoundaryModel.dart';

// ==========================================
// MAPA DE CALOR - RASTER DE DENSIDAD
// ==========================================
// Convierte las celdas agregadas en una imagen georreferenciada superpuesta al mapa.
class GeoHeatmapRasterLayer extends StatefulWidget {
  const GeoHeatmapRasterLayer({
    super.key,
    required this.cells,
    required this.boundary,
  });

  final List<GeoHeatmapCellModel> cells;
  final MunicipalityBoundaryModel boundary;

  LatLngBounds get bounds => boundary.bounds;

  @override
  State<GeoHeatmapRasterLayer> createState() => _GeoHeatmapRasterLayerState();
}

class _GeoHeatmapRasterLayerState extends State<GeoHeatmapRasterLayer> {
  late Future<Uint8List?> _image;

  @override
  void initState() {
    super.initState();
    _image = _createImage();
  }

  @override
  void didUpdateWidget(covariant GeoHeatmapRasterLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cells != widget.cells ||
        oldWidget.boundary != widget.boundary) {
      _image = _createImage();
    }
  }

  Future<Uint8List?> _createImage() async {
    // Calcula los píxeles en un isolate y decodifica el resultado como imagen.
    if (widget.cells.isEmpty) return null;
    final pixels = await compute(_rasterizeHeatmap, {
      'cells': widget.cells
          .map(
            (cell) => <String, num>{
              'latitude': cell.latitude,
              'longitude': cell.longitude,
              'count': cell.count,
            },
          )
          .toList(),
      'west': widget.bounds.west,
      'east': widget.bounds.east,
      'south': widget.bounds.south,
      'north': widget.bounds.north,
      'size': 448,
      'polygons': _pixelPolygons(widget.boundary, widget.bounds),
    });

    final completer = Completer<Uint8List?>();
    ui.decodeImageFromPixels(pixels, 448, 448, ui.PixelFormat.rgba8888, (
      image,
    ) async {
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        completer.complete(data?.buffer.asUint8List());
      } finally {
        image.dispose();
      }
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: _image,
    builder: (context, snapshot) {
      final bytes = snapshot.data;
      if (bytes == null) return const SizedBox.shrink();
      return OverlayImageLayer(
        overlayImages: [
          OverlayImage(
            imageProvider: MemoryImage(bytes),
            bounds: widget.bounds,
            opacity: 0.78,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          ),
        ],
      );
    },
  );
}

@visibleForTesting
Uint8List rasterizeHeatmapForTest({
  required List<GeoHeatmapCellModel> cells,
  required MunicipalityBoundaryModel boundary,
  int size = 128,
}) {
  final bounds = boundary.bounds;
  return _rasterizeHeatmap({
    'cells': cells
        .map(
          (cell) => <String, num>{
            'latitude': cell.latitude,
            'longitude': cell.longitude,
            'count': cell.count,
          },
        )
        .toList(),
    'west': bounds.west,
    'east': bounds.east,
    'south': bounds.south,
    'north': bounds.north,
    'size': size,
    'polygons': _pixelPolygons(boundary, bounds, size: size),
  });
}

List<Map<String, dynamic>> _pixelPolygons(
  MunicipalityBoundaryModel boundary,
  LatLngBounds bounds, {
  int size = 448,
}) {
  // Proyecta los anillos municipales a las coordenadas del raster Web Mercator.
  final northY = _mercatorY(bounds.north);
  final yRange = _mercatorY(bounds.south) - northY;
  final xRange = bounds.east - bounds.west;

  List<List<double>> projectRing(List<LatLng> ring) => ring
      .map<List<double>>(
        (point) => [
          (point.longitude - bounds.west) / xRange * (size - 1),
          (_mercatorY(point.latitude) - northY) / yRange * (size - 1),
        ],
      )
      .toList();

  return boundary.polygons
      .map(
        (polygon) => <String, dynamic>{
          'outer': projectRing(polygon.outer),
          'holes': polygon.holes.map(projectRing).toList(),
        },
      )
      .toList();
}

Uint8List _rasterizeHeatmap(Map<String, dynamic> input) {
  // Acumula densidad gaussiana alrededor del centro de cada celda según su conteo.
  final size = input['size'] as int;
  final west = (input['west'] as num).toDouble();
  final east = (input['east'] as num).toDouble();
  final south = (input['south'] as num).toDouble();
  final north = (input['north'] as num).toDouble();
  final cells = (input['cells'] as List).cast<Map<String, num>>();
  final polygons = (input['polygons'] as List).cast<Map<String, dynamic>>();
  final density = Float32List(size * size);
  final sigma = size * 0.045;
  final radius = (sigma * 3).ceil();
  final northY = _mercatorY(north);
  final southY = _mercatorY(south);
  final yRange = southY - northY;
  final xRange = east - west;

  for (final cell in cells) {
    final latitude = cell['latitude']!.toDouble();
    final longitude = cell['longitude']!.toDouble();
    if (longitude < west ||
        longitude > east ||
        latitude < south ||
        latitude > north) {
      continue;
    }
    final centerX = ((longitude - west) / xRange * (size - 1)).round();
    final projectedY = _mercatorY(latitude);
    final centerY = ((projectedY - northY) / yRange * (size - 1)).round();
    final count = cell['count']!.toDouble();
    final minX = math.max(0, centerX - radius);
    final maxX = math.min(size - 1, centerX + radius);
    final minY = math.max(0, centerY - radius);
    final maxY = math.min(size - 1, centerY + radius);

    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        final dx = x - centerX;
        final dy = y - centerY;
        final distanceSquared = dx * dx + dy * dy;
        if (distanceSquared > radius * radius) continue;
        density[y * size + x] +=
            count * math.exp(-distanceSquared / (2 * sigma * sigma));
      }
    }
  }

  var maximum = 0.0;
  for (final value in density) {
    maximum = math.max(maximum, value);
  }
  final output = Uint8List(size * size * 4);
  if (maximum == 0) return output;

  for (var index = 0; index < density.length; index++) {
    final normalized = density[index] / maximum;
    if (normalized < 0.015) continue;
    final x = index % size;
    final y = index ~/ size;
    if (!_insidePolygons(x.toDouble(), y.toDouble(), polygons)) continue;
    final color = _densityColor(normalized);
    final offset = index * 4;
    output[offset] = color[0];
    output[offset + 1] = color[1];
    output[offset + 2] = color[2];
    output[offset + 3] = (220 * math.sqrt(normalized)).round();
  }
  return output;
}

bool _insidePolygons(double x, double y, List<Map<String, dynamic>> polygons) {
  // Recorta el raster al polígono municipal y respeta sus huecos interiores.
  for (final polygon in polygons) {
    final outer = (polygon['outer'] as List).cast<List<double>>();
    if (_insideRing(x, y, outer)) {
      final holes = (polygon['holes'] as List).cast<List<List<double>>>();
      if (!holes.any((hole) => _insideRing(x, y, hole))) return true;
    }
  }
  return false;
}

bool _insideRing(double x, double y, List<List<double>> ring) {
  var inside = false;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final current = ring[i];
    final previous = ring[j];
    if ((current[1] > y) != (previous[1] > y) &&
        x <
            (previous[0] - current[0]) *
                    (y - current[1]) /
                    (previous[1] - current[1]) +
                current[0]) {
      inside = !inside;
    }
  }
  return inside;
}

double _mercatorY(double latitude) {
  // Proyección vertical de latitud usada para alinear la imagen con los tiles.
  final clamped = latitude.clamp(-85.05112878, 85.05112878);
  final radians = clamped * math.pi / 180;
  return math.log(math.tan(math.pi / 4 + radians / 2));
}

List<int> _densityColor(double value) {
  // Interpola la escala azul-cian-amarillo-naranja-rojo según la densidad normalizada.
  const stops = <(double, int)>[
    (0.0, 0xFF1683E5),
    (0.25, 0xFF37C5D8),
    (0.5, 0xFFF0D34A),
    (0.75, 0xFFF28C28),
    (1.0, 0xFFE45D3F),
  ];
  for (var index = 0; index < stops.length - 1; index++) {
    final (start, startColor) = stops[index];
    final (end, endColor) = stops[index + 1];
    if (value > end) continue;
    final ratio = ((value - start) / (end - start)).clamp(0.0, 1.0);
    return [
      _mix((startColor >> 16) & 0xFF, (endColor >> 16) & 0xFF, ratio),
      _mix((startColor >> 8) & 0xFF, (endColor >> 8) & 0xFF, ratio),
      _mix(startColor & 0xFF, endColor & 0xFF, ratio),
    ];
  }
  const last = 0xFFE45D3F;
  return [(last >> 16) & 0xFF, (last >> 8) & 0xFF, last & 0xFF];
}

int _mix(int start, int end, double ratio) =>
    (start + (end - start) * ratio).round();
