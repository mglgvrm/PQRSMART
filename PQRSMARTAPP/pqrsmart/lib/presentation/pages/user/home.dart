import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const _verde = Color(0xFF4A6B5A);
  static const _bg    = Color(0xFFF0F2F5);

  String safeStr(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  String _rolLegible(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':  return 'Administrador';
      case 'SECRE':  return 'Funcionario';
      case 'USER':   return 'Usuario';
      default:       return role;
    }
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 8),
          Text('Cerrar Sesión'),
        ]),
        content: Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _verde,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('Inicio',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        // ── Icono de cuenta en lugar de 3 puntos ──────
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.white, size: 28),
            onSelected: (value) {
              if (value == 'cerrar_sesion') _signOut(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'perfil',
                child: Row(children: [
                  Icon(Icons.person, color: _verde),
                  SizedBox(width: 10),
                  Text('Perfil'),
                ]),
              ),
              PopupMenuItem(
                value: 'cerrar_sesion',
                child: Row(children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Cerrar Sesión',
                      style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return Center(
                child: CircularProgressIndicator(color: _verde));
          }

          if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 56, color: Colors.red[300]),
                  SizedBox(height: 12),
                  Text(state.message,
                      style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _verde,
                        foregroundColor: Colors.white),
                    onPressed: () =>
                        context.read<UserBloc>().add(GetMyUserEvent()),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is MyUserLoaded) {
            final user    = state.user;
            final nombre  = '${safeStr(user.name)} ${safeStr(user.lastName)}'.trim();
            final email   = safeStr(user.email, 'Sin email');
            final rol     = _rolLegible(safeStr(user.role, 'USER'));
            final activo  = safeStr(user.stateUser?.state).toUpperCase() == 'ACTIVO';
            final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _cardPerfil(
                        context: context,
                        nombre:  nombre,
                        email:   email,
                        rol:     rol,
                        activo:  activo,
                        inicial: inicial,
                      ),
                      SizedBox(height: 16),
                      _cardActividad(),
                    ],
                  ),
                ),

              ],
            );
          }

          return SizedBox.shrink();
        },
      ),
      // ── Sin bottomNavigationBar — lo maneja el padre ──
    );
  }

  // ── Card Perfil ────────────────────────────────────────
  Widget _cardPerfil({
    required BuildContext context,
    required String nombre,
    required String email,
    required String rol,
    required bool activo,
    required String inicial,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: _verde.withOpacity(0.15),
                    child: Text(
                      inicial,
                      style: TextStyle(
                          fontSize: 26,
                          color: _verde,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: _verde,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.check,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(height: 4),
                    Text('Rol: $rol',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (activo ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: activo ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                          fontSize: 12,
                          color: activo ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey[200]),
          SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.email_outlined, color: _verde, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(email,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),

          SizedBox(height: 14),

          InkWell(
            onTap: () {
              // TODO: navegar a editar perfil
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Editar perfil',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500)),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right,
                      color: Colors.black54, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Actividad ─────────────────────────────────────
  Widget _cardActividad() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actividad',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.description_outlined,
                  valor: '0',
                  etiqueta: 'PQRS creadas',
                  iconColor: Colors.grey.shade500,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _statItem(
                  icon: Icons.hourglass_empty_rounded,
                  valor: '0',
                  etiqueta: 'Pendientes',
                  iconColor: Colors.orange,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _statItem(
                  icon: Icons.check_circle_outline,
                  valor: '0',
                  etiqueta: 'Resueltas',
                  iconColor: _verde,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String valor,
    required String etiqueta,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 6),
              Text(valor,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          SizedBox(height: 6),
          Text(etiqueta,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

}