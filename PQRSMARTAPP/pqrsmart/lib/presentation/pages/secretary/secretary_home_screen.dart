import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/presentation/blocs/ChatBoxBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/pages/secretary/secretary_profile_screen.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_chat_screen.dart';
import 'package:pqrsmart/presentation/states/ChatBoxEvent.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/utils/request_status_filter.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/widgets/request_statistics_charts.dart';

class SecretaryHomeScreen extends StatefulWidget {
  const SecretaryHomeScreen({super.key});

  @override
  State<SecretaryHomeScreen> createState() => _SecretaryHomeScreenState();
}

class _SecretaryHomeScreenState extends State<SecretaryHomeScreen> {
  int _selectedIndex = 0;
  RequestStatusFilter _selectedRequestFilter = RequestStatusFilter.all;

  void _openRequests(RequestStatusFilter filter) {
    setState(() {
      _selectedRequestFilter = filter;
      _selectedIndex = 1;
    });
  }

  void _openDependence() {
    setState(() => _selectedIndex = 4);
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            RequestBloc(RequestRepository(RequestService()))
              ..add(LoadRequestsForDependenceEvent()),
      ),
      BlocProvider(
        create: (_) =>
            UserBloc(UserRepository(UserService()))..add(GetMyUserEvent()),
      ),
      BlocProvider(create: (_) => ChatBoxBloc()..add(LoadChatBoxUser())),
    ],
    child: Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _SecretaryStartPage(onRequestFilterSelected: _openRequests),
          _SecretaryRequestsPage(
            selectedFilter: _selectedRequestFilter,
            onFilterSelected: (filter) =>
                setState(() => _selectedRequestFilter = filter),
          ),
          const PqrChatScreen(),
          SecretaryProfileScreen(onOpenDependence: _openDependence),
          _SecretaryDependencePage(
            onBack: () => setState(() => _selectedIndex = 3),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex == 4 ? 3 : _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    ),
  );
}

class _SecretaryStartPage extends StatelessWidget {
  const _SecretaryStartPage({required this.onRequestFilterSelected});

