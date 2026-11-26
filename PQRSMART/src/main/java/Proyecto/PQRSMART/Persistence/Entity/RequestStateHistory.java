package Proyecto.PQRSMART.Persistence.Entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "Historial_Estado_Solicitud")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RequestStateHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID_Historial_Estado")
    private Long id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "ID_Solicitud", nullable = false)
    private Request request;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "Estado_Anterior")
    private RequestState previousState;

    @ManyToOne(optional = false, fetch = FetchType.EAGER)
    @JoinColumn(name = "Estado_Nuevo", nullable = false)
    private RequestState newState;

    @Column(name = "Fecha_Cambio", nullable = false)
    private Instant changedAt;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "Funcionario_Responsable")
    private User changedBy;

    @Column(name = "Observacion", columnDefinition = "TEXT")
    private String observation;
}
