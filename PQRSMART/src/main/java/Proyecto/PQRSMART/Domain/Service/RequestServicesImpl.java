package Proyecto.PQRSMART.Domain.Service;


import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Domain.Mapper.RequestMapper;
import Proyecto.PQRSMART.Domain.Service.Interfaces.RequestServices;
import Proyecto.PQRSMART.Persistence.Entity.*;
import Proyecto.PQRSMART.Persistence.Repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class RequestServicesImpl implements RequestServices {
    @Autowired
    private RequestRepository requestRepository;

    @Autowired
    private UsuarioRepository userRepository;

    @Autowired
    private RequestStateRepository requestStateRepository;

    @Autowired
    private RequestTypeRepository requestTypeRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private DependenceRepository dependenceRepository;



    public List<RequestDTO> getAll() {
        return requestRepository.findAll().stream().map(RequestMapper::toDTO).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<RequestDTO> getPqrs(String usurious) {

        return requestRepository.findByUserUser(usurious)
                .stream()
                .map(RequestMapper::toDTO)
                .collect(Collectors.toList());
    }

    public Optional<RequestDTO> findById(Long id) {
        return requestRepository.findById(id).map(RequestMapper::toDTO);
    }

    public Optional<Request> findEntityById(Long id) {
        return requestRepository.findById(id);
    }

    public Request findEntityByIds(RequestDTO dto) {



        RequestType requestType = requestTypeRepository
                .findById(dto.getRequestType().getIdRequestType())
                .orElseThrow(() -> new RuntimeException("Tipo de solicitud no encontrado"));

        Category category = categoryRepository
                .findById(dto.getCategory().getIdCategory())
                .orElseThrow(() -> new RuntimeException("Categoría no encontrada"));

        Dependence dependence = dependenceRepository
                .findById(dto.getDependence().getIdDependence())
                .orElseThrow(() -> new RuntimeException("Dependencia no encontrada"));

        User user = userRepository
                .findById(dto.getUser().getId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        RequestState requestState = requestStateRepository
                .findById(dto.getRequestState().getIdRequestState())
                .orElseThrow(() -> new RuntimeException("Estado no encontrado"));

        return Request.builder()


                .requestType(requestType)
                .category(category)
                .dependence(dependence)

                .requestState(requestState)

                .build();
    }
    public void update(RequestDTO requestDTO) {
        Request request = RequestMapper.toEntity(requestDTO);
        requestRepository.save(request);
    }

    public RequestDTO save(RequestDTO requestDTO) {
        Optional<Request> existingRequestOptional = requestRepository.findById(requestDTO.getIdRequest());
        if (existingRequestOptional.isPresent()) {
            Request existingRequest = existingRequestOptional.get();
            // Actualizar los campos relevantes de la solicitud existente con los valores de requestDTO
            RequestState state = requestStateRepository
                    .findById(requestDTO.getRequestState().getIdRequestState())
                    .orElseThrow(() -> new RuntimeException("Estado no encontrado"));

            existingRequest.setRequestState(state);
            existingRequest.setAnswer(requestDTO.getAnswer());
            // Actualizar otros campos si es necesario
            requestRepository.save(existingRequest);
            return requestDTO;
        } else {
            // Si la solicitud no existe, guardar una nueva solicitud en la base de datos
            requestRepository.save(RequestMapper.toEntity(requestDTO));
            return requestDTO;
        }
    }

    public RequestDTO saves(RequestDTO request) {
        // Primero, guarda la solicitud sin el radicado para que se genere el ID automáticamente.
        Request savedRequest = requestRepository.save(RequestMapper.toEntity(request));

        // Ahora que el ID ya está generado, puedes asignarlo al campo 'radicado'.
        savedRequest.setRadicado(savedRequest.getIdRequest()); // Asumiendo que getIdRequest() devuelve el ID

        // Guarda nuevamente para actualizar el radicado.
        requestRepository.save(savedRequest);

        return RequestMapper.toDTO(savedRequest);
    }
    public RequestDTO cancelar(Long id) {

        Request request = requestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("No encontrado"));


        RequestState canceladoState =
                requestStateRepository.findByNameRequestState("Cancelado")
                        .orElseThrow(() -> new RuntimeException("Estado no encontrado"));

        request.setRequestState(canceladoState);

        Request saved = requestRepository.save(request);

        return RequestMapper.toDTO(saved);
    }

}