  final ValueChanged<RequestStatusFilter> onRequestFilterSelected;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Inicio'),
      actions: [
        IconButton(
          tooltip: 'Actualizar resumen',
          onPressed: () {
            context.read<RequestBloc>().add(LoadRequestsForDependenceEvent());
            context.read<UserBloc>().add(GetMyUserEvent());
          },
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is UserError) {
          return _SecretaryDashboardMessage(
            message: 'No fue posible cargar el perfil: ${userState.message}',
            onRetry: () => context.read<UserBloc>().add(GetMyUserEvent()),
          );
        }
        if (userState is! MyUserLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.action),
          );
        }
        return BlocBuilder<RequestBloc, RequestState>(
          builder: (context, requestState) {
            if (requestState is RequestError) {
              return _SecretaryDashboardMessage(
                message:
                    'No fue posible cargar la actividad de la dependencia.',
                onRetry: () => context.read<RequestBloc>().add(
                  LoadRequestsForDependenceEvent(),
                ),
              );
            }
            if (requestState is! RequestLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.action),
              );
            }
            final user = userState.user;
            final requests = requestState.request;
            final resolved = countRequestsByStatus(
              requests,
              RequestStatusFilter.attended,
            );
            final rejected = countRequestsByStatus(
              requests,
              RequestStatusFilter.rejected,
            );
            final cancelled = countRequestsByStatus(
              requests,
              RequestStatusFilter.cancelled,
            );
            final needsAttention = math.max(
              0,
              requests.length - resolved - rejected - cancelled,
            );
            final resolutionRate = requests.isEmpty
                ? 0.0
                : resolved / requests.length;
            final recent = requests.toList()
              ..sort((left, right) {
                final leftDate = DateTime.tryParse(left.date);
                final rightDate = DateTime.tryParse(right.date);
                if (leftDate == null) return rightDate == null ? 0 : 1;
                if (rightDate == null) return -1;
                return rightDate.compareTo(leftDate);
              });
            final columns = MediaQuery.sizeOf(context).width >= 1000
                ? 4
                : MediaQuery.sizeOf(context).width >= 560
                ? 3
                : 2;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _SecretaryWelcomeCard(
                  name: '${user.name} ${user.lastName}'.trim(),
                  dependence:
                      user.dependence?.nameDependence ??
                      'Dependencia no asignada',
                ),
                const SizedBox(height: 20),
                const _SecretarySectionHeading(
                  title: 'Resumen de solicitudes',
                  subtitle: 'Indicadores de tu dependencia',
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth =
                        (constraints.maxWidth - 10 * (columns - 1)) / columns;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _dashboardStat(
                          width: cardWidth,
                          filter: RequestStatusFilter.all,
                          requests: requests,
                          icon: Icons.inbox_outlined,
                          onTap: onRequestFilterSelected,
                        ),
                        _dashboardStat(
                          width: cardWidth,
                          filter: RequestStatusFilter.pending,
                          requests: requests,
                          icon: Icons.schedule_outlined,
                          onTap: onRequestFilterSelected,
                        ),
                        _dashboardStat(
                          width: cardWidth,
                          filter: RequestStatusFilter.waiting,
                          requests: requests,
                          icon: Icons.hourglass_empty,
                          onTap: onRequestFilterSelected,
                        ),
                        _dashboardStat(
                          width: cardWidth,
                          filter: RequestStatusFilter.inProgress,
                          requests: requests,
                          icon: Icons.autorenew,
                          onTap: onRequestFilterSelected,
                        ),
                        _dashboardStat(
                          width: cardWidth,
                          filter: RequestStatusFilter.attended,
                          requests: requests,
                          icon: Icons.check_circle_outline,
                          onTap: onRequestFilterSelected,
                        ),
                        _dashboardStat(
                          width: cardWidth,
                          filter: RequestStatusFilter.rejected,
                          requests: requests,
                          icon: Icons.cancel_outlined,
                          onTap: onRequestFilterSelected,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  color: AppColors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SecretarySectionHeading(
                          title: 'Actividad de atención',
                          subtitle:
                              'Casos resueltos frente a la carga recibida',
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _SecretaryActivityMetric(
                              label: 'Atendidas',
                              value: resolved,
                              color: AppColors.attended,
                            ),
                            _SecretaryActivityMetric(
                              label: 'Por gestionar',
                              value: needsAttention,
                              color: AppColors.claim,
                            ),
                            _SecretaryActivityMetric(
                              label: 'Total',
                              value: requests.length,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 11,
                            value: resolutionRate,
                            color: AppColors.attended,
                            backgroundColor: AppColors.backgroundBlue,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          requests.isEmpty
                              ? 'Todavía no hay solicitudes para calcular el porcentaje de resolución.'
                              : '${(resolutionRate * 100).toStringAsFixed(0)}% de las solicitudes recibidas están finalizadas.',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                RequestActivityChart(requests: requests),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: _SecretarySectionHeading(
                        title: 'Solicitudes recientes',
                        subtitle: 'Últimos registros de tu dependencia',
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          onRequestFilterSelected(RequestStatusFilter.all),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  const _SecretaryDashboardMessage(
                    message: 'No hay solicitudes asignadas para mostrar.',
                  )
                else
                  for (final request in recent.take(5))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _RecentSecretaryRequest(
                        request: request,
                        onTap: () =>
                            _showSecretaryRequestDetails(context, request),
                      ),
                    ),
              ],
            );
          },
        );
      },
    ),
  );

  Widget _dashboardStat({
    required double width,
    required RequestStatusFilter filter,
    required List<RequestModel> requests,
    required IconData icon,
    required ValueChanged<RequestStatusFilter> onTap,
  }) => SizedBox(
    width: width,
    height: 82,
    child: _SecretaryStat(
      label: filter.label,
      value: countRequestsByStatus(requests, filter),
      icon: icon,
      color: _filterColor(filter),
      selected: false,
      onTap: () => onTap(filter),
    ),
  );

  Color _filterColor(RequestStatusFilter filter) => switch (filter) {
    RequestStatusFilter.all => AppColors.primary,
    RequestStatusFilter.pending => AppColors.action,
    RequestStatusFilter.waiting => AppColors.claim,
    RequestStatusFilter.inProgress => AppColors.dark,
    RequestStatusFilter.attended => AppColors.attended,
    RequestStatusFilter.rejected => AppColors.complaint,
    RequestStatusFilter.cancelled => AppColors.muted,
  };
}

