import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/model/CategoryModel.dart';
import 'package:pqrsmart/data/model/DependenceModel.dart';
import 'package:pqrsmart/data/model/RequestModel.dart';
import 'package:pqrsmart/data/model/RequestStateModel.dart';
import 'package:pqrsmart/data/model/RequestTypeModel.dart';
import 'package:pqrsmart/data/repository/CategoryRepository.dart';
import 'package:pqrsmart/data/repository/DependenceRepository.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/data/repository/RequestTypeRepository.dart';
import 'package:pqrsmart/data/services/CategoryService.dart';
import 'package:pqrsmart/data/services/DependenceService.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/RequestTypeService.dart';
import 'package:pqrsmart/presentation/blocs/CategoryBloc.dart';
import 'package:pqrsmart/presentation/blocs/ChatBoxBloc.dart';
import 'package:pqrsmart/presentation/blocs/DependenceBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestTypeBloc.dart';
import 'package:pqrsmart/presentation/states/CategoryEvent.dart';
import 'package:pqrsmart/presentation/states/CategoryState.dart';
import 'package:pqrsmart/presentation/states/ChatBoxEvent.dart';
import 'package:pqrsmart/presentation/states/ChatBoxState.dart';
import 'package:pqrsmart/presentation/states/DependenceEvent.dart';
import 'package:pqrsmart/presentation/states/DependenceState.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/RequestState.dart';
import 'package:pqrsmart/presentation/states/RequestTypeEvent.dart';
import 'package:pqrsmart/presentation/states/RequestTypeState.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({Key? key}) : super(key: key);

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final _descripcionController = TextEditingController();
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();

  RequestTypeModel? _tipoSeleccionado;
  DependenceModel? _dependenciaSeleccionada;
  CategoryModel? _categoriaSeleccionada;
  bool _iaChatVisible = false;

  final List<String> _tipos = ['Peticion', 'Queja', 'Reclamo', 'Sugerencia'];

  static const _verde = Color(0xFF4A6B5A);
  static const _verdeLight = Color(0xFF6B9E82);
  static const _bg = Color(0xFFF2F4F3);

  @override
  void dispose() {
    _descripcionController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Envía mensaje usando el ChatBoxBloc ──────────────────
  void _enviarMensajeIA(BuildContext ctx, String mensaje) {
    if (mensaje.trim().isEmpty) return;
    ctx.read<ChatBoxBloc>().add(SendMessageChatBox(mensaje));
    _chatController.clear();
    _scrollToBottom();
  }

  void _copiarTexto(String texto) {
    Clipboard.setData(ClipboardData(text: texto)); // 👈 copia todo el texto
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copiado al portapapeles'),
        backgroundColor: _verde,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _usarSugerencia(String texto) {
    _descripcionController.text = _extraerSugerencia(texto);
    setState(() => _iaChatVisible = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sugerencia aplicada'),
        backgroundColor: _verde,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _extraerSugerencia(String texto) {
    final idx = texto.indexOf(':');
    if (idx != -1 && idx < 40) return texto.substring(idx + 1).trim();
    return texto.trim();
  }

  bool _esSugerencia(String texto) =>
      texto.toLowerCase().contains('sugerencia') ||
      (texto.contains(':') && texto.indexOf(':') < 40);

  List<CategoryModel> _filtrarCategorias(List<CategoryModel> todas) {
    if (_dependenciaSeleccionada == null) return [];
    return todas
        .where(
          (c) =>
              c.dependence?.idDependence ==
              _dependenciaSeleccionada!.idDependence,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DependenceBloc>(
          create: (_) =>
              DependenceBloc(DependenceRepository(DependenceService()))
                ..add(LoadDependenceEvent()),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) =>
              CategoryBloc(CategoryRepository(CategoryService()))
                ..add(LoadCategoriesEvent()),
        ),
        // ── ChatBoxBloc agregado aquí ──────────────────────
        BlocProvider<ChatBoxBloc>(
          create: (_) => ChatBoxBloc()..add(LoadChatBox()),
        ),
        BlocProvider<RequestTypeBloc>(
          create: (_) =>
              RequestTypeBloc(RequestTypeRepository(RequestTypeService()))
                ..add(LoadRequestTypeEvent()),
        ),
        BlocProvider<RequestBloc>(
          create: (_) => RequestBloc(RequestRepository(RequestService())),
        ),
      ],
    child: BlocListener<RequestBloc, RequestState>(
    listener: (context, state) {
    if (state is RequestSaved) {
    Navigator.pop(context, true); // 👈 vuelve y manda señal
    }

    if (state is RequestError) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.message)),
    );
    }
    },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'Nueva PQRS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          leadingWidth: 90,
          actions: [
            Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    print("CLICK ENVIAR");
                    context.read<RequestBloc>().add(
                      SaveRequestEvent(
                        RequestModel(
                          description: _descripcionController.text,
                          requestType: _tipoSeleccionado,
                          dependence: _dependenciaSeleccionada,
                          category: _categoriaSeleccionada,
                          date: DateTime.now().toIso8601String().split('T')[0],
                          mediumAnswer: "Correo",
                          requestState: RequestStateModel(
                            idRequestState: 1,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Enviar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        body: BlocBuilder<RequestTypeBloc, RequestTypeState>(
          builder: (context, requestTypeState) {
            return BlocBuilder<DependenceBloc, DependenceState>(
              builder: (context, dependenceState) {
                if (requestTypeState is RequestTypeLoading ||
                    dependenceState is DependenceLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: _verde),
                  );
                }

                if (dependenceState is DependenceLoaded &&
                    requestTypeState is RequestTypeLoaded) {
                  final dependencias = dependenceState.dependence;
                  final request = requestTypeState
                      .requestTypeModel; // 👈 ajusta según tu estado

                  return BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, categoryState) {
                      List<CategoryModel> categoriasFiltradas = [];
                      if (categoryState is CategoryLoaded) {
                        categoriasFiltradas = _filtrarCategorias(
                          categoryState.categories,
                        );
                      }

                      if (_categoriaSeleccionada != null &&
                          !categoriasFiltradas.contains(
                            _categoriaSeleccionada,
                          )) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() => _categoriaSeleccionada = null);
                        });
                      }

                      return Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('Tipo de PQRS'),
                                const SizedBox(height: 8),
                                _dropdownTipo(request),
                                const SizedBox(height: 20),

                                _label('Dependencia'),
                                const SizedBox(height: 8),
                                _dropdownDependencia(dependencias),
                                const SizedBox(height: 20),

                                _label('Categoría'),
                                const SizedBox(height: 8),
                                _dropdownCategoria(
                                  categoriasFiltradas,
                                  categoryState is CategoryLoading,
                                ),
                                const SizedBox(height: 20),

                                _label('Descripción'),
                                const SizedBox(height: 8),
                                _campo(
                                  controller: _descripcionController,
                                  hint:
                                      'Explica detalladamente tu solicitud...',
                                  maxLines: 6,
                                ),
                                const SizedBox(height: 28),

                                _botonIA(),
                              ],
                            ),
                          ),

                          // ── Chat Sheet con BlocBuilder ───────
                          if (_iaChatVisible) _chatSheetBloc(),
                        ],
                      );
                    },
                  );
                }
                if (dependenceState is DependenceError) {
                  return Center(child: Text(dependenceState.message));
                }

                return Container();
              },
            );
          },
        ),
      ),
    ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _dropdownTipo(List<RequestTypeModel> requestTypeModel) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<RequestTypeModel>(
        value: _tipoSeleccionado,
        isExpanded: true,
        hint: Text(
          'Selecciona un tipo de PQRS',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _verde),
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        onChanged: (v) => setState(() => _tipoSeleccionado = v!),
        items: requestTypeModel
            .map(
              (t) => DropdownMenuItem(
                value: t,
                child: Text(t.nameRequestType ?? 'sin tipo'),
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _dropdownDependencia(List<DependenceModel> dependencias) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<DependenceModel>(
        value: _dependenciaSeleccionada,
        isExpanded: true,
        hint: Text(
          'Selecciona una dependencia',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _verde),
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        onChanged: (v) {
          setState(() {
            _dependenciaSeleccionada = v;
            _categoriaSeleccionada = null;
          });
        },
        items: dependencias
            .map(
              (d) => DropdownMenuItem(
                value: d,
                child: Text(d.nameDependence ?? 'Sin nombre'),
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _dropdownCategoria(List<CategoryModel> categorias, bool loading) {
    if (_dependenciaSeleccionada == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 18),
            const SizedBox(width: 8),
            Text(
              'Selecciona primero una dependencia',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: _verde),
            ),
            const SizedBox(width: 10),
            Text(
              'Cargando categorías...',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (categorias.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.category_outlined, color: Colors.grey[400], size: 18),
            const SizedBox(width: 8),
            Text(
              'Sin categorías para esta dependencia',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CategoryModel>(
          value: _categoriaSeleccionada,
          isExpanded: true,
          hint: Text(
            'Selecciona una categoría',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _verde),
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          onChanged: (v) => setState(() => _categoriaSeleccionada = v),
          items: categorias
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.nameCategory ?? 'Sin nombre'),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding: const EdgeInsets.all(16),
        border: InputBorder.none,
      ),
    ),
  );

  Widget _botonIA() => GestureDetector(
    onTap: () => setState(() => _iaChatVisible = true),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_verde, _verdeLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _verde.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asistente IA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'Mejora tu redacción con IA',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    ),
  );

  // ── Chat Sheet conectado al ChatBoxBloc ──────────────────
  Widget _chatSheetBloc() => BlocConsumer<ChatBoxBloc, ChatBoxState>(
    listener: (context, state) {
      // Scroll al fondo cuando llega respuesta
      if (state is ChatBoxLoaded || state is ChatBoxSending) {
        _scrollToBottom();
      }
    },
    builder: (context, state) {
      // Extraer mensajes e indicador de carga según estado
      final messages = switch (state) {
        ChatBoxLoaded() => state.messages,
        ChatBoxSending() => state.messages,
        _ => <dynamic>[],
      };
      final isLoading = state is ChatBoxSending;

      return DraggableScrollableSheet(
        initialChildSize: 0.58,
        minChildSize: 0.4,
        maxChildSize: 0.93,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _verde.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: _verde,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Asistente IA',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () =>
                              setState(() => _iaChatVisible = false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // ── Lista de mensajes ──────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (isLoading && i == messages.length) {
                      return _typingBubble();
                    }
                    final m = messages[i];
                    final isIA = m.role == 'assistant';
                    return _bubble(m.content, isIA);
                  },
                ),
              ),

              _inputArea(context),
            ],
          ),
        ),
      );
    },
  );

  Widget _bubble(String texto, bool isIA) {
    return Align(
      alignment: isIA ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          right: isIA ? 40 : 0,
          left: isIA ? 0 : 40,
        ),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isIA ? Colors.grey[100] : _verde,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isIA ? 4 : 16),
            bottomRight: Radius.circular(isIA ? 16 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texto,
              style: TextStyle(
                color: isIA ? Colors.black87 : Colors.white,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            // 👇 Siempre muestra botones en mensajes del asistente
            if (isIA) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _accionBubble(
                    icon: Icons.copy,
                    label: 'Copiar',
                    filled: true,
                    onTap: () => _copiarTexto(texto),
                  ),
                  const SizedBox(width: 8),
                  _accionBubble(
                    icon: Icons.edit_note,
                    label: 'Usar',
                    filled: false,
                    onTap: () => _usarSugerencia(texto),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _accionBubble({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? _verde : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: filled ? null : Border.all(color: _verde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: filled ? Colors.white : _verde, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : _verde,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _typingBubble() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _verde.withOpacity(0.5 + i * 0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _inputArea(BuildContext ctx) => Container(
    padding: EdgeInsets.fromLTRB(
      12,
      10,
      12,
      MediaQuery.of(context).viewInsets.bottom + 14,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Colors.grey.shade200)),
    ),
    child: Row(
      children: [
        // Botón "mejorar descripción" si hay texto
        if (_descripcionController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _enviarMensajeIA(
                ctx,
                'Mejora esta descripción: '
                '${_descripcionController.text}',
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _verde.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_fix_high, color: _verde, size: 20),
              ),
            ),
          ),
        Expanded(
          child: TextField(
            controller: _chatController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Escribe un mensaje...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (v) => _enviarMensajeIA(ctx, v),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _enviarMensajeIA(ctx, _chatController.text),
          child: Container(
            padding: const EdgeInsets.all(11),
            decoration: const BoxDecoration(
              color: _verde,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}
