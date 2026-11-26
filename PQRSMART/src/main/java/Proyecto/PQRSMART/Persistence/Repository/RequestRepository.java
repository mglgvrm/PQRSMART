package Proyecto.PQRSMART.Persistence.Repository;

import Proyecto.PQRSMART.Persistence.Entity.Dependence;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@org.springframework.stereotype.Repository
public interface RequestRepository extends JpaRepository<Request, Long> {
    List<Request> findByUserUser(String user);
    List<Request> findByDependence(Dependence dependence);
    List<Request> findByDateBetween(LocalDate startDate, LocalDate endDate);
    Optional<Request> findByRadicado(String radicado);
    List<Request> findByRadicadoStartingWith(String prefix);

    // Consulta solicitudes georreferenciadas; cada filtro se habilita mediante su flag.
    @Query("""
            select r from Request r
            where r.latitude is not null and r.longitude is not null
              and (:filterFromDate = false or r.date >= :fromDate)
              and (:filterToDate = false or r.date <= :toDate)
              and (:filterRequestType = false
                   or r.requestType.idRequestType = :requestTypeId)
              and (:filterRequestState = false
                   or r.requestState.idRequestState = :requestStateId)
            """)
    List<Request> findGeolocatedForHeatmap(
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate,
            @Param("requestTypeId") Long requestTypeId,
            @Param("requestStateId") Long requestStateId,
            @Param("filterFromDate") boolean filterFromDate,
            @Param("filterToDate") boolean filterToDate,
            @Param("filterRequestType") boolean filterRequestType,
            @Param("filterRequestState") boolean filterRequestState
    );
}