class _SecretaryWelcomeCard extends StatelessWidget {
  const _SecretaryWelcomeCard({required this.name, required this.dependence});

  final String name;
  final String dependence;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.16),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido, Secretario',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                name.isEmpty ? 'Usuario' : name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_outlined,
                    color: Colors.white70,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      dependence,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.dashboard_customize_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    ),
  );
}

class _SecretarySectionHeading extends StatelessWidget {
  const _SecretarySectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 11),
      ),
    ],
  );
}

class _SecretaryActivityMetric extends StatelessWidget {
  const _SecretaryActivityMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 10),
        ),
      ],
    ),
  );
}

class _RecentSecretaryRequest extends StatelessWidget {
  const _RecentSecretaryRequest({required this.request, required this.onTap});

  final RequestModel request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final requester = [
      request.user?.name ?? request.citizenName ?? 'Ciudadano',
      if (request.user?.lastName.isNotEmpty == true) request.user!.lastName,
    ].join(' ');
    final status = request.requestState?.nameRequestState ?? 'Sin estado';
    final color = requestStatusColor(status);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceBlue,
          child: Icon(Icons.description_outlined, color: AppColors.primary),
        ),
        title: Text(
          request.radicado?.isNotEmpty == true
              ? request.radicado!
              : '#PQR-${request.idRequest ?? '---'}',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$requester · ${request.requestType?.nameRequestType ?? 'PQRS'} · '
          '${request.category?.nameCategory ?? 'Sin categoría'} · ${request.date}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        trailing: Container(
          constraints: const BoxConstraints(maxWidth: 105),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecretaryDashboardMessage extends StatelessWidget {
  const _SecretaryDashboardMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}

void _showSecretaryRequestDetails(BuildContext context, RequestModel request) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.radicado?.isNotEmpty == true
                  ? request.radicado!
                  : '#PQR-${request.idRequest ?? '---'}',
              style: const TextStyle(
                color: AppColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 24),
            Text(
              'Ciudadano: ${request.user?.name ?? request.citizenName ?? ''} '
              '${request.user?.lastName ?? ''}',
            ),
            if (request.registeredBy != null)
              Text(
                'Registrada por: ${request.registeredBy!.name} '
                '${request.registeredBy!.lastName}',
              ),
            if (request.locationDescription?.isNotEmpty == true)
              Text('Lugar: ${request.locationDescription}'),
            if (request.latitude != null && request.longitude != null)
              Text(
                'Coordenadas: ${request.latitude!.toStringAsFixed(5)}, '
                '${request.longitude!.toStringAsFixed(5)}',
              ),
            Text(
              'Tipo: ${request.requestType?.nameRequestType ?? 'No disponible'}',
            ),
            Text(
              'Categoría: ${request.category?.nameCategory ?? 'No disponible'}',
            ),
            Text(
              'Estado: ${request.requestState?.nameRequestState ?? 'No disponible'}',
            ),
            Text('Fecha: ${request.date}'),
            const SizedBox(height: 12),
            const Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(request.description),
            if (request.answer?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              const Text(
                'Respuesta',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(request.answer!),
            ],
          ],
        ),
      ),
    ),
  );
}

