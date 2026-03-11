package Proyecto.PQRSMART.Persistence.Repository;

import Proyecto.PQRSMART.Persistence.Entity.Request;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

@org.springframework.stereotype.Repository
public interface RequestRepository extends JpaRepository<Request, Long> {
    List<Request> findByUserUser(String user);
}
