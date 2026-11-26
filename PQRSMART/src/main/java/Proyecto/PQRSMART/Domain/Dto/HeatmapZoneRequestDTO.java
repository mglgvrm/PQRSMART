package Proyecto.PQRSMART.Domain.Dto;

import lombok.Builder;
import lombok.Value;

import java.time.LocalDate;

// Datos de la PQRS mostrados al administrador, sin identidad ni contacto ciudadano.
@Value
@Builder
public class HeatmapZoneRequestDTO {
    Long idRequest;
    String radicado;
    String requestType;
    String category;
    String dependence;
    LocalDate date;
    String state;
    String description;
    String answer;
}