class _SecretaryRequestsPage extends StatefulWidget {
  const _SecretaryRequestsPage({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final RequestStatusFilter selectedFilter;
  final ValueChanged<RequestStatusFilter> onFilterSelected;

  @override
  State<_SecretaryRequestsPage> createState() => _SecretaryRequestsPageState();
}

class _SecretaryRequestsPageState extends State<_SecretaryRequestsPage> {
  final RequestService _requestService = RequestService();
  late Future<List<RequestStateModel>> _statesFuture;
  final Set<int> _updatingRequestIds = {};

  @override
  void initState() {
    super.initState();
    _statesFuture = _requestService.getRequestStates();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Solicitudes asignadas'),
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          onPressed: () =>
              context.read<RequestBloc>().add(LoadRequestsForDependenceEvent()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        final saved = await Navigator.pushNamed(context, '/newAssistedRequest');
        if (saved == true && context.mounted) {
          context.read<RequestBloc>().add(LoadRequestsForDependenceEvent());
        }
      },
      icon: const Icon(Icons.person_add_alt_1_outlined),
      label: const Text('Registrar presencial'),
    ),
    body: BlocConsumer<RequestBloc, RequestState>(
      listener: (context, state) {
        if (state is RequestAnswered) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta registrada y solicitud finalizada.'),
            ),
          );
          context.read<RequestBloc>().add(LoadRequestsForDependenceEvent());
        } else if (state is RequestError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is RequestInitial || state is RequestLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.action),
          );
        }
        if (state is RequestError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No fue posible consultar las solicitudes asignadas.\n${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () => context.read<RequestBloc>().add(
                      LoadRequestsForDependenceEvent(),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is! RequestLoaded) {
          return const Center(child: Text('No hay solicitudes disponibles.'));
        }
        final requests = state.request;
        final filteredRequests = filterRequestsByStatus(
          requests,
          widget.selectedFilter,
        );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        color: AppColors.primary,
                        size: 23,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bandeja de solicitudes',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Casos asignados a tu dependencia',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 8),
                  const Text(
                    'Filtrar por estado',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusFilters(requests),
            Expanded(
              child: FutureBuilder<List<RequestStateModel>>(
                future: _statesFuture,
                builder: (context, statesSnapshot) {
                  if (statesSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.action),
                    );
                  }
                  if (statesSnapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No fue posible cargar los estados disponibles.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                          TextButton(
                            onPressed: () => setState(
                              () => _statesFuture = _requestService
                                  .getRequestStates(),
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }
                  final availableStates = statesSnapshot.data ?? [];
                  if (filteredRequests.isEmpty) {
                    final emptyMessage =
                        widget.selectedFilter == RequestStatusFilter.all
                        ? 'No hay solicitudes asignadas a tu dependencia.'
                        : 'No hay solicitudes en estado '
                              '${widget.selectedFilter.label.toLowerCase()}.';
                    return Center(
                      key: ValueKey(widget.selectedFilter),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          emptyMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    );
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    child: ListView.separated(
                      key: ValueKey(widget.selectedFilter),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                      itemCount: filteredRequests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index];
                        return _SecretaryRequestCard(
                          request: request,
                          states: availableStates,
                          isUpdating:
                              request.idRequest != null &&
                              _updatingRequestIds.contains(request.idRequest),
                          onOpen: () => _showDetails(context, request),
                          onAnswer: _isOpen(request)
                              ? () => _answer(context, request)
                              : null,
                          onStateChanged: (stateId) =>
                              _changeState(context, request, stateId),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );

  static bool _isOpen(RequestModel request) =>
      _isPending(request) || _isWaiting(request) || _isInProgress(request);

  static bool _isPending(RequestModel request) =>
      matchesRequestStatus(request, RequestStatusFilter.pending);

  static bool _isInProgress(RequestModel request) =>
      matchesRequestStatus(request, RequestStatusFilter.inProgress);

  static bool _isWaiting(RequestModel request) =>
      matchesRequestStatus(request, RequestStatusFilter.waiting);

  static bool _isAttended(RequestModel request) {
    return matchesRequestStatus(request, RequestStatusFilter.attended);
  }

  static bool _isRejected(RequestModel request) =>
      matchesRequestStatus(request, RequestStatusFilter.rejected);

  static bool _isCancelled(RequestModel request) =>
      matchesRequestStatus(request, RequestStatusFilter.cancelled);

  Widget _buildStatusFilters(List<RequestModel> requests) {
    final filters = RequestStatusFilter.values;
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget statCard(RequestStatusFilter filter, {double? width}) =>
            _SecretaryStat(
              key: ValueKey(filter),
              label: filter.label,
              value: countRequestsByStatus(requests, filter),
              icon: switch (filter) {
                RequestStatusFilter.all => Icons.inbox_outlined,
                RequestStatusFilter.pending => Icons.schedule_outlined,
                RequestStatusFilter.waiting => Icons.hourglass_empty,
                RequestStatusFilter.inProgress => Icons.autorenew,
                RequestStatusFilter.attended => Icons.check_circle_outline,
                RequestStatusFilter.rejected => Icons.cancel_outlined,
                RequestStatusFilter.cancelled => Icons.block_outlined,
              },
              color: _filterColor(filter),
              selected: widget.selectedFilter == filter,
              width: width,
              onTap: () => widget.onFilterSelected(filter),
            );

        if (constraints.maxWidth >= 1000) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (var index = 0; index < filters.length; index++) ...[
                  Expanded(child: statCard(filters[index])),
                  if (index < filters.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          );
        }

        return SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) =>
                statCard(filters[index], width: 145),
          ),
        );
      },
    );
  }

  Color _filterColor(RequestStatusFilter filter) => switch (filter) {
    RequestStatusFilter.all => AppColors.primary,
    RequestStatusFilter.pending => AppColors.action,
    RequestStatusFilter.waiting => AppColors.claim,
    RequestStatusFilter.inProgress => AppColors.dark,
    RequestStatusFilter.attended => AppColors.attended,
    RequestStatusFilter.rejected => AppColors.complaint,
    RequestStatusFilter.cancelled => AppColors.muted,
  };

  void _showDetails(BuildContext context, RequestModel request) {
    _showSecretaryRequestDetails(context, request);
  }

  Future<void> _answer(BuildContext context, RequestModel request) async {
    final id = request.idRequest;
    if (id == null) return;
    final controller = TextEditingController();
    final answer = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder y finalizar'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Respuesta al ciudadano',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(context, value);
            },
            child: const Text('Enviar respuesta'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (answer != null && context.mounted) {
      context.read<RequestBloc>().add(AnswerRequestEvent(id, answer));
    }
  }

  Future<void> _changeState(
    BuildContext context,
    RequestModel request,
    int stateId,
  ) async {
    final requestId = request.idRequest;
    if (requestId == null ||
        request.requestState?.idRequestState == stateId ||
        _updatingRequestIds.contains(requestId)) {
      return;
    }

    final observationController = TextEditingController();
    final observation = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Actualizar estado'),
        content: TextField(
          controller: observationController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Observación (opcional)',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, observationController.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    observationController.dispose();
    if (observation == null || !context.mounted) return;

    setState(() => _updatingRequestIds.add(requestId));
    try {
      await _requestService.updateRequestState(
        requestId,
        stateId: stateId,
        observation: observation.isEmpty ? null : observation,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado correctamente.')),
      );
      context.read<RequestBloc>().add(LoadRequestsForDependenceEvent());
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _updatingRequestIds.remove(requestId));
    }
  }
}

