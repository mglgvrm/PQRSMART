import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/presentation/blocs/ChatBoxBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/pages/ProfilePage.dart';
import 'package:pqrsmart/presentation/pages/admin/register/RegisterAdminPage.dart';
import 'package:pqrsmart/presentation/states/ChatBoxEvent.dart';
import 'package:pqrsmart/presentation/states/ChatBoxState.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';
import 'package:pqrsmart/presentation/states/UserSatate.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class User extends StatefulWidget {
  const User({Key? key}) : super(key: key);

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  String _filtroSeleccionado = 'Todos';
  final List<String> _filtros = [
    'Todos',
    'Administradores',
    'Funcionarios',
    'Usuarios',
    'Inactivos',
  ];

  bool _chatAbierto = false;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  void _enviarMensaje() {
    final texto = _chatController.text.trim();
    if (texto.isEmpty) return;
    context.read<ChatBoxBloc>().add(SendMessageChatBoxUser(texto));
    _chatController.clear();
  }

  String safeStr(dynamic value, [String fallback = 'No disponible']) {
    if (value == null) return fallback;
    return value.toString();
  }

  String _rolLegible(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrador';
      case 'SECRE':
        return 'Funcionarios';
      case 'USER':
        return 'Usuario';
      default:
        return role;
    }
  }

  List<dynamic> _aplicarFiltro(List<dynamic> users) {
    switch (_filtroSeleccionado) {
      case 'Administradores':
        return users.where((u) => safeStr(u.role).toUpperCase() == 'ADMIN').toList();
      case 'Funcionarios':
        return users.where((u) => safeStr(u.role).toUpperCase() == 'SECRE').toList();
      case 'Usuarios':
        return users.where((u) => safeStr(u.role).toUpperCase() == 'USER').toList();
      case 'Inactivos':
        return users
            .where((u) => safeStr(u.stateUser?.state).toUpperCase() != 'ACTIVO')
            .toList();
      default:
        return users;
    }
  }

  Map<String, int> _estadisticas(List<dynamic> users) {
    return {
      'total': users.length,
      'administradores': users.where((u) => safeStr(u.role).toUpperCase() == 'ADMIN').length,
      'usuarios': users.where((u) => safeStr(u.role).toUpperCase() == 'USER').length,
      'funcionarios': users.where((u) => safeStr(u.role).toUpperCase() == 'SECRE').length,
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
                width: 40,
                height: 4,
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
                  safeStr(user.name).isNotEmpty
                      ? safeStr(user.name)[0].toUpperCase()
                      : '?',
                  style: TextStyle(fontSize: 28, color: Color(0xFF4A6B5A)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Información del Usuario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            _infoFila(Icons.person, 'Nombre', '${safeStr(user.name)} ${safeStr(user.lastName)}'),
            _infoFila(Icons.email, 'Email', safeStr(user.email)),
            _infoFila(Icons.account_circle, 'Usuario', safeStr(user.user)),
            _infoFila(Icons.phone, 'Número', safeStr(user.number)),
            _infoFila(Icons.badge, 'Identificación', safeStr(user.identificationNumber)),
            _infoFila(Icons.security, 'Rol', _rolLegible(safeStr(user.role))),
            _infoFila(Icons.toggle_on, 'Estado', safeStr(user.stateUser?.state)),
            _infoFila(Icons.business, 'Dependencia', safeStr(user.dependence?.nameDependence)),
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
              width: 40,
              height: 4,
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
              leading: Icon(Icons.chat_bubble_outline, color: Color(0xFF4A6B5A)),
              title: Text('Enviar mensaje'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Color(0xFF4A6B5A)),
              title: Text('Editar usuario'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz, color: Color(0xFF4A6B5A)),
              title: Text('Cambiar rol'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new, color: Colors.orange),
              title: Text('Desactivar usuario', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                context.read<UserBloc>().add(DesactivarUsuarioEvent(user.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario desactivado'),
                    backgroundColor: Color(0xFF4A6B5A),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showViewFormAddUser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          child: BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: const RegisterAdminPage(),
          ),
        ),
      ),
    ).then((_) {
      context.read<UserBloc>().add(GetUserEvent());
    });
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildChatDesplegable() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_chatAbierto)
          BlocBuilder<ChatBoxBloc, ChatBoxState>(
            builder: (context, state) {
              final mensajes = state is ChatBoxUserLoaded
                  ? state.messages
                  : state is ChatBoxSending
                  ? state.messages
                  : <dynamic>[];

              final enviando = state is ChatBoxSending;

              if (mensajes.isNotEmpty) _scrollAlFinal();

              return Container(
                width: 300,
                height: 380,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Header ──────────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFF4A6B5A),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Asistente IA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _chatAbierto = false),
                            child: Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),

                    // ── Mensajes ─────────────────────────────────────
                    Expanded(
                      child: mensajes.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.smart_toy_outlined,
                              size: 40,
                              color: Color(0xFF4A6B5A).withOpacity(0.4),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '¡Hola! ¿En qué te puedo ayudar?',
                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        controller: _chatScrollController,
                        padding: EdgeInsets.all(12),
                        itemCount: mensajes.length + (enviando ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Burbuja typing al final
                          if (enviando && index == mensajes.length) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 8),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _TypingDot(delay: 0),
                                    SizedBox(width: 4),
                                    _TypingDot(delay: 200),
                                    SizedBox(width: 4),
                                    _TypingDot(delay: 400),
                                  ],
                                ),
                              ),
                            );
                          }

                          final msg = mensajes[index];
                          final esUsuario = msg.role == 'user';

                          return Align(
                            alignment: esUsuario
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              constraints: BoxConstraints(maxWidth: 220),
                              decoration: BoxDecoration(
                                color: esUsuario
                                    ? Color(0xFF4A6B5A)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg.content,
                                style: TextStyle(
                                  color: esUsuario
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Input ────────────────────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              enabled: !enviando,
                              style: TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: enviando
                                    ? 'Esperando respuesta...'
                                    : 'Escribe un mensaje...',
                                hintStyle: TextStyle(fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Color(0xFF4A6B5A)),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              onSubmitted: enviando ? null : (_) => _enviarMensaje(),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: enviando ? null : _enviarMensaje,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: enviando
                                    ? Colors.grey[400]
                                    : Color(0xFF4A6B5A),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.send, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        // ── FABs ──────────────────────────────────────────────────
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'chat',
              onPressed: () {
                setState(() => _chatAbierto = !_chatAbierto);
                if (!_chatAbierto) {
                  context.read<ChatBoxBloc>().add(LoadChatBox());
                }
              },
              backgroundColor: Color(0xFF4A6B5A),
              foregroundColor: Colors.white,
              shape: CircleBorder(),
              child: Icon(Icons.smart_toy_outlined),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'nuevo_usuario',
              onPressed: () => _showViewFormAddUser(context),
              backgroundColor: Color(0xFF4A6B5A),
              foregroundColor: Colors.white,
              child: Icon(Icons.person_add),
            ),
          ],
        ),
      ],
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
      floatingActionButton: _buildChatDesplegable(),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is CancelUserLoaded) {
            context.read<UserBloc>().add(GetUserEvent());
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is UserLoaded) {
            final stats = _estadisticas(state.user);
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

                // ── Estadísticas ─────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 10),
                  child: Text(
                    '${stats['total']} usuarios encontrados  •  '
                        'Administradores: ${stats['administradores']}  •  '
                        'Funcionarios: ${stats['funcionarios']} • '
                        'Usuarios: ${stats['usuarios']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),

                Divider(height: 1),

                // ── Lista ────────────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 12),
                        Text(
                          'No se encontraron usuarios',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      final activo =
                          safeStr(user.stateUser?.state).toUpperCase() == 'ACTIVO';

                      return InkWell(
                        onTap: () => _showMenuOption(context, user),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor:
                                    Color(0xFF4A6B5A).withOpacity(0.15),
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
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 12),
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
                                          color: Colors.grey[600], fontSize: 13),
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
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
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
                                      width: 6,
                                      height: 6,
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
                            ],
                          ),
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
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }
}

// ── Widget animado de typing ─────────────────────────────────────────────────
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.grey[500],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}