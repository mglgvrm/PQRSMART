package Proyecto.PQRSMART.Domain.Dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

// Respuesta resumida del endpoint del mapa: periodo, total, tamaño de celda y agregados.
@Data
@Builder
public class HeatmapResponseDTO {
    private boolean boundaryAvailable;
    private String message;
    private String period;
    private long totalRequests;
    private double gridCellSizeDegrees;
    private Map<String, Long> typeDistribution;
    private List<HeatmapCellDTO> cells;
}
