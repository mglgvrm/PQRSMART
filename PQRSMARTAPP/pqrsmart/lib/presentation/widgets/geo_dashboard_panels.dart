import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/GeoHeatmapModel.dart';
import 'package:pqrsmart/data/model/MunicipalityBoundaryModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/data/model/RequestTypeModel.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/RequestTypeService.dart';
import 'package:pqrsmart/presentation/widgets/geo_heatmap_raster.dart';

// ==========================================
// MAPAS GEOGRÁFICOS - FUENTES Y CAPAS BASE
// ==========================================
// Define mapas base disponibles y el selector compartido de capas.
enum _MapBaseStyle { standard, terrain, satellite, dark }

extension on _MapBaseStyle {
  String get label => switch (this) {
    _MapBaseStyle.standard => 'Estándar',
    _MapBaseStyle.terrain => 'Terreno',
    _MapBaseStyle.satellite => 'Satelital',
    _MapBaseStyle.dark => 'Oscuro',
  };

  String get urlTemplate => switch (this) {
    _MapBaseStyle.standard => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    _MapBaseStyle.terrain =>
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
    _MapBaseStyle.satellite =>
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    _MapBaseStyle.dark =>
      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
  };

  String get attribution => switch (this) {
    _MapBaseStyle.standard => '© OpenStreetMap contributors',
    _MapBaseStyle.terrain => 'Tiles © Esri · Sources: Esri, USGS, NOAA',
    _MapBaseStyle.satellite =>
      'Imagery © Esri · Sources: Esri, Maxar, Earthstar Geographics',
    _MapBaseStyle.dark => '© OpenStreetMap contributors · © CARTO',
  };
}

Future<void> _showMapLayers({
  required BuildContext context,
  required _MapBaseStyle initialBase,
  required ValueChanged<_MapBaseStyle> onBaseChanged,
  required Map<String, String> overlays,
  required Map<String, bool> overlayValues,
  required ValueChanged<String> onOverlayChanged,
  required Set<String> unavailableOverlays,
}) async {
  // El diálogo cambia el mapa base y activa o desactiva capas superpuestas.
  var selected = initialBase;
  final selectedOverlays = Map<String, bool>.from(overlayValues);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Capas del mapa',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<_MapBaseStyle>(
              groupValue: selected,
              onChanged: (value) {
                if (value == null) return;
                setSheetState(() => selected = value);
                onBaseChanged(value);
              },
              child: Column(
                children: [
                  for (final style in _MapBaseStyle.values)
                    RadioListTile<_MapBaseStyle>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(style.label),
                      value: style,
                    ),
                ],
              ),
            ),
            const Divider(),
            for (final entry in overlays.entries)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(entry.value),
                subtitle: unavailableOverlays.contains(entry.key)
                    ? const Text('Fuente geográfica verificada no disponible')
                    : null,
                value: selectedOverlays[entry.key] ?? false,
                onChanged: unavailableOverlays.contains(entry.key)
                    ? null
                    : (value) {
                        setSheetState(
                          () => selectedOverlays[entry.key] = value,
                        );
                        onOverlayChanged(entry.key);
                      },
              ),
          ],
        ),
      ),
    ),
  );
}

class TerritoryMapPanel extends StatefulWidget {
  const TerritoryMapPanel({super.key});

  @override
  State<TerritoryMapPanel> createState() => _TerritoryMapPanelState();
}

// ==========================================
// MAPA TERRITORIAL - LÍMITE MUNICIPAL
// ==========================================
// Carga el GeoJSON oficial y dibuja el contorno municipal sobre el mapa base.
class _TerritoryMapPanelState extends State<TerritoryMapPanel> {
  final _requestService = RequestService();
  final _mapController = MapController();
  MunicipalityBoundaryModel? _boundary;
  String? _error;
  bool _mapReady = false;
  bool _showBoundary = true;
  _MapBaseStyle _baseStyle = _MapBaseStyle.standard;

