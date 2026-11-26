package Proyecto.PQRSMART.Persistence.Repository;

import Proyecto.PQRSMART.Persistence.Entity.RequestStateHistory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RequestStateHistoryRepository extends JpaRepository<RequestStateHistory, Long> {
    List<RequestStateHistory> findByRequestIdRequestOrderByChangedAtAsc(Long requestId);
}
