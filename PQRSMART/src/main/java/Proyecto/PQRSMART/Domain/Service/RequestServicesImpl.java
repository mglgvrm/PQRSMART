package Proyecto.PQRSMART.Domain.Service;


import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestStateHistoryDTO;
import Proyecto.PQRSMART.Domain.Mapper.RequestMapper;
import Proyecto.PQRSMART.Domain.Service.Interfaces.PdfServices;
import Proyecto.PQRSMART.Domain.Service.Interfaces.RequestServices;
import Proyecto.PQRSMART.Persistence.Entity.*;
import Proyecto.PQRSMART.Persistence.Repository.*;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.thymeleaf.context.Context;

import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.Objects;
import java.util.NoSuchElementException;
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
    private RequestStateHistoryRepository requestStateHistoryRepository;

    @Autowired
    private RequestTypeRepository requestTypeRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private DependenceRepository dependenceRepository;

    @Autowired
    private PdfServices pdfServices;



    public List<RequestDTO> getAll() {

        return requestRepository.findAll().stream().map(RequestMapper::toDTO).collect(Collectors.toList());
    }

    public List<RequestDTO> getForDependence() {
        User secretary = authenticatedSecretary();
        return requestRepository.findByDependence(secretary.getDependence())
                .stream()
                .map(RequestMapper::toDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public RequestDTO updateStateForSecretary(Long requestId, Long stateId, String observation) {
        if (requestId == null || stateId == null) {
            throw new IllegalArgumentException("La solicitud y el estado son obligatorios.");
        }

        User secretary = authenticatedSecretary();
        Request request = requestRepository.findById(requestId)
                .orElseThrow(() -> new NoSuchElementException("La solicitud no existe."));
        if (request.getDependence() == null
                || !Objects.equals(
                        secretary.getDependence().getIdDependence(),
                        request.getDependence().getIdDependence()
                )) {
            throw new AccessDeniedException("No tienes permiso para gestionar esta solicitud.");
        }

        RequestState newState = requestStateRepository.findById(stateId)
                .orElseThrow(() -> new IllegalArgumentException("El estado seleccionado no existe."));
        RequestState previousState = request.getRequestState();
        request.setRequestState(newState);
        Request saved = requestRepository.save(request);
        recordStateChange(saved, previousState, newState,
                observation == null || observation.isBlank() ? null : observation.trim());
        return RequestMapper.toDTO(saved);
    }

    private User authenticatedSecretary() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof UserDetails details)) {
            throw new AccessDeniedException("Se requiere una sesión de secretario.");
        }

        User user = userRepository.findByUser(details.getUsername());
        if (user == null
                || user.getRole() != Role.SECRE
                || user.getDependence() == null
                || user.getDependence().getIdDependence() == null
                || Long.valueOf(7L).equals(user.getDependence().getIdDependence())) {
            throw new AccessDeniedException("La cuenta de secretario no tiene una dependencia válida.");
        }
        return user;
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

    @Transactional
    public RequestDTO save(RequestDTO requestDTO) {
        Optional<Request> existingRequestOptional = requestRepository.findById(requestDTO.getIdRequest());
        if (existingRequestOptional.isPresent()) {
            Request existingRequest = existingRequestOptional.get();
            // Actualizar los campos relevantes de la solicitud existente con los valores de requestDTO
            RequestState state = requestStateRepository
                    .findByNameRequestState("Finalizado")
                    .orElseThrow(() -> new RuntimeException("Estado no encontrado"));

            RequestState previousState = existingRequest.getRequestState();
            existingRequest.setRequestState(state);

            existingRequest.setAnswer(requestDTO.getAnswer());
            if (requestDTO.getArchiveAnswer() != null && !requestDTO.getArchiveAnswer().isEmpty()) {
                existingRequest.setArchiveAnswer(requestDTO.getArchiveAnswer());
            }
            // Actualizar otros campos si es necesario
            Request saved = requestRepository.save(existingRequest);
            recordStateChange(saved, previousState, state, requestDTO.getAnswer());
            return requestDTO;
        } else {
            // Si la solicitud no existe, guardar una nueva solicitud en la base de datos
            Request saved = requestRepository.save(RequestMapper.toEntity(requestDTO));
            recordStateChange(saved, null, saved.getRequestState(), "Solicitud registrada.");
            return requestDTO;
        }
    }

    @Transactional
    public RequestDTO saves(RequestDTO request) {
        // Primero, guarda la solicitud sin el radicado para que se genere el ID automáticamente.
        Request savedRequest = requestRepository.save(RequestMapper.toEntity(request));
        // 2. Obtener el ID categoría (ajusta si tu modelo cambia)
        Long dependenceId = savedRequest.getDependence().getIdDependence();

        // 3. Generar radicado
        String radicado = generarRadicadoSecuencial(savedRequest.getIdRequest(),dependenceId );
        // Ahora que el ID ya está generado, puedes asignarlo al campo 'radicado'.
        savedRequest.setRadicado(radicado); // Asumiendo que getIdRequest() devuelve el ID

        // Guarda nuevamente para actualizar el radicado.
        requestRepository.save(savedRequest);
        recordStateChange(savedRequest, null, savedRequest.getRequestState(), "Solicitud registrada.");

        return RequestMapper.toDTO(savedRequest);
    }

    @Transactional
    public RequestDTO saveAssisted(RequestDTO dto, User registrar) {
        if (registrar.getRole() != Role.ADMIN && registrar.getRole() != Role.SECRE) {
            throw new IllegalArgumentException(
                    "Solo un administrador o secretario puede registrar solicitudes asistidas."
            );
        }
        if (dto.getCitizenName() == null || dto.getCitizenName().isBlank()) {
            throw new IllegalArgumentException("El nombre del ciudadano es obligatorio.");
        }
        if (dto.getCitizenName().trim().length() > 160
                || (dto.getCitizenEmail() != null && dto.getCitizenEmail().length() > 254)
                || (dto.getCitizenPhone() != null && dto.getCitizenPhone().length() > 40)
                || (dto.getLocationDescription() != null
                && dto.getLocationDescription().length() > 300)) {
            throw new IllegalArgumentException("Los datos del ciudadano o del lugar exceden el tamaño permitido.");
        }
        if (dto.getRequestType() == null || dto.getRequestType().getIdRequestType() == null
                || dto.getCategory() == null || dto.getCategory().getIdCategory() == null
                || dto.getDependence() == null || dto.getDependence().getIdDependence() == null
                || dto.getRequestState() == null
                || dto.getRequestState().getIdRequestState() == null) {
            throw new IllegalArgumentException(
                    "Tipo, categoría, dependencia y estado son obligatorios."
            );
        }

        RequestType requestType = requestTypeRepository
                .findById(dto.getRequestType().getIdRequestType())
                .orElseThrow(() -> new IllegalArgumentException("Tipo de solicitud no encontrado."));
        Category category = categoryRepository
                .findById(dto.getCategory().getIdCategory())
                .orElseThrow(() -> new IllegalArgumentException("Categoría no encontrada."));
        Dependence dependence = dependenceRepository
                .findById(dto.getDependence().getIdDependence())
                .orElseThrow(() -> new IllegalArgumentException("Dependencia no encontrada."));
        RequestState state = requestStateRepository
                .findById(dto.getRequestState().getIdRequestState())
                .orElseThrow(() -> new IllegalArgumentException("Estado de solicitud no encontrado."));

        if (category.getDependence() == null
                || !category.getDependence().getIdDependence().equals(dependence.getIdDependence())) {
            throw new IllegalArgumentException(
                    "La categoría seleccionada no pertenece a la dependencia indicada."
            );
        }
        if (registrar.getRole() == Role.SECRE
                && (registrar.getDependence() == null
                || !registrar.getDependence().getIdDependence().equals(dependence.getIdDependence()))) {
            throw new IllegalArgumentException(
                    "Solo puedes registrar solicitudes para tu dependencia."
            );
        }

        Request request = RequestMapper.toEntity(dto);
        request.setIdRequest(null);
        request.setRadicado(null);
        request.setAnswer(null);
        request.setArchiveAnswer(null);
        request.setUser(null);
        request.setRegisteredBy(registrar);
        request.setRequestType(requestType);
        request.setCategory(category);
        request.setDependence(dependence);
        request.setRequestState(state);
        request.setLocationSource(dto.getLatitude() == null
                ? null
                : RequestLocationSource.FUNCIONARIO);
        request.setDate(dto.getDate() == null ? LocalDate.now() : dto.getDate());
        if (request.getLatitude() != null && request.getLocationCapturedAt() == null) {
            request.setLocationCapturedAt(Instant.now());
        }

        Request saved = requestRepository.save(request);
        saved.setRadicado(generarRadicadoSecuencial(
                saved.getIdRequest(),
                requestType.getIdRequestType()
        ));
        Request persisted = requestRepository.save(saved);
        recordStateChange(
                persisted,
                null,
                persisted.getRequestState(),
                "Solicitud registrada presencialmente."
        );
        return RequestMapper.toDTO(persisted);
    }


    @Transactional
    public RequestDTO cancelar(Long id) {

        Request request = requestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("No encontrado"));


        RequestState canceladoState =
                requestStateRepository.findByNameRequestState("Cancelado")
                        .orElseThrow(() -> new RuntimeException("Estado no encontrado"));

        RequestState previousState = request.getRequestState();
        request.setRequestState(canceladoState);

        Request saved = requestRepository.save(request);
        recordStateChange(saved, previousState, canceladoState, "Solicitud cancelada.");

        return RequestMapper.toDTO(saved);
    }

    @Transactional(readOnly = true)
    public List<RequestStateHistoryDTO> getStateHistory(Long requestId) {
        return requestStateHistoryRepository
                .findByRequestIdRequestOrderByChangedAtAsc(requestId)
                .stream()
                .map(history -> RequestStateHistoryDTO.builder()
                        .previousState(history.getPreviousState() == null
                                ? null
                                : history.getPreviousState().getNameRequestState())
                        .newState(history.getNewState().getNameRequestState())
                        .changedAt(history.getChangedAt())
                        .changedBy(history.getChangedBy() == null
                                ? null
                                : history.getChangedBy().getName())
                        .observation(history.getObservation())
                        .build())
                .toList();
    }

    private void recordStateChange(
            Request request,
            RequestState previousState,
            RequestState newState,
            String observation
    ) {
        if (request == null || request.getRequestState() == null || newState == null) {
            return;
        }
        if (previousState != null
                && Objects.equals(previousState.getIdRequestState(), newState.getIdRequestState())) {
            return;
        }

        User actor = null;
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UserDetails details) {
            actor = userRepository.findByUser(details.getUsername());
        }
        requestStateHistoryRepository.save(RequestStateHistory.builder()
                .request(request)
                .previousState(previousState)
                .newState(newState)
                .changedAt(Instant.now())
                .changedBy(actor)
                .observation(observation)
                .build());
    }

    public byte[] generateReport(List<Request> pqrsDelMes, int anio) {

        return pdfServices.generateReport(pqrsDelMes, anio);
    }

    public List<Request> getByMonth(int year, int month) {

        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

        return requestRepository.findByDateBetween(startDate, endDate);
    }

    private String letraPorTipoSolicitud(Long requestTypeId) {
        return switch (requestTypeId.intValue()) {
            case 1 -> "P"; // Petición
            case 2 -> "Q"; // Queja
            case 3 -> "R"; // Reclamo
            case 4 -> "S"; // Sugerencia
            default -> "X"; // Por si llega algo diferente
        };
    }

    public String generarRadicadoSecuencial(Long id, Long requestTypeId) {

        long numero = id + 1; // SUMAR 1 AL ID
        String letra = letraPorTipoSolicitud(requestTypeId);

        return "PQRS-" + String.format("%05d", numero) + letra;
    }
}