  @override
  void initState() {
    super.initState();
    _loadBoundary();
  }

  Future<void> _loadBoundary() async {
    try {
      final boundary = MunicipalityBoundaryModel.fromGeoJson(
        await _requestService.getMunicipalityBoundary(),
      );
      if (!mounted) return;
      setState(() {
        _boundary = boundary;
        _error = null;
      });
      _fitBoundary();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _readableError(error));
    }
  }

  void _fitBoundary() {
    if (!_mapReady || _boundary == null) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: _boundary!.bounds,
        padding: const EdgeInsets.all(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _MapCard(
    title: 'Villanueva, Bolívar',
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Capas',
          onPressed: () => _showMapLayers(
            context: context,
            initialBase: _baseStyle,
            onBaseChanged: (style) => setState(() => _baseStyle = style),
            overlays: const {
              'boundary': 'Límite municipal oficial',
              'urban': 'Casco urbano',
              'sectors': 'Barrios y sectores',
            },
            overlayValues: {
              'boundary': _showBoundary,
              'urban': false,
              'sectors': false,
            },
            onOverlayChanged: (layer) {
              if (layer == 'boundary') {
                setState(() => _showBoundary = !_showBoundary);
              }
            },
            unavailableOverlays: const {'urban', 'sectors'},
          ),
          icon: const Icon(Icons.layers_outlined, color: AppColors.primary),
        ),
        IconButton(
          tooltip: 'Actualizar límite',
          onPressed: _loadBoundary,
          icon: const Icon(Icons.refresh, color: AppColors.primary),
        ),
      ],
    ),
    map: Column(
      children: [
        SizedBox(
          height: 300,
          child: _boundary == null
              ? _BoundaryUnavailable(message: _error)
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _boundary!.bounds.center,
                    initialCameraFit: CameraFit.bounds(
                      bounds: _boundary!.bounds,
                      padding: const EdgeInsets.all(24),
                    ),
                    minZoom: 8,
                    maxZoom: 18,
                    onMapReady: () {
                      _mapReady = true;
                      _fitBoundary();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _baseStyle.urlTemplate,
                      userAgentPackageName: 'co.gov.villanueva.pqrsmart',
                    ),
                    if (_showBoundary)
                      PolygonLayer(
                        polygons: _boundary!.polygons
                            .map(
                              (polygon) => Polygon(
                                points: polygon.outer,
                                holePointsList: polygon.holes,
                                color: AppColors.primary.withValues(
                                  alpha: 0.13,
                                ),
                                borderColor: AppColors.primary,
                                borderStrokeWidth: 2,
                              ),
                            )
                            .toList(),
                      ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(_baseStyle.attribution),
                      ],
                    ),
                  ],
                ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(13, 8, 13, 11),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'El casco urbano y los barrios no se dibujan hasta contar con capas geográficas verificadas.',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ),
        ),
      ],
    ),
  );
}

class HeatmapPanel extends StatefulWidget {
  const HeatmapPanel({super.key});

  @override
  State<HeatmapPanel> createState() => _HeatmapPanelState();
}

// ==========================================
// MAPA DE CALOR - ESTADO Y CARGA DE DATOS
// ==========================================
// Mantiene filtros, límites, celdas y selecciones; refresca los datos cada minuto.
class _HeatmapPanelState extends State<HeatmapPanel> {
  final _requestService = RequestService();
  MunicipalityBoundaryModel? _boundary;
  GeoHeatmapModel? _heatmap;
  List<RequestTypeModel> _types = [];
  List<RequestStateModel> _states = [];
  String? _boundaryError;
  String? _requestError;
  DateTime? _from;
  DateTime? _to;
  int? _requestTypeId;
  int? _requestStateId;
  GeoHeatmapCellModel? _selectedCell;
  GeoHeatmapCellModel? _hoveredCell;
  Offset? _hoverOffset;
  bool _loading = false;
  bool _showHeatmap = true;
  bool _showBoundary = true;
  bool _showAggregateMarkers = false;
  _MapBaseStyle _baseStyle = _MapBaseStyle.standard;
  Timer? _refreshTimer;

