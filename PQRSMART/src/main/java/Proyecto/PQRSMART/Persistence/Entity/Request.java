package Proyecto.PQRSMART.Persistence.Entity;


import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.Instant;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "Solicitudes ")
public class Request {

    @Column(name = "ID_Solicitud")
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idRequest;

    @Column(name = "Radicado", unique = true)
    private String radicado;

    @JoinColumn(name = "Usuario", nullable = true)
    @ManyToOne(optional = true)
    private User user;

    @JoinColumn(name = "ID_Tipo_Solicitud")
    @ManyToOne(fetch = FetchType.EAGER)
    private RequestType requestType;

    @JoinColumn(name = "ID_Categoria")
    @ManyToOne(fetch = FetchType.EAGER)
    private Category category;

    
    @Column(name = "Descripcion_Solicitud", columnDefinition = "TEXT")
    private String description;


    @Column(name = "Fecha_Solicitud")
    private LocalDate date;

    @Column(name = "Fecha_Actualizacion")
    private Instant updatedAt;

    @Column(name = "Respuesta_Solicitud")
    private String answer;

    @JoinColumn(name = "Id_Estado_Solicitud")
    @ManyToOne(fetch = FetchType.EAGER)
    private RequestState requestState;

    @Column(name = "Medio_Respuesta")
    private String mediumAnswer;

    @JoinColumn (name = "ID_Dependencia")
    @ManyToOne
    private Dependence dependence;


    @Column(name = "Archivo")
    private String archivo;


    @Column(name = "Archivo_Respuesta")
    private String archiveAnswer;
    @Enumerated(EnumType.STRING)

    @Column(name = "Prioridad")
    private Priority priority;

    @ManyToOne
    @JoinColumn(name = "Usuario_Asignado")
    private User assignedUser;

    @Column(name = "Motivo_Rechazo")
    private String rejectReason;

    @Column(name = "Coherencia_IA")
    private Boolean aiCoherence;

    @Column(name = "Relevancia")
    private Double relevance;

    // Coordenadas persistidas que determinan la posición de cada PQRS en el mapa.
    @Column(name = "Latitud")
    private Double latitude;

    @Column(name = "Longitud")
    private Double longitude;

    @Enumerated(EnumType.STRING)
    @Column(name = "Fuente_Ubicacion")
    private RequestLocationSource locationSource;

    @Enumerated(EnumType.STRING)
    @Column(name = "Metodo_Ubicacion")
    private RequestLocationMethod locationMethod;

    @Column(name = "Descripcion_Lugar", length = 300)
    private String locationDescription;

    @Column(name = "Fecha_Captura_Ubicacion")
    private Instant locationCapturedAt;

    @Column(name = "Nombre_Ciudadano", length = 160)
    private String citizenName;

    @Column(name = "Correo_Ciudadano", length = 254)
    private String citizenEmail;

    @Column(name = "Telefono_Ciudadano", length = 40)
    private String citizenPhone;

    @ManyToOne
    @JoinColumn(name = "Registrado_Por")
    private User registeredBy;

    @PrePersist
    @PreUpdate
    private void updateTimestamp() {
        updatedAt = Instant.now();
    }
}
