import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/data/services/AuthStorage.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';

class SecretaryHomeScreen extends StatefulWidget {
  const SecretaryHomeScreen({super.key});

  @override
  State<SecretaryHomeScreen> createState() => _SecretaryHomeScreenState();
}

class _SecretaryHomeScreenState extends State<SecretaryHomeScreen> {
  int _selectedIndex = 0;

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
    ],
    child: Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _SecretaryRequestsPage(),
          _SecretaryDependencePage(),
          _SecretaryProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Dependencia',
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

class _SecretaryRequestsPage extends StatelessWidget {
  const _SecretaryRequestsPage();

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
        final pending = requests.where(_isPending).length;
        final inProgress = requests.where(_isInProgress).length;
        final attended = requests.where(_isAttended).length;
        return Column(
          children: [
            SizedBox(
              height: 82,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                scrollDirection: Axis.horizontal,
                children: [
                  _SecretaryStat(label: 'Recibidas', value: requests.length),
                  const SizedBox(width: 9),
                  _SecretaryStat(label: 'Pendientes', value: pending),
                  const SizedBox(width: 9),
                  _SecretaryStat(label: 'En proceso', value: inProgress),
                  const SizedBox(width: 9),
                  _SecretaryStat(label: 'Atendidas', value: attended),
                ],
              ),
            ),
            Expanded(
              child: requests.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay solicitudes asignadas a tu dependencia.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 9),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _SecretaryRequestCard(
                          request: request,
                          onOpen: () => _showDetails(context, request),
                          onAnswer: _isOpen(request)
                              ? () => _answer(context, request)
                              : null,
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
      _isPending(request) || _isInProgress(request);

  static bool _isPending(RequestModel request) =>
      (request.requestState?.nameRequestState ?? '').toUpperCase().contains(
        'PEND',
      );

  static bool _isInProgress(RequestModel request) =>
      (request.requestState?.nameRequestState ?? '').toUpperCase().contains(
        'PROCESO',
      );

  static bool _isAttended(RequestModel request) {
    final status = (request.requestState?.nameRequestState ?? '').toUpperCase();
    return status.contains('ATEND') ||
        status.contains('FINAL') ||
        status.contains('RESUEL');
  }

  void _showDetails(BuildContext context, RequestModel request) {
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
                'Ciudadano: ${request.user?.name ?? ''} ${request.user?.lastName ?? ''}',
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
}

class _SecretaryRequestCard extends StatelessWidget {
  const _SecretaryRequestCard({
    required this.request,
    required this.onOpen,
    required this.onAnswer,
  });

  final RequestModel request;
  final VoidCallback onOpen;
  final VoidCallback? onAnswer;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 110,
    child: Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onOpen,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceBlue,
          child: Icon(Icons.assignment_outlined, color: AppColors.primary),
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
          '${request.category?.nameCategory ?? 'Sin categoría'} · '
          '${request.requestState?.nameRequestState ?? 'Sin estado'}',
          style: const TextStyle(color: AppColors.muted),
        ),
        trailing: onAnswer == null
            ? const Icon(Icons.chevron_right, color: AppColors.muted)
            : IconButton(
                tooltip: 'Responder y finalizar',
                onPressed: onAnswer,
                icon: const Icon(Icons.reply_outlined, color: AppColors.action),
              ),
      ),
    ),
  );
}

class _SecretaryDependencePage extends StatelessWidget {
  const _SecretaryDependencePage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mi dependencia')),
    body: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading || state is UserInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.action),
          );
        }
        if (state is UserError) {
          return Center(
            child: Text(
              'No fue posible consultar la dependencia: ${state.message}',
              textAlign: TextAlign.center,
            ),
          );
        }
        if (state is! MyUserLoaded) {
          return const Center(child: Text('Información no disponible.'));
        }
        final dependence = state.user.dependence?.nameDependence;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              color: AppColors.backgroundBlue,
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const Icon(
                  Icons.business_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
                title: const Text(
                  'Dependencia asignada',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    dependence?.isNotEmpty == true
                        ? dependence!
                        : 'No hay dependencia asociada a esta cuenta.',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _SecretaryProfilePage extends StatelessWidget {
  const _SecretaryProfilePage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Perfil'),
      actions: [
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: () async {
            await AuthStorage().clear();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            }
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is! MyUserLoaded) {
          if (state is UserError) {
            return Center(
              child: Text(
                'No fue posible cargar el perfil: ${state.message}',
                textAlign: TextAlign.center,
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.action),
          );
        }
        final user = state.user;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.account_circle_outlined,
              color: AppColors.primary,
              size: 76,
            ),
            const SizedBox(height: 12),
            Text(
              '${user.name} ${user.lastName}'.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _ProfileItem(label: 'Correo', value: user.email),
            _ProfileItem(label: 'Rol', value: 'Secretario'),
            _ProfileItem(
              label: 'Dependencia',
              value: user.dependence?.nameDependence ?? 'No disponible',
            ),
          ],
        );
      },
    ),
  );
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: AppColors.backgroundBlue,
    child: ListTile(
      title: Text(
        label,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      ),
      subtitle: Text(value, style: const TextStyle(color: AppColors.text)),
    ),
  );
}

class _SecretaryStat extends StatelessWidget {
  const _SecretaryStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: AppColors.surfaceBlue,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 7),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}
