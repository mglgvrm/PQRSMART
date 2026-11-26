package Proyecto.PQRSMART.Domain.Dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RequestStateUpdateDTO {
    private Long idRequestState;
    private String observation;
}
