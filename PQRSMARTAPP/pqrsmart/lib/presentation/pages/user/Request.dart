import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class Pqrs extends StatefulWidget {
  const Pqrs({Key? key}) : super(key: key);

  @override
  _PqrsState createState() => _PqrsState();
}

class _PqrsState extends State<Pqrs> {
  String _filtroSeleccionado = 'Todos';
  String _busquedaRadicado = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filtros = [
    'Todos',
    'Petición',
    'Queja',
    'Reclamo',
    'Sugerencia',
    'Denuncia',
  ];

  String safeStr(dynamic value, [String fallback = 'No disponible']) {
    if (value == null) return fallback;
    return value.toString();
  }

  // Mapea el tipo de solicitud del backend al texto visible
  String _tipoLegible(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'PETICION':   return 'Petición';
      case 'QUEJA':      return 'Queja';
      case 'RECLAMO':    return 'Reclamo';
      case 'SUGERENCIA': return 'Sugerencia';
      case 'DENUNCIA':   return 'Denuncia';
      default:           return tipo;
    }
  }

  // Filtra la lista según el chip seleccionado y la búsqueda por radicado
  List<dynamic> _aplicarFiltro(List<dynamic> requests) {
    List<dynamic> resultado = requests;

    // Filtro por tipo
    switch (_filtroSeleccionado) {
      case 'Petición':
        resultado = resultado.where((r) =>
        safeStr(r.requestType?.name).toUpperCase() == 'PETICION').toList();
        break;
      case 'Queja':
        resultado = resultado.where((r) =>
        safeStr(r.requestType?.name).toUpperCase() == 'QUEJA').toList();
        break;
      case 'Reclamo':
        resultado = resultado.where((r) =>
        safeStr(r.requestType?.name).toUpperCase() == 'RECLAMO').toList();
        break;
      case 'Sugerencia':
        resultado = resultado.where((r) =>
        safeStr(r.requestType?.name).toUpperCase() == 'SUGERENCIA').toList();
        break;
      case 'Denuncia':
        resultado = resultado.where((r) =>
        safeStr(r.requestType?.name).toUpperCase() == 'DENUNCIA').toList();
        break;
    }

    // Filtro por radicado
    if (_busquedaRadicado.isNotEmpty) {
      resultado = resultado.where((r) =>
          safeStr(r.radicado).toLowerCase()
              .contains(_busquedaRadicado.toLowerCase())).toList();
    }

    return resultado;
  }

  // Estadísticas del resumen
  Map<String, int> _estadisticas(List<dynamic> requests) {
    return {
      'total':      requests.length,
      'peticiones': requests.where((r) =>
      safeStr(r.requestType?.name).toUpperCase() == 'PETICION').length,
      'quejas':     requests.where((r) =>
      safeStr(r.requestType?.name).toUpperCase() == 'QUEJA').length,
      'reclamos':   requests.where((r) =>
      safeStr(r.requestType?.name).toUpperCase() == 'RECLAMO').length,
      'sugerencias': requests.where((r) =>
      safeStr(r.requestType?.name).toUpperCase() == 'SUGERENCIA').length,
      'denuncias':  requests.where((r) =>
      safeStr(r.requestType?.name).toUpperCase() == 'DENUNCIA').length,
    };
  }

  // Color por tipo de solicitud
  Color _colorTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'PETICION':   return Colors.blue;
      case 'QUEJA':      return Colors.orange;
      case 'RECLAMO':    return Colors.red;
      case 'SUGERENCIA': return Colors.green;
      case 'DENUNCIA':   return Colors.purple;
      default:           return Colors.grey;
    }
  }

  // Color por estado de la solicitud
  Color _colorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':  return Colors.orange;
      case 'EN PROCESO': return Colors.blue;
      case 'RESUELTO':   return Colors.green;
      case 'CERRADO':    return Colors.grey;
      default:           return Colors.grey;
    }
  }

  void _showDetailsRequest(BuildContext context, dynamic request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
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
                // Radicado destacado
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A6B5A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF4A6B5A).withOpacity(0.4)),
                    ),
                    child: Column(
                      children: [
                        Text('Radicado',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Text(
                          safeStr(request.radicado),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A6B5A),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('Detalle de la Solicitud',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Divider(),
                _infoFila(Icons.category,      'Tipo',        _tipoLegible(safeStr(request.requestType?.name))),
                _infoFila(Icons.person,         'Solicitante', '${safeStr(request.user?.name)} ${safeStr(request.user?.lastName)}'),
                _infoFila(Icons.email,          'Email',       safeStr(request.user?.email)),
                _infoFila(Icons.business,       'Dependencia', safeStr(request.dependence?.nameDependence)),
                _infoFila(Icons.label,          'Categoría',   safeStr(request.category?.nameCategory)),
                _infoFila(Icons.calendar_today, 'Fecha',       safeStr(request.date)),
                _infoFila(Icons.info_outline,   'Estado',      safeStr(request.requestState?.name)),
                _infoFila(Icons.forum,          'Medio resp.', safeStr(request.mediumAnswer)),
                SizedBox(height: 12),
                Text('Descripción',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(safeStr(request.description),
                      style: TextStyle(fontSize: 13, height: 1.5)),
                ),
                if (safeStr(request.answer).isNotEmpty &&
                    request.answer != 'No disponible') ...[
                  SizedBox(height: 12),
                  Text('Respuesta',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A6B5A).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF4A6B5A).withOpacity(0.2)),
                    ),
                    child: Text(safeStr(request.answer),
                        style: TextStyle(fontSize: 13, height: 1.5)),
                  ),
                ],
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenuOption(BuildContext context, dynamic request) {
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
                _showDetailsRequest(context, request);
              },
            ),
            ListTile(
              leading: Icon(Icons.reply_outlined, color: Color(0xFF4A6B5A)),
              title: Text('Responder solicitud'),
              onTap: () {
                Navigator.pop(context);
                // TODO: navegar a responder solicitud
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: Colors.orange),
              title: Text('Cambiar estado',
                  style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                // TODO: cambiar estado
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file, color: Color(0xFF4A6B5A)),
              title: Text('Ver archivo adjunto'),
              onTap: () {
                Navigator.pop(context);
                // TODO: abrir archivo
              },
            ),
          ],
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
        title: Text('PQRS'),
        centerTitle: true,
        backgroundColor: Color(0xFF4A6B5A),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por radicado...',
                hintStyle: TextStyle(color: Colors.white60),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                suffixIcon: _busquedaRadicado.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _busquedaRadicado = '');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _busquedaRadicado = value),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'cerrar_sesion') _signOut(context);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'perfil',
                child: Row(children: [
                  Icon(Icons.person, color: Color(0xFF4A6B5A)),
                  SizedBox(width: 10),
                  Text('Perfil'),
                ]),
              ),
              PopupMenuItem(
                value: 'cerrar_sesion',
                child: Row(children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          if (state is RequestLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is RequestLoaded) {
            final stats    = _estadisticas(state.request);
            final filtered = _aplicarFiltro(state.request);

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
                            onSelected: (_) =>
                                setState(() => _filtroSeleccionado = filtro),
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
                    '${stats['total']} solicitudes  •  '
                        'P: ${stats['peticiones']}  •  '
                        'Q: ${stats['quejas']}  •  '
                        'R: ${stats['reclamos']}  •  '
                        'S: ${stats['sugerencias']}  •  '
                        'D: ${stats['denuncias']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),

                Divider(height: 1),

                // ── Lista de solicitudes ─────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 12),
                        Text('No se encontraron solicitudes',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final request = filtered[index];
                      final tipo    = safeStr(request.requestType?.name);
                      final estado  = safeStr(request.requestState?.name);
                      final colorTipo   = _colorTipo(tipo);
                      final colorEstado = _colorEstado(estado);

                      return Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [

                            // Icono tipo
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: colorTipo.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.description_outlined,
                                  color: colorTipo, size: 26),
                            ),

                            SizedBox(width: 12),

                            // Info principal
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Radicado como título
                                  Text(
                                    safeStr(request.radicado),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${safeStr(request.user?.name)} ${safeStr(request.user?.lastName)}',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Badge tipo
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorTipo.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          _tipoLegible(tipo),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorTipo,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(Icons.calendar_today,
                                          size: 11, color: Colors.grey[400]),
                                      SizedBox(width: 3),
                                      Text(
                                        safeStr(request.date),
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Estado + menú
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colorEstado.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6, height: 6,
                                        decoration: BoxDecoration(
                                          color: colorEstado,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        estado,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorEstado,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () => _showMenuOption(context, request),
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

          if (state is RequestError) {
            return Center(child: Text(state.message));
          }

          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}