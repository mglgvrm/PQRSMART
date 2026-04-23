import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/pages/ProfilePage.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  static const _verde = Color(0xFF4A6B5A);
  static const _bg    = Color(0xFFF0F2F5);

  String safeStr(dynamic v, [String fallback = '']) =>
      (v == null || v.toString().isEmpty) ? fallback : v.toString();
  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Cerrar Sesión'),
          ],
        ),
        content: Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
  void _showProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      create: (_) => UserBloc(UserRepository(UserService()))
        ..add(GetUserEvent()),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text('Home',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.account_circle, color: Colors.white),
              onSelected: (value) {
                if (value == 'perfil') {
                  _showProfile(context);
                } else if (value == 'cerrar_sesion') {
                  _signOut(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'perfil',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Color(0xFF4A6B5A)),
                      SizedBox(width: 10),
                      Text('Perfil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'cerrar_sesion',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                    ],
                  ),
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

            if (state is UserLoaded) {
              final usuarios = state.user;

              // ── Conteos ──────────────────────────────────
              final total       = usuarios.length;
              final activos     = usuarios.where((u) =>
              safeStr(u.stateUser?.state).toUpperCase() == 'ACTIVO').length;
              final inactivos   = usuarios.where((u) =>
              safeStr(u.stateUser?.state).toUpperCase() != 'ACTIVO').length;
              final admins      = usuarios.where((u) =>
              safeStr(u.role).toUpperCase() == 'ADMIN').length;
              final secretarios = usuarios.where((u) =>
              safeStr(u.role).toUpperCase() == 'SECRE').length;
              final regulares   = usuarios.where((u) =>
              safeStr(u.role).toUpperCase() == 'USER').length;

              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 8),

                    // ── Saludo ──────────────────────────────
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                        children: [
                          TextSpan(text: 'Bienvenido '),
                          TextSpan(text: '👋'),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Resumen general del sistema',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    SizedBox(height: 24),

                    // ── Sección usuarios ────────────────────
                    _seccion('Usuarios'),
                    SizedBox(height: 12),

                    // Total grande destacado
                    _cardTotal(total),
                    SizedBox(height: 12),

                    // Grid de conteos
                    Row(
                      children: [
                        Expanded(
                          child: _cardConteo(
                            icon: Icons.check_circle_outline,
                            label: 'Activos',
                            valor: activos,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _cardConteo(
                            icon: Icons.cancel_outlined,
                            label: 'Inactivos',
                            valor: inactivos,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _cardConteo(
                            icon: Icons.admin_panel_settings_outlined,
                            label: 'Admins',
                            valor: admins,
                            color: Color(0xFF4A6B5A),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _cardConteo(
                            icon: Icons.work_outline,
                            label: 'Secretarios',
                            valor: secretarios,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _cardConteo(
                            icon: Icons.person_outline,
                            label: 'Usuarios',
                            valor: regulares,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // ── Barra visual proporcional ───────────
                    _barraUsuarios(
                      activos:     activos,
                      inactivos:   inactivos,
                      total:       total,
                    ),

                    SizedBox(height: 24),
                  ],
                ),
              );
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
                          context.read<UserBloc>().add(GetUserEvent()),
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ── Total destacado ──────────────────────────────────────
  Widget _cardTotal(int total) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    decoration: BoxDecoration(
      color: _verde,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: _verde.withOpacity(0.35),
            blurRadius: 12,
            offset: Offset(0, 4)),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.group_outlined,
              color: Colors.white, size: 28),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$total',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('Total de usuarios',
                style: TextStyle(
                    fontSize: 14, color: Colors.white70)),
          ],
        ),
      ],
    ),
  );

  // ── Card conteo individual ───────────────────────────────
  Widget _cardConteo({
    required IconData icon,
    required String label,
    required int valor,
    required Color color,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 10),
            Text('$valor',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      );

  // ── Barra proporcional activos/inactivos ─────────────────
  Widget _barraUsuarios({
    required int activos,
    required int inactivos,
    required int total,
  }) {
    final pActivos   = total > 0 ? activos / total : 0.0;
    final pInactivos = total > 0 ? inactivos / total : 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distribución de usuarios',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (pActivos > 0)
                  Expanded(
                    flex: (pActivos * 100).round(),
                    child: Container(height: 12, color: Colors.green),
                  ),
                if (pInactivos > 0)
                  Expanded(
                    flex: (pInactivos * 100).round(),
                    child: Container(height: 12, color: Colors.red[300]),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _leyenda(color: Colors.green, label: 'Activos ($activos)'),
              SizedBox(width: 16),
              _leyenda(
                  color: Colors.red[300]!,
                  label: 'Inactivos ($inactivos)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leyenda({required Color color, required String label}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          width: 10, height: 10,
          decoration:
          BoxDecoration(color: color, shape: BoxShape.circle)),
      SizedBox(width: 6),
      Text(label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ],
  );

  // ── Título sección ───────────────────────────────────────
  Widget _seccion(String titulo) => Text(
    titulo.toUpperCase(),
    style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 1.0),
  );
}