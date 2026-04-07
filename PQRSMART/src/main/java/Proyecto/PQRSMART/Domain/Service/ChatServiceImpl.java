package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Domain.Dto.ChatRequest;
import Proyecto.PQRSMART.Domain.Service.Interfaces.ChatService;
import lombok.AllArgsConstructor;
import lombok.Builder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.ai.chat.client.ChatClient;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;


@Service
@AllArgsConstructor
@Builder
public class ChatServiceImpl implements ChatService {


    private final ChatClient chatClient;

    public String preguntarIA(String mensaje) {
        RestTemplate restTemplate = new RestTemplate();
        String prompt = """
Eres un asistente experto en PQRS en Colombia.
Redacta documentos formales, claros y jurídicos.
No inventes datos.

Puedes:
- Explicar qué es cada tipo de PQRS
- Redactar quejas, reclamos, peticiones y sugerencias
- Pedir información si falta
- Responder de forma clara y formal
Estructura:
- Encabezado
- Hechos
- Solicitud
- Despedida
Responde al usuario de forma útil.

y si te piden algo diferente al estos temas rechazas

y no pidas informacion personal nada de nombre, identificacion ni nada de eso ya que en la peticion ya va incluida

Usuario: """ + mensaje;


        return chatClient.prompt()
                .user(prompt)
                .call()
                .content();

    }


    public String chat(ChatRequest request) {

        List<String> conversation = new ArrayList<>();

        for (var msg : request.getMessages()) {
            conversation.add(msg.getRole() + ": " + msg.getContent());
        }

        String fullPrompt = """
Eres un asistente experto en PQRS en Colombia.

Funciones:
- Redactar quejas, reclamos, peticiones y sugerencias
- Explicar conceptos
- Mejorar textos

Reglas:
- Responder SIEMPRE de forma formal
- No inventar información
- Si falta información, solicitarla

Estructura obligatoria:
- Encabezado
- Hechos
- Solicitud
- Despedida

y no pidas informacion personal nada de nombre, identificacion ni nada de eso ya que en la peticion ya va incluida

Si la solicitud no es de PQRS, indícalo claramente.
""" + String.join("\n", conversation) + "\nRespuesta:";

        return chatClient.prompt()
                .user(fullPrompt)
                .call()
                .content();
    }
}
