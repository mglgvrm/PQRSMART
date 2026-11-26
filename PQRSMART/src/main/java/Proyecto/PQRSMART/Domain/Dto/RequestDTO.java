package Proyecto.PQRSMART.Domain.Dto;


import lombok.*;

import java.time.LocalDate;
import java.time.Instant;
import Proyecto.PQRSMART.Persistence.Entity.RequestLocationMethod;
import Proyecto.PQRSMART.Persistence.Entity.RequestLocationSource;


@AllArgsConstructor
@NoArgsConstructor
@Builder
@Data
public class RequestDTO {
    private Long idRequest;
    private UsuarioDto user;
    private RequestTypeDTO requestType;
    private DependenceDTO dependence;
    private CategoryDTO category;
    private String description;
    private LocalDate date;
    private Instant updatedAt;
    private String answer;
    private RequestStateDTO requestState;
    private String mediumAnswer;
    private String archivo;
    private String archiveAnswer;
    private String radicado;
    private Double latitude;
    private Double longitude;
    private RequestLocationSource locationSource;
    private RequestLocationMethod locationMethod;
    private String locationDescription;
    private Instant locationCapturedAt;
    private String citizenName;
    private String citizenEmail;
    private String citizenPhone;
    private UsuarioDto registeredBy;

}
