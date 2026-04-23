import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _verde      = Color(0xFF4A6B5A);
  static const _bg         = Color(0xFFF2F4F3);
  static const _sinDependencia = 7; // idDependence que significa "sin dependencia"

  final _emailController    = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _editandoEmail    = false;
  bool _editandoTelefono = false;

  String safeStr(dynamic v, [String fallback = 'No disponible']) =>
      (v == null || v.toString().isEmpty) ? fallback : v.toString();

  String _rolLegible(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':  return 'Administrador';
      case 'SECRE':  return 'Secretario';
      case 'USER':   return 'Usuario';
      default:       return role;
    }
  }

  bool _tieneDependencia(dynamic user) {
    final id = user?.dependence?.idDependence;
    return id != null && id != _sinDependencia;
  }

  bool _esSecretario(dynamic user) =>
      safeStr(user?.role).toUpperCase() == 'SECRE';

  @override
  void dispose() {
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.power_settings_new, color: Colors.red),
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
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
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
    return BlocProvider<UserBloc>(
      create: (_) => UserBloc(UserRepository(UserService()))
        ..add(GetMyUserEvent()),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: Text('Perfil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return Center(
                  child: CircularProgressIndicator(color: _verde));
            }

            if (state is MyUserLoaded) {
              final user    = state.user;
              final nombre  = '${safeStr(user.name, '')} ${safeStr(user.lastName, '')}'.trim();
              final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
              final rol     = _rolLegible(safeStr(user.role, 'USER'));

              if (_emailController.text.isEmpty) {
                _emailController.text    = safeStr(user.email, '');
                _telefonoController.text = safeStr(user.number, '');
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [

                    // ── Avatar ────────────────────────────────
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: _verde.withOpacity(0.15),
                          child: Text(inicial,
                              style: TextStyle(
                                  fontSize: 38,
                                  color: _verde,
                                  fontWeight: FontWeight.bold)),
                        ),


                      ],
                    ),

                    SizedBox(height: 10),

                    Text(nombre.isNotEmpty ? nombre : 'Sin nombre',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(height: 4),
                    // Badge rol
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _verde.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(rol,
                          style: TextStyle(
                              fontSize: 13,
                              color: _verde,
                              fontWeight: FontWeight.w600)),
                    ),

                    SizedBox(height: 28),

                    // ── Datos no modificables ─────────────────
                    _seccion('Información personal'),
                    SizedBox(height: 10),

                    _campoInfo(
                      icon: Icons.badge_outlined,
                      label: 'Usuario',
                      valor: safeStr(user.user),
                    ),
                    SizedBox(height: 10),

                    _campoInfo(
                      icon: Icons.fingerprint,
                      label: 'Identificación',
                      valor: safeStr(user.identificationNumber),
                    ),
                    SizedBox(height: 10),

                    _campoInfo(
                      icon: Icons.toggle_on_outlined,
                      label: 'Estado',
                      valor: safeStr(user.stateUser?.state, 'Activo'),
                      valorColor: safeStr(user.stateUser?.state)
                          .toUpperCase() == 'ACTIVO'
                          ? Colors.green
                          : Colors.red,
                    ),

                    // Dependencia — solo si es secretario y tiene dependencia real
                    if (_esSecretario(user) && _tieneDependencia(user)) ...[
                      SizedBox(height: 10),
                      _campoInfo(
                        icon: Icons.business_outlined,
                        label: 'Dependencia',
                        valor: safeStr(user.dependence?.nameDependence),
                      ),
                    ],

                    SizedBox(height: 24),

                    // ── Datos modificables ────────────────────
                    _seccion('Datos de contacto'),
                    SizedBox(height: 10),

                    _campoEditable(
                      label: 'Correo electrónico',
                      controller: _emailController,
                      editando: _editandoEmail,
                      keyboardType: TextInputType.emailAddress,
                      onEditTap: () =>
                          setState(() => _editandoEmail = true),
                      onGuardar: () {
                        setState(() => _editandoEmail = false);
                        // TODO: bloc actualizar email
                      },
                      onCancelar: () => setState(() {
                        _editandoEmail        = false;
                        _emailController.text = safeStr(user.email, '');
                      }),
                    ),

                    SizedBox(height: 10),

                    _campoEditable(
                      label: 'Teléfono',
                      controller: _telefonoController,
                      editando: _editandoTelefono,
                      keyboardType: TextInputType.phone,
                      onEditTap: () =>
                          setState(() => _editandoTelefono = true),
                      onGuardar: () {
                        setState(() => _editandoTelefono = false);
                        // TODO: bloc actualizar teléfono
                      },
                      onCancelar: () => setState(() {
                        _editandoTelefono        = false;
                        _telefonoController.text = safeStr(user.number, '');
                      }),
                    ),

                    SizedBox(height: 36),

                    // ── Cerrar sesión ─────────────────────────
                    GestureDetector(
                      onTap: () => _signOut(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.power_settings_new,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Cerrar sesión',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
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
                          context.read<UserBloc>().add(GetMyUserEvent()),
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

  // ── Título de sección ──────────────────────────────────
  Widget _seccion(String titulo) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      titulo,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 0.8),
    ),
  );

  // ── Campo solo lectura ─────────────────────────────────
  Widget _campoInfo({
    required IconData icon,
    required String label,
    required String valor,
    Color? valorColor,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: _verde, size: 20),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 2),
                Text(valor,
                    style: TextStyle(
                        fontSize: 15,
                        color: valorColor ?? Colors.black87,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      );

  // ── Campo editable ─────────────────────────────────────
  Widget _campoEditable({
    required String label,
    required TextEditingController controller,
    required bool editando,
    required TextInputType keyboardType,
    required VoidCallback onEditTap,
    required VoidCallback onGuardar,
    required VoidCallback onCancelar,
  }) =>
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFEAF0EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: editando,
                      keyboardType: keyboardType,
                      style:
                      TextStyle(fontSize: 15, color: Colors.black87),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onEditTap,
                    child: Icon(Icons.edit_outlined,
                        color: _verde, size: 18),
                  ),
                ],
              ),
            ),
            if (editando) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verde,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: onGuardar,
                      child: Text('Guardar',
                          style:
                          TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black54,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: onCancelar,
                      child: Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}