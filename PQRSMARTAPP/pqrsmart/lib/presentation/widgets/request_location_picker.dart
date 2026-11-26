import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/MunicipalityBoundaryModel.dart';
import 'package:pqrsmart/data/services/RequestService.dart';

class RequestLocationSelection {
  final LatLng point;
  final String method;
  final DateTime capturedAt;

  const RequestLocationSelection({
    required this.point,
    required this.method,
    required this.capturedAt,
  });
}

class RequestLocationPicker extends StatefulWidget {
  final RequestLocationSelection? selection;
  final ValueChanged<RequestLocationSelection?> onChanged;

  const RequestLocationPicker({
    super.key,
    required this.selection,
    required this.onChanged,
  });

  @override
  State<RequestLocationPicker> createState() => _RequestLocationPickerState();
}

class _RequestLocationPickerState extends State<RequestLocationPicker> {
  bool _loading = false;
  final _requestService = RequestService();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'La ubicación se usa solo para identificar dónde ocurre el problema. '
        'No se activa el seguimiento del dispositivo.',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      const SizedBox(height: 10),
      if (widget.selection != null) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceBlue,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.selection!.point.latitude.toStringAsFixed(5)}, '
                  '${widget.selection!.point.longitude.toStringAsFixed(5)}'
                  ' · ${widget.selection!.method}',
                  style: const TextStyle(color: AppColors.text, fontSize: 12),
                ),
              ),
              IconButton(
                tooltip: 'Quitar ubicación',
                onPressed: () => widget.onChanged(null),
                icon: const Icon(Icons.close, size: 19),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
      Wrap(
        spacing: 9,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _loading ? null : _useGps,
            icon: const Icon(Icons.my_location_outlined),
            label: const Text('Usar mi ubicación'),
          ),
          OutlinedButton.icon(
            onPressed: _loading ? null : _selectOnMap,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Seleccionar ubicación en el mapa'),
          ),
        ],
      ),
      if (_loading) ...[
        const SizedBox(height: 8),
        const LinearProgressIndicator(minHeight: 2),
      ],
    ],
  );

  Future<void> _useGps() async {
    setState(() => _loading = true);
    try {
      final boundary = MunicipalityBoundaryModel.fromGeoJson(
        await _requestService.getMunicipalityBoundary(),
      );
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Activa el servicio de ubicación para continuar.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'No se concedió el permiso de ubicación. Puedes seleccionar el punto manualmente.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      if (!boundary.contains(point)) {
        throw Exception(
          'La ubicación GPS está fuera del límite municipal de Villanueva, Bolívar.',
        );
      }
      final selection = await _openMap(
        boundary,
        initialPoint: point,
        initialMethod: 'GPS',
      );
      if (selection != null) widget.onChanged(selection);
    } catch (error) {
      _showMessage(_readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectOnMap() async {
    setState(() => _loading = true);
    try {
      final boundary = MunicipalityBoundaryModel.fromGeoJson(
        await _requestService.getMunicipalityBoundary(),
      );
      final selection = await _openMap(boundary);
      if (selection != null) widget.onChanged(selection);
    } catch (error) {
      _showMessage(_readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<RequestLocationSelection?> _openMap(
    MunicipalityBoundaryModel boundary, {
    LatLng? initialPoint,
    String? initialMethod,
  }) => showDialog<RequestLocationSelection>(
    context: context,
    builder: (_) => _BoundaryPickerDialog(
      boundary: boundary,
      initialPoint: initialPoint,
      initialMethod: initialMethod,
    ),
  );

  String _readableError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    if (message.contains('SocketException') ||
        message.contains('ClientException')) {
      return 'No se pudo consultar el límite oficial. Verifica tu conexión y vuelve a intentar.';
    }
    return message;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }
}

class _BoundaryPickerDialog extends StatefulWidget {
  final MunicipalityBoundaryModel boundary;
  final LatLng? initialPoint;
  final String? initialMethod;

  const _BoundaryPickerDialog({
    required this.boundary,
    this.initialPoint,
    this.initialMethod,
  });

  @override
  State<_BoundaryPickerDialog> createState() => _BoundaryPickerDialogState();
}

class _BoundaryPickerDialogState extends State<_BoundaryPickerDialog> {
  late LatLng? _point = widget.initialPoint;
  late String? _method = widget.initialMethod;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ubicación del problema'),
    content: SizedBox(
      width: 640,
      height: 390,
      child: Column(
        children: [
          const Text(
            'Toca el lugar del problema en el mapa. Puedes volver a tocar para ajustar el punto.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      widget.initialPoint ?? widget.boundary.bounds.center,
                  initialCameraFit: CameraFit.bounds(
                    bounds: widget.boundary.bounds,
                    padding: const EdgeInsets.all(24),
                  ),
                  minZoom: 8,
                  maxZoom: 18,
                  onTap: (_, point) {
                    if (!_contains(point)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Selecciona un punto dentro del límite municipal.',
                          ),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _point = point;
                      _method = 'MANUAL';
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'co.gov.villanueva.pqrsmart',
                  ),
                  PolygonLayer(
                    polygons: widget.boundary.polygons
                        .map(
                          (polygon) => Polygon(
                            points: polygon.outer,
                            holePointsList: polygon.holes,
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderColor: AppColors.primary,
                            borderStrokeWidth: 2,
                          ),
                        )
                        .toList(),
                  ),
                  if (_point != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _point!,
                          width: 36,
                          height: 42,
                          child: const Icon(
                            Icons.location_pin,
                            color: AppColors.cancelled,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'Límite municipal oficial · Mapa © OpenStreetMap',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_point != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_point!.latitude.toStringAsFixed(5)}, '
                '${_point!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(color: AppColors.text, fontSize: 12),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _point == null
            ? null
            : () => Navigator.pop(
                context,
                RequestLocationSelection(
                  point: _point!,
                  method: _method ?? 'MANUAL',
                  capturedAt: DateTime.now(),
                ),
              ),
        child: const Text('Confirmar ubicación'),
      ),
    ],
  );

  bool _contains(LatLng point) {
    return widget.boundary.contains(point);
  }
}
