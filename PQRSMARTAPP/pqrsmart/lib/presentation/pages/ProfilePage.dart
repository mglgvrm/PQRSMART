import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _withoutDependenceId = 7;

  String _safeValue(Object? value, [String fallback = 'No disponible']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _readableRole(String role) => switch (role.toUpperCase()) {
    'ADMIN' => 'Administrador',
    'SECRE' => 'Secretario',
    'USER' => 'Usuario',
    _ => role,
  };

  bool _hasDependence(dynamic user) {
    final id = user?.dependence?.idDependence;
    return id != null && id != _withoutDependenceId;
  }

  bool _isSecretary(dynamic user) =>
      _safeValue(user?.role).toUpperCase() == 'SECRE';

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.action,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<AuthBloc>().add(LogoutEvent());
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) => BlocProvider<UserBloc>(
    create: (_) =>
        UserBloc(UserRepository(UserService()))..add(GetMyUserEvent()),
    child: Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      appBar: AppBar(title: const Text('Mi perfil')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.action),
            );
          }
          if (state is UserError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 40,
                      color: AppColors.muted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No fue posible cargar tu perfil.\n${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<UserBloc>().add(GetMyUserEvent()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! MyUserLoaded) return const SizedBox.shrink();

          final user = state.user;
          final name =
              '${_safeValue(user.name, '')} ${_safeValue(user.lastName, '')}'
                  .trim();
          final initial = name.isEmpty ? '?' : name[0].toUpperCase();
          final status = _safeValue(user.stateUser?.state);
          final normalizedStatus = status.toUpperCase();
          final statusColor =
              normalizedStatus == 'ACTIVO' || normalizedStatus == 'ACTIVADO'
              ? AppColors.attended
              : normalizedStatus == 'No disponible'.toUpperCase()
              ? AppColors.muted
              : AppColors.inProgress;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  _ProfileIdentity(
                    initial: initial,
                    name: name.isEmpty ? 'Sin nombre' : name,
                    role: _readableRole(_safeValue(user.role, '')),
                  ),
                  const SizedBox(height: 22),
                  const _SectionHeading(
                    title: 'Información personal',
                    subtitle: 'Datos asociados a tu cuenta en PQRSMART.',
                  ),
                  const SizedBox(height: 12),
                  _ProfileInfoTile(
                    icon: Icons.account_circle_outlined,
                    label: 'Usuario',
                    value: _safeValue(user.user),
                  ),
                  const SizedBox(height: 9),
                  _ProfileInfoTile(
                    icon: Icons.fingerprint_outlined,
                    label: 'Identificación',
                    value: _safeValue(user.identificationNumber),
                  ),
                  const SizedBox(height: 9),
                  _ProfileInfoTile(
                    icon: Icons.toggle_on_outlined,
                    label: 'Estado de la cuenta',
                    value: status,
                    valueColor: statusColor,
                  ),
                  if (_isSecretary(user) && _hasDependence(user)) ...[
                    const SizedBox(height: 9),
                    _ProfileInfoTile(
                      icon: Icons.business_outlined,
                      label: 'Dependencia',
                      value: _safeValue(user.dependence?.nameDependence),
                    ),
                  ],
                  const SizedBox(height: 22),
                  const _SectionHeading(
                    title: 'Datos de contacto',
                    subtitle:
                        'Información registrada en el backend. La edición no está habilitada.',
                  ),
                  const SizedBox(height: 12),
                  _ProfileInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Correo electrónico',
                    value: _safeValue(user.email),
                  ),
                  const SizedBox(height: 9),
                  _ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: _safeValue(user.number),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cancelled,
                      side: const BorderSide(color: AppColors.cancelled),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.initial,
    required this.name,
    required this.role,
  });

  final String initial;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.dark,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 39,
          backgroundColor: AppColors.surfaceBlue,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          role,
          style: const TextStyle(color: AppColors.surfaceBlue, fontSize: 14),
        ),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    ],
  );
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.text,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.icon, size: 21),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