class _SecretaryRequestCard extends StatelessWidget {
  const _SecretaryRequestCard({
    required this.request,
    required this.states,
    required this.isUpdating,
    required this.onOpen,
    required this.onAnswer,
    required this.onStateChanged,
  });

  final RequestModel request;
  final List<RequestStateModel> states;
  final bool isUpdating;
  final VoidCallback onOpen;
  final VoidCallback? onAnswer;
  final ValueChanged<int> onStateChanged;

  @override
  Widget build(BuildContext context) {
    final currentStateId = request.requestState?.idRequestState;
    final selectedStateId =
        states.any((state) => state.idRequestState == currentStateId)
        ? currentStateId
        : null;
    final currentStateName =
        request.requestState?.nameRequestState ?? 'Sin estado';
    final stateColor = requestStatusColor(currentStateName);
    final citizen = [
      request.user?.name ?? request.citizenName ?? 'Ciudadano',
      if (request.user?.lastName.isNotEmpty == true) request.user!.lastName,
    ].join(' ');
    final requestType = request.requestType?.nameRequestType ?? 'PQRS';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.surfaceBlue,
                    child: Icon(
                      Icons.assignment_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.radicado?.isNotEmpty == true
                              ? request.radicado!
                              : '#PQR-${request.idRequest ?? '---'}',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          citizen,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.text),
                        ),
                        Text(
                          '$requestType · '
                          '${request.category?.nameCategory ?? 'Sin categoría'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Fecha: ${request.date}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        if (request.description.isNotEmpty)
                          Text(
                            request.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new,
                    color: AppColors.muted,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentStateName,
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (isUpdating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.action,
                    ),
                  )
                else if (states.isNotEmpty)
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width < 380 ? 120 : 170,
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: selectedStateId,
                      hint: const Text('Cambiar estado'),
                      items: states
                          .map(
                            (state) => DropdownMenuItem<int>(
                              value: state.idRequestState,
                              child: Text(
                                state.nameRequestState ?? 'Estado',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) onStateChanged(value);
                      },
                    ),
                  ),
                if (onAnswer != null)
                  IconButton(
                    tooltip: 'Responder y finalizar',
                    onPressed: onAnswer,
                    icon: const Icon(
                      Icons.reply_outlined,
                      color: AppColors.action,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SecretaryDependencePage extends StatelessWidget {
  const _SecretaryDependencePage({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: onBack == null
          ? null
          : IconButton(
              tooltip: 'Volver al perfil',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
      title: const Text('Mi dependencia'),
    ),
    body: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.action),
          );
        }
        if (state is UserError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No fue posible consultar la dependencia: ${state.message}',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () =>
                      context.read<UserBloc>().add(GetMyUserEvent()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (state is! MyUserLoaded) {
          return const Center(child: Text('Información no disponible.'));
        }
        final dependence = state.user.dependence;
        return BlocBuilder<RequestBloc, RequestState>(
          builder: (context, requestState) {
            final requests = requestState is RequestLoaded
                ? requestState.request
                : <RequestModel>[];
            final crossAxisCount = MediaQuery.sizeOf(context).width > 650
                ? 3
                : 2;
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Card(
                  elevation: 0,
                  color: AppColors.backgroundBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.surfaceBlue,
                          child: Icon(
                            Icons.business_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dependencia asignada',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dependence?.nameDependence?.isNotEmpty == true
                                    ? dependence!.nameDependence!
                                    : 'No hay dependencia asociada a esta cuenta.',
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (dependence?.idDependence != null)
                                Text(
                                  'Identificador institucional: ${dependence!.idDependence}',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (requestState is RequestLoading ||
                    requestState is RequestInitial)
                  const LinearProgressIndicator(color: AppColors.action),
                if (requestState is RequestError)
                  Card(
                    elevation: 0,
                    color: AppColors.surfaceBlue,
                    child: ListTile(
                      title: const Text(
                        'No se pudieron actualizar las estadísticas.',
                      ),
                      trailing: TextButton(
                        onPressed: () => context.read<RequestBloc>().add(
                          LoadRequestsForDependenceEvent(),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.65,
                  children: [
                    _SecretaryStat(
                      label: 'Recibidas',
                      value: requests.length,
                      icon: Icons.inbox_outlined,
                    ),
                    _SecretaryStat(
                      label: 'Pendientes',
                      value: requests
                          .where(_SecretaryRequestsPageState._isPending)
                          .length,
                      icon: Icons.schedule_outlined,
                      color: AppColors.action,
                    ),
                    _SecretaryStat(
                      label: 'En espera',
                      value: requests
                          .where(_SecretaryRequestsPageState._isWaiting)
                          .length,
                      icon: Icons.hourglass_empty,
                      color: AppColors.inProgress,
                    ),
                    _SecretaryStat(
                      label: 'En proceso',
                      value: requests
                          .where(_SecretaryRequestsPageState._isInProgress)
                          .length,
                      icon: Icons.autorenew,
                      color: AppColors.primary,
                    ),
                    _SecretaryStat(
                      label: 'Atendidas',
                      value: requests
                          .where(_SecretaryRequestsPageState._isAttended)
                          .length,
                      icon: Icons.check_circle_outline,
                      color: AppColors.attended,
                    ),
                    _SecretaryStat(
                      label: 'Rechazadas',
                      value: requests
                          .where(_SecretaryRequestsPageState._isRejected)
                          .length,
                      icon: Icons.cancel_outlined,
                      color: AppColors.complaint,
                    ),
                    _SecretaryStat(
                      label: 'Canceladas',
                      value: requests
                          .where(_SecretaryRequestsPageState._isCancelled)
                          .length,
                      icon: Icons.block_outlined,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    ),
  );
}

class _SecretaryStat extends StatelessWidget {
  const _SecretaryStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    this.width,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final double? width;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Semantics(
      button: onTap != null,
      selected: selected,
      label: '$label: $value',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceBlue : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 19),
                      const SizedBox(width: 7),
                      Text(
                        '$value',
                        style: TextStyle(
                          color: color,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? AppColors.text : AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
