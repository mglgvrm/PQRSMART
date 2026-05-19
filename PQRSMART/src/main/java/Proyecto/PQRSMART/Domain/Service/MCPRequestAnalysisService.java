package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Domain.Dto.AIAnalysisResponse;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MCPRequestAnalysisService {

    private final ChatClient chatClient;
    private final UsuarioRepository userRepository;

    public AIAnalysisResponse analyze(Request request) throws JsonProcessingException {

        String prompt = """
        Analiza la siguiente PQRS.

        Dependencia: %s
        Categoría: %s
        Descripción: %s

        Debes determinar:

        1. Si la solicitud es coherente.
        2. Si debe rechazarse.
        3. Prioridad:
           BAJA, MEDIA, ALTA o CRITICA.
        4. Nivel de relevancia de 0 a 1.

        Rechazar si:
        - la descripción no coincide con la dependencia
        - la categoría no coincide
        - es spam
        - no tiene sentido

        Responde SOLO en JSON.
        """.formatted(
                request.getDependence().getNameDependence(),
                request.getCategory().getNameCategory(),
                request.getDescription()
        );

        String response = chatClient.prompt()
                .user(prompt)
                .call()
                .content();

        // Convertir JSON a objeto
        ObjectMapper mapper = new ObjectMapper();

        AIAnalysisResponse ai =
                mapper.readValue(response, AIAnalysisResponse.class);

        // Buscar usuario compatible SOLO de la dependencia
        if(Boolean.TRUE.equals(ai.getValid())){

            List<User> users =
                    userRepository.findByDependence(
                            request.getDependence()
                    );

            User assigned =
                    selectBestUser(users);

            ai.setAssignedUserId(assigned.getId());
        }

        return ai;
    }

    private User selectBestUser(List<User> users){

        // lógica:
        // menos carga
        // activo
        // mismo rol
        // disponible

        return users.get(0);
    }
}
