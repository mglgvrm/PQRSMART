import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';
import 'package:pqrsmart/presentation/widgets/profile_menu_item.dart';

class PqrProfileScreen extends StatelessWidget {
  const PqrProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final name = state is MyUserLoaded
            ? '${state.user.name} ${state.user.lastName}'.trim()
            : 'Usuario';
        final initial = name.isEmpty ? 'U' : name[0].toUpperCase();
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
                      child: Text(
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
                      name.isEmpty ? 'Usuario' : name,
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
                      'Perfil ciudadano',
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
              padding: const EdgeInsets.fromLTRB(18, 19, 18, 20),
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
                  PqrProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Información personal',
                    subtitle: 'Consulta tus datos registrados',
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                  const SizedBox(height: 10),
                  PqrProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Cambiar contraseña',
                    subtitle: 'Solicita instrucciones por correo',
                    onTap: () =>
                        Navigator.pushNamed(context, '/passwordRecovered'),
                  ),
                  const SizedBox(height: 10),
                  PqrProfileMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Notificaciones',
                    subtitle: 'Próximamente',
                  ),
                  const SizedBox(height: 10),
                  PqrProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Ayuda',
                    subtitle: 'No disponible todavía',
                  ),
                  const SizedBox(height: 10),
                  PqrProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Cerrar sesión',
                    destructive: true,
                    onTap: () => _confirmSignOut(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.action,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
