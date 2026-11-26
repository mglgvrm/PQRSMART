package Proyecto.PQRSMART.Domain.Dto;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

// Conteos y distribuciones de las solicitudes asignadas a una celda geográfica.
@Data
@Builder
public class HeatmapCellDTO {
    private int latitudeIndex;
    private int longitudeIndex;
    private double latitude;
    private double longitude;
    private long count;
    private String mostFrequentType;
    private Map<String, Long> statusDistribution;
    private Map<String, Long> typeDistribution;
    private Map<String, Long> categoryDistribution;
    private Map<String, Long> dependenceDistribution;
}
