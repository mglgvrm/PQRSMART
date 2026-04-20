import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class User extends StatefulWidget {
  const User({Key? key}) : super(key: key);

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  String _filtroSeleccionado = 'Todos';
  final List<String> _filtros = ['Todos', 'Administradores', 'Funcionarios', 'Usuarios', 'Inactivos'];

  String safeStr(dynamic value, [String fallback = 'No disponible']) {
    if (value == null) return fallback;
    return value.toString();
  }

  // Mapea el rol del backend al texto visible
  String _rolLegible(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':   return 'Administrador';
      case 'SECRE':   return 'Funcionarios';
      case 'USER':    return 'Usuario';
      default:        return role;
    }
  }

  // Filtra la lista según el chip seleccionado
  List<dynamic> _aplicarFiltro(List<dynamic> users) {
    switch (_filtroSeleccionado) {
      case 'Administradores':
        return users.where((u) => safeStr(u.role).toUpperCase() == 'ADMIN').toList();
      case 'Funcionarios':
        return users.where((u) =>  safeStr(u.role).toUpperCase() == 'SECRE').toList();
      case 'Usuarios':
        return users.where((u) => safeStr(u.role).toUpperCase() == 'USER').toList();
        case 'Inactivos':
        return users.where((u) => safeStr(u.stateUser?.state).toUpperCase() != 'ACTIVO').toList();
      default:
        return users;
    }
  }

  // Estadísticas del resumen
  Map<String, int> _estadisticas(List<dynamic> users) {
    return {
      'total':          users.length,
      'administradores': users.where((u) => safeStr(u.role).toUpperCase() == 'ADMIN').length,
      'usuarios':   users.where((u) => safeStr(u.role).toUpperCase() == 'USER').length,
      'funcionarios':    users.where((u) => safeStr(u.role).toUpperCase() == 'SECRE').length,
    };
  }

  void _showDetailsUser(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFF4A6B5A).withOpacity(0.15),
                child: Text(
                  safeStr(user.name).isNotEmpty ? safeStr(user.name)[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 28, color: Color(0xFF4A6B5A)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Información del Usuario',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            _infoFila(Icons.person,         'Nombre',        '${safeStr(user.name)} ${safeStr(user.lastName)}'),
            _infoFila(Icons.email,          'Email',          safeStr(user.email)),
            _infoFila(Icons.account_circle, 'Usuario',        safeStr(user.user)),
            _infoFila(Icons.phone,          'Número',         safeStr(user.number)),
            _infoFila(Icons.badge,          'Identificación', safeStr(user.identificationNumber)),
            _infoFila(Icons.security,       'Rol',            _rolLegible(safeStr(user.role))),
            _infoFila(Icons.toggle_on,      'Estado',         safeStr(user.stateUser?.state)),
            _infoFila(Icons.business,       'Dependencia',    safeStr(user.dependence?.nameDependence)),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMenuOption(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.remove_red_eye_outlined, color: Color(0xFF4A6B5A)),
              title: Text('Ver perfil'),
              onTap: () {
                Navigator.pop(context);
                _showDetailsUser(context, user);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Color(0xFF4A6B5A)),
              title: Text('Editar usuario'),
              onTap: () {
                Navigator.pop(context);
                // TODO: navegar a editar usuario
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: Color(0xFF4A6B5A)),
              title: Text('Cambiar rol'),
              onTap: () {
                Navigator.pop(context);
                // TODO: cambiar rol
              },
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new, color: Colors.orange),
              title: Text('Desactivar usuario',
                  style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                /* context.read<UserBloc>().add(DesactivarUsuarioEvent(user.id)); */
              },
            ),

          ],
        ),
      ),
    );
  }

  void _showViewFormAddUser(BuildContext context) {
    final _nombreController        = TextEditingController();
    final _apellidoController      = TextEditingController();
    final _emailController         = TextEditingController();
    final _usuarioController       = TextEditingController();
    final _numeroController        = TextEditingController();
    final _identificacionController = TextEditingController();
    String _rolSeleccionado = 'USER';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Nuevo Usuario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              SizedBox(height: 8),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _apellidoController,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.account_circle),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _numeroController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Número',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _identificacionController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de Identificación',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setModalState) => DropdownButtonFormField<String>(
                  value: _rolSeleccionado,
                  decoration: InputDecoration(
                    labelText: 'Rol',
                    prefixIcon: Icon(Icons.security),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: ['USER', 'ADMIN', 'SECRE'].map((rol) {
                    return DropdownMenuItem(value: rol, child: Text(rol));
                  }).toList(),
                  onChanged: (value) {
                    setModalState(() => _rolSeleccionado = value!);
                  },
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Guardar Usuario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A6B5A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // TODO: context.read<UserBloc>().add(CrearUsuarioEvent(...));
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoFila(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 20, color: Color(0xFF4A6B5A)),
          SizedBox(width: 10),
          Text('$etiqueta: ', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(valor, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        centerTitle: true,
        backgroundColor: Color(0xFF4A6B5A),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'cerrar_sesion') _signOut(context);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showViewFormAddUser(context),
        backgroundColor: Color(0xFF4A6B5A),
        foregroundColor: Colors.white,
        icon: Icon(Icons.person_add),
        label: Text('Nuevo Usuario'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is UserLoaded) {
            final stats    = _estadisticas(state.user);
            final filtered = _aplicarFiltro(state.user);

            return Column(
              children: [

                // ── Chips de filtro ──────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filtros.map((filtro) {
                        final seleccionado = _filtroSeleccionado == filtro;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filtro),
                            selected: seleccionado,
                            selectedColor: Color(0xFF4A6B5A),
                            labelStyle: TextStyle(
                              color: seleccionado ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            onSelected: (_) {
                              setState(() => _filtroSeleccionado = filtro);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Resumen de estadísticas ──────────────────────────
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                  child: Text(
                    '${stats['total']} usuarios encontrados  •  '
                        'Administradores: ${stats['administradores']}  •  '
                        'Funcionarios: ${stats['funcionarios']} • '
                        'Usuarios: ${stats['usuarios']} • ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),

                Divider(height: 1),

                // ── Lista de usuarios ────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 12),
                        Text('No se encontraron usuarios',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      final activo = safeStr(user.stateUser?.state).toUpperCase() == 'ACTIVO';

                      return Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [

                            // Avatar con punto de estado
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Color(0xFF4A6B5A).withOpacity(0.15),
                                  child: Text(
                                    safeStr(user.name).isNotEmpty
                                        ? safeStr(user.name)[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF4A6B5A),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: activo ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 12),

                            // Info principal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${safeStr(user.name)} ${safeStr(user.lastName)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    safeStr(user.email),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.shield_outlined,
                                          size: 13, color: Color(0xFF4A6B5A)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Rol: ${_rolLegible(safeStr(user.role))}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4A6B5A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Badge estado + menú
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Badge activo/inactivo
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: activo
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6, height: 6,
                                        decoration: BoxDecoration(
                                          color: activo ? Colors.green : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        activo ? 'Activo' : 'Inactivo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: activo ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6),
                                // Botón menú (···)
                                GestureDetector(
                                  onTap: () => _showMenuOption(context, user),
                                  child: Icon(Icons.more_horiz,
                                      color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is UserError) {
            return Center(child: Text(state.message));
          }

          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}