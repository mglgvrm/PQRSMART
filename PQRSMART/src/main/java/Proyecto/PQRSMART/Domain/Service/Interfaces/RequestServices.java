package Proyecto.PQRSMART.Domain.Service.Interfaces;

import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Persistence.Entity.Request;

import java.util.List;
import java.util.Optional;

public interface RequestServices {
    List<RequestDTO> getAll();
    List<RequestDTO> getPqrs(String usuario);
    Optional<RequestDTO> findById(Long id);
    Request findEntityByIds(RequestDTO dto);
    Optional<Request> findEntityById(Long id);
    void update(RequestDTO requestDTO);
    RequestDTO save(RequestDTO requestDTO);
    RequestDTO saves(RequestDTO request);
    RequestDTO cancelar(Long id);
}
