import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/DependenceBloc.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/states/DependenceState.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/utils/request_status_filter.dart';
import 'package:pqrsmart/presentation/widgets/geo_dashboard_panels.dart';
import 'package:pqrsmart/presentation/widgets/request_statistics_charts.dart';

// ==========================================
// DASHBOARD ADMINISTRATIVO - MAPAS
// ==========================================
// Coloca el mapa territorial y el mapa de calor en una fila o columna adaptable.
class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    this.onRequestFilterSelected,
    this.onUsersSelected,
  });

  final ValueChanged<RequestStatusFilter>? onRequestFilterSelected;
  final VoidCallback? onUsersSelected;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _heatmapRefresh = 0;

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
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _registerAssistedRequest,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Registrar solicitud presencial'),
              ),
            ),
            const SizedBox(height: 12),
            _Statistics(
              wide: wide,
              onRequestFilterSelected: widget.onRequestFilterSelected,
              onUsersSelected: widget.onUsersSelected,
            ),
            const SizedBox(height: 22),
            const Text(
              'Análisis de solicitudes',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const _AdminChartsSection(),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: TerritoryMapPanel()),
                  SizedBox(width: 14),
                  Expanded(child: HeatmapPanel(key: ValueKey(_heatmapRefresh))),
                ],
              )
            else ...[
              const TerritoryMapPanel(),
              const SizedBox(height: 14),
              HeatmapPanel(key: ValueKey(_heatmapRefresh)),
            ],
          ],
        );
      },
    ),
  );

  Future<void> _registerAssistedRequest() async {
    final saved = await Navigator.pushNamed(context, '/newAssistedRequest');
    if (!mounted || saved != true) return;
    context.read<RequestBloc>().add(LoadAllRequestsEvent());
    setState(() => _heatmapRefresh++);
  }
}

class _AdminChartsSection extends StatelessWidget {
  const _AdminChartsSection();

  @override
  Widget build(BuildContext context) => BlocBuilder<RequestBloc, RequestState>(
    builder: (context, requestState) {
      if (requestState is RequestLoading || requestState is RequestInitial) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(color: AppColors.action),
          ),
        );
      }
      if (requestState is RequestError) {
        return const _StatisticsUnavailable(
          message:
              'No se pudieron cargar las solicitudes para crear las gráficas.',
        );
      }
      if (requestState is! RequestLoaded) {
        return const _StatisticsUnavailable(
          message: 'No hay solicitudes disponibles para analizar.',
        );
      }
      return BlocBuilder<DependenceBloc, DependenceState>(
        builder: (context, dependenceState) {
          final List<DependenceModel> dependences =
              dependenceState is DependenceLoaded
              ? dependenceState.dependence
              : const <DependenceModel>[];
          return AdminRequestStatistics(
            requests: requestState.request,
            dependences: dependences,
          );
        },
      );
    },
  );
}

class _StatisticsUnavailable extends StatelessWidget {
  const _StatisticsUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.backgroundBlue,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(message, style: const TextStyle(color: AppColors.muted)),
  );
}

class _Statistics extends StatelessWidget {
  const _Statistics({
    required this.wide,
    required this.onRequestFilterSelected,
    required this.onUsersSelected,
  });

  final bool wide;
  final ValueChanged<RequestStatusFilter>? onRequestFilterSelected;
  final VoidCallback? onUsersSelected;

  @override
  Widget build(BuildContext context) {
    final columns = wide ? 4 : 2;
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, requestState) {
        final requests = requestState is RequestLoaded
            ? requestState.request
            : null;
        String count(RequestStatusFilter filter) {
          if (requests == null) return '—';
          return countRequestsByStatus(requests, filter).toString();
        }

        VoidCallback? openRequests(RequestStatusFilter filter) {
          final callback = onRequestFilterSelected;
          if (requests == null || callback == null) return null;
          return () => callback(filter);
        }

        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final users = userState is UserLoaded
                ? userState.user.length.toString()
                : '—';
            final stats = [
              _StatData(
                'Solicitudes',
                count(RequestStatusFilter.all),
                Icons.description_outlined,
                onTap: openRequests(RequestStatusFilter.all),
              ),
              _StatData(
                'Pendientes',
                count(RequestStatusFilter.pending),
                Icons.pending_actions,
                color: AppColors.action,
                onTap: openRequests(RequestStatusFilter.pending),
              ),
              _StatData(
                'En espera',
                count(RequestStatusFilter.waiting),
                Icons.hourglass_empty,
                color: AppColors.claim,
                onTap: openRequests(RequestStatusFilter.waiting),
              ),
              _StatData(
                'En proceso',
                count(RequestStatusFilter.inProgress),
                Icons.autorenew,
                color: AppColors.primary,
                onTap: openRequests(RequestStatusFilter.inProgress),
              ),
              _StatData(
                'Atendidas',
                count(RequestStatusFilter.attended),
                Icons.task_alt,
                color: AppColors.attended,
                onTap: openRequests(RequestStatusFilter.attended),
              ),
              _StatData(
                'Rechazadas',
                count(RequestStatusFilter.rejected),
                Icons.cancel_outlined,
                color: AppColors.complaint,
                onTap: openRequests(RequestStatusFilter.rejected),
              ),
              _StatData(
                'Usuarios',
                users,
                Icons.people_outline,
                onTap: onUsersSelected,
              ),
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
  const _StatData(
    this.label,
    this.value,
    this.icon, {
    this.color = AppColors.primary,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) => Semantics(
    button: data.onTap != null,
    label: '${data.label}: ${data.value}',
    child: Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.value,
                      style: TextStyle(
                        color: data.color,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (data.onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
