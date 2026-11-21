import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/pages/user/request_detail_screen.dart';
import 'package:pqrsmart/presentation/widgets/pqr_widgets.dart';

class PqrRequestsScreen extends StatefulWidget {
  const PqrRequestsScreen({super.key, this.initialType});
  final String? initialType;

  @override
  State<PqrRequestsScreen> createState() => _PqrRequestsScreenState();
}

class _PqrRequestsScreenState extends State<PqrRequestsScreen> {
  static const _filters = ['Todas', 'En proceso', 'Atendidas', 'Canceladas'];
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Mis solicitudes'),
      actions: [
        IconButton(
          tooltip: 'Crear solicitud',
          onPressed: () =>
              Navigator.pushNamed(context, '/newRequest').then((created) {
                if (created == true && context.mounted) {
                  context.read<RequestBloc>().add(LoadRequestEvent());
                }
              }),
          icon: const Icon(Icons.add),
        ),
        IconButton(
          tooltip: 'Actualizar',
          onPressed: () => context.read<RequestBloc>().add(LoadRequestEvent()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.action),
          );
        }
        if (state is RequestError) {
          return _MessageState(
            icon: Icons.cloud_off_outlined,
            message: state.message,
            action: TextButton(
              onPressed: () =>
                  context.read<RequestBloc>().add(LoadRequestEvent()),
              child: const Text('Reintentar'),
            ),
          );
        }
        if (state is! RequestLoaded) {
          return const _MessageState(
            icon: Icons.inbox_outlined,
            message: 'Aún no tienes solicitudes registradas.',
          );
        }

        final requests = state.request.where((request) {
          final status = (request.requestState?.nameRequestState ?? '')
              .toUpperCase();
          final type = (request.requestType?.nameRequestType ?? '')
              .toUpperCase();
          final typeMatch =
              widget.initialType == null ||
              type == _typeKey(widget.initialType!);
          final statusMatch = switch (_filterIndex) {
            1 => status.contains('PROCESO') || status.contains('PENDIENTE'),
            2 => status.contains('ATEND') || status.contains('RESUEL'),
            3 => status.contains('CANCEL') || status.contains('RECHAZ'),
            _ => true,
          };
          return typeMatch && statusMatch;
        }).toList();

        return Column(
          children: [
            SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ChoiceChip(
                  label: Text(_filters[index]),
                  selected: _filterIndex == index,
                  onSelected: (_) => setState(() => _filterIndex = index),
                  selectedColor: AppColors.action,
                  backgroundColor: AppColors.surfaceBlue,
                  labelStyle: TextStyle(
                    color: _filterIndex == index
                        ? AppColors.white
                        : AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide.none,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Expanded(
              child: requests.isEmpty
                  ? const _MessageState(
                      icon: Icons.search_off,
                      message: 'No se encontraron solicitudes.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 11),
                      itemBuilder: (context, index) =>
                          _RequestCard(request: requests[index]),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

String _typeKey(String type) => switch (type.toLowerCase()) {
  'peticiones' || 'petición' || 'peticion' => 'PETICION',
  'quejas' || 'queja' => 'QUEJA',
  'reclamos' || 'reclamo' => 'RECLAMO',
  'sugerencias' || 'sugerencia' => 'SUGERENCIA',
  _ => type.toUpperCase(),
};

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});
  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    final type = request.requestType?.nameRequestType ?? 'Solicitud';
    final status = request.requestState?.nameRequestState ?? 'En proceso';
    return InkWell(
      onTap: () =>
          Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (_) => RequestDetailScreen(request: request),
            ),
          ).then((cancelled) {
            if (cancelled == true && context.mounted) {
              context.read<RequestBloc>().add(LoadRequestEvent());
            }
          }),
      borderRadius: BorderRadius.circular(12),
      child: PqrCard(
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.radicado?.isNotEmpty == true
                                  ? request.radicado!
                                  : '#PQR-${request.idRequest ?? '---'}',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          PqrStatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '$type · ${request.category?.nameCategory ?? request.dependence?.nameDependence ?? 'General'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.muted,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            request.date,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  final value = status.toUpperCase();
  if (value.contains('CANCEL') || value.contains('RECHAZ')) {
    return AppColors.cancelled;
  }
  if (value.contains('ATEND') || value.contains('RESUEL')) {
    return AppColors.attended;
  }
  return AppColors.inProgress;
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.action});
  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.muted, size: 42),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (action != null) action!,
        ],
      ),
    ),
  );
}
