import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/presentation/blocs/DependenceBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/pages/ProfilePage.dart';
import 'package:pqrsmart/presentation/states/DependenceEvent.dart';
import 'package:pqrsmart/presentation/states/DependenceState.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class DependencePage extends StatefulWidget {
  const DependencePage({Key? key}) : super(key: key);

  @override
  _DependencePageState createState() => _DependencePageState();
}

class _DependencePageState extends State<DependencePage> {
  String safeStr(dynamic value, [String fallback = 'No disponible']) {
    if (value == null) return fallback;
    return value.toString();
  }

  void _showDetailsDependence(BuildContext context, dynamic dependence) {
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
                  safeStr(dependence.nameDependence).isNotEmpty
                      ? safeStr(dependence.nameDependence)[0].toUpperCase()
                      : '?',
                  style: TextStyle(fontSize: 28, color: Color(0xFF4A6B5A)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Información de la Dependencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            _infoFila(Icons.business, 'Nombre', safeStr(dependence.nameDependence)),
            _infoFila(Icons.toggle_on, 'Estado', safeStr(dependence.state?.description)),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showMenuOption(BuildContext context, dynamic dependence) {
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
              title: Text('Ver detalle'),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDependence(context, dependence);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Color(0xFF4A6B5A)),
              title: Text('Editar dependencia'),
              onTap: () {
                Navigator.pop(context);
                // TODO: editar dependencia
              },
            ),
            ListTile(
              leading: Icon(Icons.check, color: Colors.green),
              title: Text('Activar',
                  style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.pop(context);
                // TODO: context.read<DependenceBloc>().add(DesactivarDependenceEvent(dependence.idDependence));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: Colors.red),
              title: Text('Desactivar',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: context.read<DependenceBloc>().add(DesactivarDependenceEvent(dependence.idDependence));
              },
            ),


          ],
        ),
      ),
    );
  }

  void _showFormAddDependence(BuildContext context) {
    final _nombreController = TextEditingController();

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
              Text('Nueva Dependencia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              SizedBox(height: 8),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Dependencia',
                  prefixIcon: Icon(Icons.business),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text('Guardar Dependencia'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A6B5A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_nombreController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('El nombre es requerido'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    // TODO: context.read<DependenceBloc>().add(CreateDependenceEvent(_nombreController.text.trim()));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dependencia guardada correctamente'),
                        backgroundColor: Color(0xFF4A6B5A),
                      ),
                    );
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
  void _showProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfilePage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dependencias'),
        centerTitle: true,
        backgroundColor: Color(0xFF4A6B5A),
        foregroundColor: Colors.white,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormAddDependence(context),
        backgroundColor: Color(0xFF4A6B5A),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add_business),
        label: Text('Nueva Dependencia'),
      ),
      body: BlocBuilder<DependenceBloc, DependenceState>(
        builder: (context, state) {

          if (state is DependenceLoading) {
            return Center(child: CircularProgressIndicator(
              color: Color(0xFF4A6B5A),
            ));
          }

          if (state is DependenceLoaded) {
            final dependence = state.dependence;

            return Column(
              children: [

                // ── Resumen ──────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${dependence.length} dependencia(s) registrada(s)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ),

                Divider(height: 1),

                // ── Lista ────────────────────────────────────────────
                Expanded(
                  child: dependence.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_outlined,
                            size: 64, color: Colors.grey[400]),
                        SizedBox(height: 12),
                        Text('No hay dependencias registradas',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: dependence.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final dep = dependence[index];
                      final activo = safeStr(dep.state?.description)
                          .toUpperCase() == 'ACTIVADO';

                      return Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [

                            // Avatar
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor:
                                  Color(0xFF4A6B5A).withOpacity(0.15),
                                  child: Text(
                                    safeStr(dep.nameDependence).isNotEmpty
                                        ? safeStr(dep.nameDependence)[0]
                                        .toUpperCase()
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
                                    width: 12, height: 12,
                                    decoration: BoxDecoration(
                                      color: activo
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(width: 12),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    safeStr(dep.nameDependence),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.tag,
                                          size: 13,
                                          color: Color(0xFF4A6B5A)),
                                      SizedBox(width: 4),
                                      Text(
                                        'ID: ${dep.idDependence}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Badge + menú
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: activo
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6, height: 6,
                                        decoration: BoxDecoration(
                                          color: activo
                                              ? Colors.green
                                              : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        activo ? 'Activo' : 'Inactivo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: activo
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () =>
                                      _showMenuOption(context, dep),
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

          if (state is DependenceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  SizedBox(height: 12),
                  Text(state.message,
                      style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A6B5A),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      context.read<DependenceBloc>().add(LoadDependenceEvent());
                    },
                  ),
                ],
              ),
            );
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