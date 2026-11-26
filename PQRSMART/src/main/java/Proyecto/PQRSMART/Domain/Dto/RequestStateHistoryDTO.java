package Proyecto.PQRSMART.Domain.Dto;

import lombok.Builder;
import lombok.Value;

import java.time.Instant;

@Value
@Builder
public class RequestStateHistoryDTO {
    String previousState;
    String newState;
    Instant changedAt;
    String changedBy;
    String observation;
}
