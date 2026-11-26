package Proyecto.PQRSMART.Domain.Dto;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PredictionResponseDTO {

    private String dependencia;

    private Double probabilidad;

    private String periodo;

    private String mensaje;
}