  @override
  void initState() {
    // Carga el límite, las opciones de filtro y el heatmap al abrir el panel.
    super.initState();
    _loadBoundary();
    _loadFilterOptions();
    _refresh();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted && !_loading) _refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBoundary() async {
    // Obtiene el GeoJSON municipal a través del servicio de solicitudes.
    try {
      final boundary = MunicipalityBoundaryModel.fromGeoJson(
        await _requestService.getMunicipalityBoundary(),
      );
      if (mounted) setState(() => _boundary = boundary);
    } catch (error) {
      if (mounted) setState(() => _boundaryError = _readableError(error));
    }
  }

  Future<void> _loadFilterOptions() async {
    // Los tipos y estados se leen del backend; no se enumeran manualmente.
    try {
      final types = await RequestTypeService().getAll();
      final states = await _requestService.getRequestStates();
      if (!mounted) return;
      setState(() {
        _types = types;
        _states = states;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _requestError = _readableError(error));
    }
  }

  Future<void> _refresh() async {
    // Envía conjuntamente las fechas, el tipo y el estado seleccionados.
    setState(() {
      _loading = true;
      _requestError = null;
      _selectedCell = null;
      _hoveredCell = null;
      _hoverOffset = null;
    });
    try {
      final result = await _requestService.getHeatmap(
        from: _from,
        to: _to,
        requestTypeId: _requestTypeId,
        requestStateId: _requestStateId,
      );
      if (!mounted) return;
      setState(() => _heatmap = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _requestError = _readableError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _MapCard(
    title: 'Concentración de PQRS',
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Capas',
          onPressed: () => _showMapLayers(
            context: context,
            initialBase: _baseStyle,
            onBaseChanged: (style) => setState(() => _baseStyle = style),
            overlays: const {
              'heatmap': 'Mapa de calor de PQRS',
              'boundary': 'Límite municipal oficial',
              'markers': 'Centros agregados con conteo',
              'urban': 'Casco urbano',
              'sectors': 'Barrios y sectores',
            },
            overlayValues: {
              'heatmap': _showHeatmap,
              'boundary': _showBoundary,
              'markers': _showAggregateMarkers,
              'urban': false,
              'sectors': false,
            },
            onOverlayChanged: (layer) {
              setState(() {
                switch (layer) {
                  case 'heatmap':
                    _showHeatmap = !_showHeatmap;
                  case 'boundary':
                    _showBoundary = !_showBoundary;
                  case 'markers':
                    _showAggregateMarkers = !_showAggregateMarkers;
                }
              });
            },
            unavailableOverlays: const {'urban', 'sectors'},
          ),
          icon: const Icon(Icons.layers_outlined, color: AppColors.primary),
        ),
        IconButton(
          tooltip: 'Actualizar mapa de calor',
          onPressed: _loading ? null : _refresh,
          icon: const Icon(Icons.refresh, color: AppColors.primary),
        ),
      ],
    ),
    map: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controles de filtro: cualquier cambio solicita nuevos agregados al backend.
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
          child: Wrap(
            spacing: 9,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _FilterDropdown<int?>(
                width: 180,
                value: _requestTypeId,
                label: 'Tipo de PQRS',
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Todos los tipos'),
                  ),
                  ..._types.map(
                    (type) => DropdownMenuItem<int?>(
                      value: type.idRequestType,
                      child: Text(
                        type.nameRequestType,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _requestTypeId = value);
                  _refresh();
                },
              ),
              _FilterDropdown<int?>(
                width: 180,
                value: _requestStateId,
                label: 'Estado',
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Todos los estados'),
                  ),
                  ..._states.map(
                    (state) => DropdownMenuItem<int?>(
                      value: state.idRequestState,
                      child: Text(
                        state.nameRequestState ?? 'Sin nombre',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _requestStateId = value);
                  _refresh();
                },
              ),
              OutlinedButton.icon(
                onPressed: () => _chooseDate(isFrom: true),
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(_from == null ? 'Desde' : _dateLabel(_from!)),
              ),
              OutlinedButton.icon(
                onPressed: () => _chooseDate(isFrom: false),
                icon: const Icon(Icons.event_outlined, size: 16),
                label: Text(_to == null ? 'Hasta' : _dateLabel(_to!)),
              ),
              if (_from != null || _to != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _from = null;
                      _to = null;
                    });
                    _refresh();
                  },
                  child: const Text('Todas las fechas'),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 270,
          child: _boundary == null
              ? _BoundaryUnavailable(message: _boundaryError)
              : _heatmap == null
              ? const Center(child: CircularProgressIndicator())
              : !_heatmap!.boundaryAvailable
              ? _BoundaryUnavailable(message: _heatmap!.message)
              : _buildHeatmap(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 9, 13, 10),
          child: Row(
            children: [
              const Text(
                'Baja',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1683E5),
                        Color(0xFFF0B949),
                        Color(0xFFF28C28),
                        Color(0xFFE45D73),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Alta',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const SizedBox(width: 12),
              Text(
                _heatmap == null
                    ? '—'
                    : '${_heatmap!.totalRequests} solicitudes · ${_heatmap!.period}',
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        if (_heatmap != null)
          // Resume el total y los tipos incluidos en los filtros activos.
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 10),
            child: Wrap(
              spacing: 7,
              runSpacing: 6,
              children: [
                _StatisticChip(
                  label: 'Total',
                  value: _heatmap!.totalRequests,
                  emphasized: true,
                ),
                for (final entry in _heatmap!.typeDistribution.entries)
                  _StatisticChip(label: entry.key, value: entry.value),
              ],
            ),
          ),
        if (_requestError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 12),
            child: Text(
              _requestError!,
              style: const TextStyle(color: AppColors.cancelled, fontSize: 12),
            ),
          ),
        if (_selectedCell != null)
          _SelectedCellSummary(
            cell: _selectedCell!,
            period: _heatmap?.period ?? 'Todas las fechas',
            requestTypeSelected: _requestTypeId != null,
            requestTypeName: _selectedRequestTypeName,
            onSeeRequests: () => _openZoneDetails(
              LatLng(_selectedCell!.latitude, _selectedCell!.longitude),
            ),
          ),
      ],
    ),
  );

  Widget _buildHeatmap() {
    // Interacciones y capas del mapa; el raster y su presentación se dibujan
    // aparte para conservar el diseño del heatmap.
    final heatmap = _heatmap!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: MouseRegion(
        onExit: (_) {
          if (_hoveredCell != null) {
            setState(() {
              _hoveredCell = null;
              _hoverOffset = null;
            });
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: _boundary!.bounds.center,
                  initialCameraFit: CameraFit.bounds(
                    bounds: _boundary!.bounds,
                    padding: const EdgeInsets.all(24),
                  ),
                  minZoom: 8,
                  maxZoom: 18,
                  // El toque abre el detalle; el movimiento del mouse identifica la celda.
                  onTap: (_, point) => _openZoneDetails(point),
                  onPointerHover: (event, point) {
                    final cell = _cellAt(point);
                    if (cell == _hoveredCell) return;
                    setState(() {
                      _hoveredCell = cell;
                      _hoverOffset = cell == null ? null : event.localPosition;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: _baseStyle.urlTemplate,
                    userAgentPackageName: 'co.gov.villanueva.pqrsmart',
                  ),
                  // El raster usa las celdas agregadas que llegaron de PostgreSQL.
                  if (_showHeatmap && heatmap.cells.isNotEmpty)
                    GeoHeatmapRasterLayer(
                      cells: heatmap.cells,
                      boundary: _boundary!,
                    ),
                  if (_showBoundary)
                    PolygonLayer(
                      polygons: _boundary!.polygons
                          .map(
                            (polygon) => Polygon(
                              points: polygon.outer,
                              holePointsList: polygon.holes,
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderColor: AppColors.primary,
                              borderStrokeWidth: 2,
                            ),
                          )
                          .toList(),
                    ),
                  if (_showAggregateMarkers && heatmap.cells.isNotEmpty)
                    MarkerLayer(
                      markers: heatmap.cells.map((cell) {
                        return Marker(
                          point: LatLng(cell.latitude, cell.longitude),
                          width: 48,
                          height: 48,
                          child: GestureDetector(
                            onTap: () => _openZoneDetails(
                              LatLng(cell.latitude, cell.longitude),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(
                                    alpha: 0.92,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  '${cell.count}',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(_baseStyle.attribution),
                      if (_showBoundary)
                        const TextSourceAttribution('Límite municipal oficial'),
                    ],
                  ),
                  if (heatmap.cells.isEmpty && _showHeatmap)
                    const Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: _MapMessage(
                        message:
                            'No hay solicitudes georreferenciadas para los filtros seleccionados.',
                      ),
                    ),
                ],
              ),
              if (_hoveredCell != null && _hoverOffset != null)
                Positioned(
                  left: _hoverOffset!.dx
                      .clamp(
                        0.0,
                        (constraints.maxWidth - 235).clamp(
                          0.0,
                          double.infinity,
                        ),
                      )
                      .toDouble(),
                  top: _hoverOffset!.dy
                      .clamp(
                        0.0,
                        (constraints.maxHeight - 130).clamp(
                          0.0,
                          double.infinity,
                        ),
                      )
                      .toDouble(),
                  child: IgnorePointer(
                    child: _HeatmapHoverSummary(
                      cell: _hoveredCell!,
                      requestTypeSelected: _requestTypeId != null,
                      requestTypeName: _selectedRequestTypeName,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  GeoHeatmapCellModel? _cellAt(LatLng point) {
    // Calcula los índices de cuadrícula igual que el backend y busca esa celda.
    final size = _heatmap?.gridCellSizeDegrees;
    if (size == null || size <= 0) return null;
    final latitudeIndex = heatmapGridIndex(point.latitude, size);
    final longitudeIndex = heatmapGridIndex(point.longitude, size);
    for (final cell in _heatmap!.cells) {
      if (cell.latitudeIndex == latitudeIndex &&
          cell.longitudeIndex == longitudeIndex) {
        return cell;
      }
    }
    return null;
  }

  String? get _selectedRequestTypeName {
    for (final type in _types) {
      if (type.idRequestType == _requestTypeId) return type.nameRequestType;
    }
    return null;
  }

  Future<void> _openZoneDetails(LatLng point) async {
    // Consulta la misma celda con los mismos filtros y muestra resultados en un bottom sheet.
    if (_loading) return;
    final size = _heatmap?.gridCellSizeDegrees;
    if (size == null || size <= 0) return;
    final latitudeIndex = heatmapGridIndex(point.latitude, size);
    final longitudeIndex = heatmapGridIndex(point.longitude, size);
    final details = _requestService.getHeatmapZoneDetails(
      latitudeIndex: latitudeIndex,
      longitudeIndex: longitudeIndex,
      from: _from,
      to: _to,
      requestTypeId: _requestTypeId,
      requestStateId: _requestStateId,
    );
    if (!mounted) return;
    setState(() => _selectedCell = _cellAt(point));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.82,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<HeatmapZoneDetailsModel>(
              future: details,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No se pudo consultar esta zona: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.cancelled),
                      ),
                    ),
                  );
                }
                final zone = snapshot.data!;
                if (zone.totalRequests == 0) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No hay solicitudes en esta zona con los filtros seleccionados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  );
                }
                return _HeatmapZoneDetailsSheet(
                  zone: zone,
                  requestTypeSelected: _requestTypeId != null,
                  requestTypeName: _selectedRequestTypeName,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseDate({required bool isFrom}) async {
    // Evita rangos invertidos y recarga el mapa al confirmar una fecha.
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (!mounted || picked == null) return;
    final date = DateTime(picked.year, picked.month, picked.day);
    final invalid = isFrom
        ? _to != null && date.isAfter(_to!)
        : _from != null && date.isBefore(_from!);
    if (invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El rango de fechas seleccionado no es válido.'),
        ),
      );
      return;
    }
    setState(() {
      if (isFrom) {
        _from = date;
      } else {
        _to = date;
      }
    });
    _refresh();
  }
}

class _MapCard extends StatelessWidget {
  final String title;
  final Widget trailing;
  final Widget map;

  const _MapCard({
    required this.title,
    required this.trailing,
    required this.map,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    elevation: 0,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 6, 8, 6),
          child: Row(
            children: [
              const Icon(
                Icons.map_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
        map,
      ],
    ),
  );
}

class _FilterDropdown<T> extends StatelessWidget {
  final double width;
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.width,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
      ),
      items: items,
      onChanged: onChanged,
    ),
  );
}

class _SelectedCellSummary extends StatelessWidget {
  final GeoHeatmapCellModel cell;
  final String period;
  final bool requestTypeSelected;
  final String? requestTypeName;
  final VoidCallback onSeeRequests;

  const _SelectedCellSummary({
    required this.cell,
    required this.period,
    required this.requestTypeSelected,
    required this.requestTypeName,
    required this.onSeeRequests,
  });

  @override
  Widget build(BuildContext context) {
    // Resumen persistente de la celda seleccionada y acceso a sus solicitudes.
    final distribution = cell.statusDistribution.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' · ');
    final visibleDistribution = requestTypeSelected
        ? cell.dependenceDistribution
        : cell.typeDistribution;
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${requestTypeSelected ? requestTypeName ?? 'Tipo seleccionado' : 'Total de PQRS'} · ${cell.count}',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            _DistributionLines(
              title: requestTypeSelected ? 'Por dependencia' : 'Por tipo',
              values: visibleDistribution,
            ),
            if (requestTypeSelected)
              _DistributionLines(
                title: 'Por categoría',
                values: cell.categoryDistribution,
              ),
            if (distribution.isNotEmpty)
              Text(
                'Estados: $distribution',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            Text(
              'Periodo: $period',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onSeeRequests,
              child: const Text('Ver solicitudes de esta zona'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeatmapHoverSummary extends StatelessWidget {
  const _HeatmapHoverSummary({
    required this.cell,
    required this.requestTypeSelected,
    required this.requestTypeName,
  });

  final GeoHeatmapCellModel cell;
  final bool requestTypeSelected;
  final String? requestTypeName;

  @override
  Widget build(BuildContext context) {
    // Tooltip compacto para computador: tipos en general o dependencias por tipo.
    final distribution = requestTypeSelected
        ? cell.dependenceDistribution
        : cell.typeDistribution;
    final entries = distribution.entries.take(4).toList();
    return Container(
      width: 225,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${requestTypeSelected ? requestTypeName ?? 'Tipo seleccionado' : 'Total de PQRS'}: ${cell.count}',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          for (final entry in entries)
            Text(
              '${entry.key}: ${entry.value}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          if (entries.isEmpty)
            const Text(
              'Sin desglose disponible',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          if (requestTypeSelected && cell.categoryDistribution.isNotEmpty)
            Text(
              'Categorías: ${cell.categoryDistribution.entries.take(2).map((entry) => '${entry.key} (${entry.value})').join(', ')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
        ],
      ),
    );
  }
}

class _DistributionLines extends StatelessWidget {
  const _DistributionLines({required this.title, required this.values});

  final String title;
  final Map<String, int> values;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Text(
      '$title: ${values.isEmpty ? 'Sin datos' : values.entries.map((entry) => '${entry.key}: ${entry.value}').join(' · ')}',
      style: const TextStyle(color: AppColors.muted, fontSize: 12),
    ),
  );
}

class _HeatmapZoneDetailsSheet extends StatelessWidget {
  const _HeatmapZoneDetailsSheet({
    required this.zone,
    required this.requestTypeSelected,
    required this.requestTypeName,
  });

  final HeatmapZoneDetailsModel zone;
  final bool requestTypeSelected;
  final String? requestTypeName;

  @override
  Widget build(BuildContext context) {
    // Detalle adaptable de la zona y lista filtrada de solicitudes.
    final primaryDistribution = requestTypeSelected
        ? zone.dependenceDistribution
        : zone.typeDistribution;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${requestTypeSelected ? requestTypeName ?? 'Tipo seleccionado' : 'Solicitudes de esta zona'} · ${zone.totalRequests}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              _DistributionLines(
                title: requestTypeSelected ? 'Por dependencia' : 'Por tipo',
                values: primaryDistribution,
              ),
              _DistributionLines(
                title: 'Por categoría',
                values: zone.categoryDistribution,
              ),
              _DistributionLines(
                title: 'Por estado',
                values: zone.statusDistribution,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
            itemCount: zone.requests.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final request = zone.requests[index];
              return ListTile(
                onTap: () => _showHeatmapRequestDetails(context, request),
                title: Text(
                  request.radicado?.isNotEmpty == true
                      ? request.radicado!
                      : 'Solicitud #${request.idRequest ?? '—'}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${request.requestType} · ${request.category} / ${request.dependence}\n'
                  '${request.date} · ${request.state}',
                  style: const TextStyle(color: AppColors.muted, height: 1.4),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
              );
            },
          ),
        ),
      ],
    );
  }
}

void _showHeatmapRequestDetails(
  BuildContext context,
  HeatmapZoneRequestModel request,
) {
  // Muestra los datos de la solicitud seleccionada sin información personal.
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        request.radicado?.isNotEmpty == true
            ? request.radicado!
            : 'Solicitud #${request.idRequest ?? '—'}',
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ZoneDetailLine('Tipo', request.requestType),
            _ZoneDetailLine('Categoría', request.category),
            _ZoneDetailLine('Dependencia', request.dependence),
            _ZoneDetailLine('Fecha', request.date),
            _ZoneDetailLine('Estado', request.state),
            const SizedBox(height: 12),
            const Text(
              'Descripción',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              request.description,
              style: const TextStyle(color: AppColors.muted, height: 1.4),
            ),
            if (request.answer?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              const Text(
                'Respuesta',
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                request.answer!,
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}

class _ZoneDetailLine extends StatelessWidget {
  const _ZoneDetailLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      '$label: $value',
      style: const TextStyle(color: AppColors.text, fontSize: 13),
    ),
  );
}

class _StatisticChip extends StatelessWidget {
  const _StatisticChip({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final int value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: emphasized ? AppColors.surfaceBlue : AppColors.backgroundBlue,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(
      '$label: $value',
      style: TextStyle(
        color: AppColors.text,
        fontSize: 11,
        fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
  );
}

class _BoundaryUnavailable extends StatelessWidget {
  final String? message;

  const _BoundaryUnavailable({this.message});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.backgroundBlue,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(20),
    child: _MapMessage(
      message:
          message ??
          'El límite municipal oficial está pendiente. Agrega el GeoJSON WGS84 '
              'verificado en PQRSMART/src/main/resources/geo/'
              'villanueva-bolivar.geojson.',
    ),
  );
}

class _MapMessage extends StatelessWidget {
  final String message;

  const _MapMessage({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, size: 19, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.text, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

String _readableError(Object error) {
  final message = error.toString().replaceFirst('Exception: ', '');
  if (message.contains('SocketException') ||
      message.contains('ClientException')) {
    return 'No se pudo consultar el servicio geográfico. Verifica la conexión.';
  }
  return message;
}

String _dateLabel(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';
