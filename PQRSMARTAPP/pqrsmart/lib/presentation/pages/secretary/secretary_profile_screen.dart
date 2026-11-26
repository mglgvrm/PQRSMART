import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/pages/password_recovery_page.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/states/auth_state.dart';
import 'package:pqrsmart/presentation/widgets/profile_menu_item.dart';

class SecretaryProfileScreen extends StatefulWidget {
  const SecretaryProfileScreen({super.key, required this.onOpenDependence});

  final VoidCallback onOpenDependence;

  @override
  State<SecretaryProfileScreen> createState() => _SecretaryProfileScreenState();
}

class _SecretaryProfileScreenState extends State<SecretaryProfileScreen> {
  bool _signingOut = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundBlue,
    body: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final user = state is MyUserLoaded ? state.user : null;
        final fullName = user == null
            ? 'Cargando perfil'
            : '${user.name} ${user.lastName}'.trim();
        final initial = fullName.isEmpty || user == null
            ? '?'
            : fullName[0].toUpperCase();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 28,
                  20,
                  25,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.dark,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 39,
                      backgroundColor: AppColors.surfaceBlue,
                      child: user == null
                          ? const Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                              size: 34,
                            )
                          : Text(
                              initial,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 27,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fullName.isEmpty ? 'Secretario' : fullName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Perfil de secretario',
                      style: TextStyle(
                        color: AppColors.surfaceBlue,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 19, 18, 24),
              sliver: SliverList.list(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mi perfil',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Consulta y administra las opciones de tu cuenta.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state is UserError)
                    _ProfileLoadError(
                      message: state.message,
                      onRetry: () =>
                          context.read<UserBloc>().add(GetMyUserEvent()),
                    )
                  else ...[
                    PqrProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Información personal',
                      subtitle: 'Consulta tus datos y dependencia asignada',
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                    const SizedBox(height: 10),
                    PqrProfileMenuItem(
                      icon: Icons.business_outlined,
                      title: 'Mi dependencia',
                      subtitle:
                          user?.dependence?.nameDependence ??
                          'Consulta las estadísticas de tu área',
                      onTap: widget.onOpenDependence,
                    ),
                    const SizedBox(height: 10),
                    PqrProfileMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Cambiar contraseña',
                      subtitle: 'Solicita instrucciones por correo',
                      onTap: () => _openPasswordRecovery(user?.email),
                    ),
                    const SizedBox(height: 10),
                    const PqrProfileMenuItem(
                      icon: Icons.notifications_none,
                      title: 'Notificaciones',
                      subtitle: 'Próximamente',
                    ),
                    const SizedBox(height: 10),
                    const PqrProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Ayuda',
                      subtitle: 'Próximamente',
                    ),
                    const SizedBox(height: 10),
                    PqrProfileMenuItem(
                      icon: Icons.logout,
                      title: _signingOut
                          ? 'Cerrando sesión...'
                          : 'Cerrar sesión',
                      subtitle: _signingOut ? null : 'Salir de tu cuenta',
                      destructive: true,
                      onTap: _signingOut ? null : _confirmSignOut,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  void _openPasswordRecovery(String? email) {
    final normalizedEmail = email?.trim() ?? '';
    if (normalizedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay un correo asociado a esta cuenta para recuperar la contraseña.',
          ),
        ),
      );
      return;
    }

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => PasswordRecoveryPage(initialEmail: normalizedEmail),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
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
              backgroundColor: AppColors.cancelled,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _signingOut = true);
    final authBloc = context.read<AuthBloc>();
    final logoutResult = authBloc.stream.firstWhere(
      (state) => state is AuthLoggedOut || state is AuthFailure,
    );
    authBloc.add(LogoutEvent());
    final result = await logoutResult;
    if (!mounted) return;

    if (result is AuthFailure) {
      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage),
          backgroundColor: AppColors.cancelled,
        ),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}

class _ProfileLoadError extends StatelessWidget {
  const _ProfileLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_outlined, color: AppColors.cancelled),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'No fue posible cargar el perfil: $message',
            style: const TextStyle(color: AppColors.text, fontSize: 12),
          ),
        ),
        IconButton(
          tooltip: 'Reintentar',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, color: AppColors.primary),
        ),
      ],
    ),
  );
}
