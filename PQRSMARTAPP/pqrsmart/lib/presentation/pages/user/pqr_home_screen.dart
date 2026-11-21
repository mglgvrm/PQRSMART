import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';

class PqrHomeScreen extends StatelessWidget {
  const PqrHomeScreen({super.key, required this.onShowRequests});

  final ValueChanged<String?> onShowRequests;

  static const _categories = <(String, IconData, Color)>[
    ('Peticiones', Icons.description_outlined, AppColors.petition),
    ('Quejas', Icons.report_gmailerrorred_outlined, AppColors.complaint),
    ('Reclamos', Icons.campaign_outlined, AppColors.claim),
    ('Sugerencias', Icons.lightbulb_outline, AppColors.suggestion),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          children: [
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      var name = 'Usuario';
                      if (state is MyUserLoaded) {
                        name = state.user.name.isEmpty
                            ? 'Usuario'
                            : state.user.name;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, $name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '¿Qué deseas hacer hoy?',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Notificaciones',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No tienes notificaciones nuevas.'),
                    ),
                  ),
                  icon: const Icon(
                    Icons.notifications_none,
                    color: AppColors.text,
                  ),
                ),
                const CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.surfaceBlue,
                  child: Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              height: size.width < 360 ? 178 : 160,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    right: 3,
                    bottom: 1,
                    child: Icon(
                      Icons.account_balance_outlined,
                      size: 78,
                      color: AppColors.lightBlue,
                    ),
                  ),
                  SizedBox(
                    width: size.width * .61,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestiona tus PQRS de forma rápida y sencilla',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(
                                  context,
                                  '/newRequest',
                                ).then((created) {
                                  if (created == true) onShowRequests(null);
                                }),
                            icon: const Icon(Icons.add, size: 17),
                            label: const Text('Crear solicitud'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mis solicitudes',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => onShowRequests(null),
                  child: const Text(
                    'Ver todas  ›',
                    style: TextStyle(
                      color: AppColors.action,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.75,
              ),
              itemBuilder: (context, index) {
                final (label, icon, color) = _categories[index];
                return Material(
                  color: AppColors.surfaceBlue,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => onShowRequests(label),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 9),
                          Flexible(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
