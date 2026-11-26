package Proyecto.PQRSMART.Domain.Dto;

import lombok.Builder;
import lombok.Value;

import java.util.List;
import java.util.Map;

// Detalle de una celda: índices, total, desgloses y solicitudes coincidentes.
@Value
@Builder
public class HeatmapZoneDetailsDTO {
    int latitudeIndex;
    int longitudeIndex;
    long totalRequests;
    Map<String, Long> typeDistribution;
    Map<String, Long> categoryDistribution;
    Map<String, Long> dependenceDistribution;
    Map<String, Long> statusDistribution;
    List<HeatmapZoneRequestDTO> requests;
}
