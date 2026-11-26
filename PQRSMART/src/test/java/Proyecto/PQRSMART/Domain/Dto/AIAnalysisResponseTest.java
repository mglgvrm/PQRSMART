package Proyecto.PQRSMART.Domain.Dto;

import Proyecto.PQRSMART.Persistence.Entity.Priority;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AIAnalysisResponseTest {
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void acceptsSpanishCoherenceKeyReturnedByExistingAiPrompt() throws Exception {
        AIAnalysisResponse response = objectMapper.readValue("""
                {
                  "valid": true,
                  "coherente": true,
                  "relevance": 0.85,
                  "reason": "La solicitud corresponde a la categoría.",
                  "priority": "MEDIA"
                }
                """, AIAnalysisResponse.class);

        assertTrue(response.getValid());
        assertTrue(response.getCoherence());
        assertEquals(0.85, response.getRelevance());
        assertEquals(Priority.MEDIA, response.getPriority());
    }

    @Test
    void continuesAcceptingCanonicalCoherenceKey() throws Exception {
        AIAnalysisResponse response = objectMapper.readValue("""
                {
                  "valid": false,
                  "coherence": false,
                  "relevance": 0.1,
                  "reason": "La descripción no corresponde.",
                  "priority": "BAJA"
                }
                """, AIAnalysisResponse.class);

        assertFalse(response.getValid());
        assertFalse(response.getCoherence());
        assertEquals(Priority.BAJA, response.getPriority());
    }
}
