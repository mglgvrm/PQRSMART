import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/data/model/ChatBoxModel.dart';
import 'package:pqrsmart/data/services/ChatBoxService.dart';
import 'package:pqrsmart/presentation/states/ChatBoxEvent.dart';
import 'package:pqrsmart/presentation/states/ChatBoxState.dart';

class ChatBoxBloc extends Bloc<ChatBoxEvent, ChatBoxState> {

  final ChatBoxService _service = ChatBoxService();

  // Historial completo de mensajes
  final List<ChatBoxModel> _messages = [
    ChatBoxModel(
      role: 'assistant',
      content: 'Hola 👋, soy tu asistente de PQRS. '
          'Puedo ayudarte a redactar quejas, reclamos o peticiones. '
          '¿Qué necesitas hoy?',
    ),
  ];

  ChatBoxBloc() : super(ChatBoxInitial()) {

    // ── Cargar historial inicial ──────────────────────────
    on<LoadChatBox>((event, emit) async {
      emit(ChatBoxLoading());
      try {
        // Si tu backend guarda historial, cárgalo aquí
        // final history = await _service.getChatBox();
        // _messages.addAll(history);
        emit(ChatBoxLoaded(List.from(_messages)));
      } catch (e) {
        emit(ChatBoxError('Error al cargar el chat: $e'));
      }
    });

    // ── Enviar mensaje ────────────────────────────────────
    on<SendMessageChatBox>((event, emit) async {
      if (event.message.trim().isEmpty) return;

      // 1. Agrega mensaje del usuario al historial
      _messages.add(ChatBoxModel(role: 'user', content: event.message));

      // 2. Emite estado "enviando" para mostrar el typing bubble
      emit(ChatBoxSending(List.from(_messages)));

      try {
        // 3. Llama al servicio con el historial completo
        final respuesta = await _service.sendMessage(_messages);

        // 4. Agrega respuesta del asistente
        _messages.add(ChatBoxModel(role: 'assistant', content: respuesta));

        emit(ChatBoxLoaded(List.from(_messages)));
      } catch (e) {
        // Agrega mensaje de error en el chat
        _messages.add(ChatBoxModel(
          role: 'assistant',
          content: 'Error al conectar con el asistente. Intenta de nuevo.',
        ));
        emit(ChatBoxLoaded(List.from(_messages)));
      }
    });
  }
}