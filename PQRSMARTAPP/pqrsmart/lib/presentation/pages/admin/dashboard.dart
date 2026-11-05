import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dashboard')),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Resumen del sistema',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Indicadores cargados desde los servicios disponibles.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            _Statistics(wide: wide),
            const SizedBox(height: 22),
            const Text(
              'Información geográfica',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (wide)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _MapPanel(title: 'Villanueva, Bolívar')),
                  SizedBox(width: 14),
                  Expanded(
                    child: _MapPanel(
                      title: 'Concentración de PQRS',
                      showHeatmapState: true,
                    ),
                  ),
                ],
              )
            else ...[
              const _MapPanel(title: 'Villanueva, Bolívar'),
              const SizedBox(height: 14),
              const _MapPanel(
                title: 'Concentración de PQRS',
                showHeatmapState: true,
              ),
            ],
          ],
        );
      },
    ),
  );
}

class _Statistics extends StatelessWidget {
  const _Statistics({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final columns = wide ? 5 : 2;
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, requestState) {
        final requests = requestState is RequestLoaded
            ? requestState.request
            : null;
        final total = requests?.length.toString() ?? '—';
        final pending = requests
            ?.where(
              (request) => (request.requestState?.nameRequestState ?? '')
                  .toUpperCase()
                  .contains('PEND'),
            )
            .length
            .toString();
        final inProgress = requests
            ?.where(
              (request) => (request.requestState?.nameRequestState ?? '')
                  .toUpperCase()
                  .contains('PROCESO'),
            )
            .length
            .toString();
        final attended = requests
            ?.where((request) {
              final status = (request.requestState?.nameRequestState ?? '')
                  .toUpperCase();
              return status.contains('ATEND') ||
                  status.contains('FINAL') ||
                  status.contains('RESUEL');
            })
            .length
            .toString();

        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final users = userState is UserLoaded
                ? userState.user.length.toString()
                : '—';
            final stats = [
              _StatData('Solicitudes', total, Icons.description_outlined),
              _StatData('Pendientes', pending ?? '—', Icons.pending_actions),
              _StatData('En proceso', inProgress ?? '—', Icons.autorenew),
              _StatData('Atendidas', attended ?? '—', Icons.task_alt),
              _StatData('Usuarios', users, Icons.people_outline),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 100,
              ),
              itemBuilder: (context, index) => _StatCard(data: stats[index]),
            );
          },
        );
      },
    );
  }
}

class _StatData {
  const _StatData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: AppColors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MapPanel extends StatefulWidget {
  const _MapPanel({required this.title, this.showHeatmapState = false});

  final String title;
  final bool showHeatmapState;

  @override
  State<_MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends State<_MapPanel> {
  static const _villanueva = LatLng(10.4444032, -75.2730468);
  final _mapController = MapController();
  bool _mapReady = false;

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
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
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
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 270,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _villanueva,
                  initialZoom: 11,
                  minZoom: 8,
                  maxZoom: 18,
                  onMapReady: () => setState(() => _mapReady = true),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'co.gov.villanueva.pqrsmart',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'Map data \u00A9 OpenStreetMap contributors',
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(9),
                  elevation: 2,
                  child: Column(
                    children: [
                      IconButton(
                        tooltip: 'Acercar',
                        visualDensity: VisualDensity.compact,
                        onPressed: _mapReady ? () => _zoom(1) : null,
                        icon: const Icon(Icons.add, color: AppColors.primary),
                      ),
                      const Divider(height: 1),
                      IconButton(
                        tooltip: 'Alejar',
                        visualDensity: VisualDensity.compact,
                        onPressed: _mapReady ? () => _zoom(-1) : null,
                        icon: const Icon(
                          Icons.remove,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.showHeatmapState)
                Positioned(
                  left: 12,
                  right: 56,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sin información geográfica suficiente para generar el mapa de calor.',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.showHeatmapState)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 12),
            child: Row(
              children: [
                const Text(
                  'Intensidad',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surfaceBlue,
                          AppColors.lightBlue,
                          AppColors.inProgress,
                          AppColors.cancelled,
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                const Text(
                  'Baja · Alta',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  void _zoom(double delta) {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + delta);
  }
}
