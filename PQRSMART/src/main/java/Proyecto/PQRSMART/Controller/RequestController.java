package Proyecto.PQRSMART.Controller;


import Proyecto.PQRSMART.Domain.Dto.AIAnalysisResponse;
import Proyecto.PQRSMART.Domain.Dto.HeatmapResponseDTO;
import Proyecto.PQRSMART.Domain.Dto.HeatmapZoneDetailsDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestStateUpdateDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestStateDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestStateHistoryDTO;
import Proyecto.PQRSMART.Domain.Dto.UsuarioDto;
import Proyecto.PQRSMART.Domain.Mapper.RequestMapper;
import Proyecto.PQRSMART.Domain.Mapper.UsuarioMapper;
import Proyecto.PQRSMART.Domain.Service.EmailServiceImpl;
import Proyecto.PQRSMART.Domain.Service.GeoAnalyticsService;
import Proyecto.PQRSMART.Domain.Service.GeoBoundaryService;
import Proyecto.PQRSMART.Domain.Service.GeoBoundaryUnavailableException;
import Proyecto.PQRSMART.Domain.Service.Interfaces.PdfServices;
import Proyecto.PQRSMART.Domain.Service.Interfaces.RequestServices;
import Proyecto.PQRSMART.Domain.Service.Interfaces.RequestStateService;
import Proyecto.PQRSMART.Domain.Service.MCPRequestAnalysisService;
import Proyecto.PQRSMART.Domain.Service.RequestServicesImpl;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Entity.RequestLocationSource;
import Proyecto.PQRSMART.Persistence.Entity.RequestState;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.format.annotation.DateTimeFormat;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.NoSuchElementException;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/request")
public class RequestController {
    private static final Logger LOGGER = LoggerFactory.getLogger(RequestController.class);

    @Autowired
    private RequestServices requestServices;
    @Autowired
    private RequestRepository requestRepository;
    @Autowired
    private UsuarioRepository userRepository;
    @Autowired
    private RequestStateService requestStateService;
    @Autowired
    private GeoBoundaryService geoBoundaryService;
    @Autowired
    private GeoAnalyticsService geoAnalyticsService;

    private final MCPRequestAnalysisService mcpRequestAnalysisService;

    @Autowired
    private PdfServices pdfServices;

    private final EmailServiceImpl emailService;

    //private final Path fileStorageLocation = Paths.get("files").toAbsolutePath().normalize();
    // Ruta para guardar archivos
    @Value("${file.upload-dir:/var/data/uploads}")
    private String uploadDir;

    @PostMapping("/save")
    public ResponseEntity<String> saveRequest(@RequestBody RequestDTO request) {
        try {
            validateLocation(request, false);

            // Obtenemos el usuario autenticado
            UserDetails userDetails = (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
            // Buscamos el usuario en la base de datos

            User user = userRepository.findByUser(userDetails.getUsername());

            if (user == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Usuario no encontrado");
            }

            if (request.getRequestType() == null
                    || request.getRequestType().getIdRequestType() == null
                    || request.getCategory() == null
                    || request.getCategory().getIdCategory() == null
                    || request.getDependence() == null
                    || request.getDependence().getIdDependence() == null
                    || request.getRequestState() == null
                    || request.getRequestState().getIdRequestState() == null) {
                return ResponseEntity.badRequest()
                        .body("Tipo, categoría, dependencia y estado son obligatorios.");
            }

            // Creamos la solicitud
            request.setUser(UsuarioMapper.toDto(user));

            Request catalogs = requestServices.findEntityByIds(request);
            if (catalogs.getCategory().getDependence() == null
                    || !Objects.equals(
                            catalogs.getCategory().getDependence().getIdDependence(),
                            catalogs.getDependence().getIdDependence()
                    )) {
                return ResponseEntity.badRequest()
                        .body("La categoría seleccionada no pertenece a la dependencia elegida.");
            }

            Request requestEntity =
                    RequestMapper.toEntity(request);

            requestEntity.setIdRequest(null);
            requestEntity.setRadicado(null);
            requestEntity.setUser(user);
            requestEntity.setRequestType(catalogs.getRequestType());
            requestEntity.setCategory(catalogs.getCategory());
            requestEntity.setDependence(catalogs.getDependence());
            requestEntity.setRequestState(catalogs.getRequestState());

            AIAnalysisResponse aiResponse =
                    mcpRequestAnalysisService.analyze(requestEntity);

            if (!Boolean.TRUE.equals(aiResponse.getValid())) {
                return ResponseEntity
                        .status(HttpStatus.BAD_REQUEST)
                        .body(aiResponse.getReason());
            }
            User assignedUser =
                    userRepository.findById(
                            aiResponse.getAssignedUserId()
                    ).orElseThrow(() ->
                            new RuntimeException(
                                    "Usuario asignado no encontrado"
                            )
                    );
            // 7. ASIGNAR DATOS IA
            // ============================

            requestEntity.setPriority(
                    aiResponse.getPriority()
            );

            requestEntity.setAiCoherence(
                    aiResponse.getCoherence()
            );

            requestEntity.setRelevance(
                    aiResponse.getRelevance()
            );

            requestEntity.setRejectReason(
                    aiResponse.getReason()
            );

            requestEntity.setAssignedUser(
                    assignedUser
            );

            // Guardar solicitud usando el servicio
            RequestDTO savedRequest = requestServices.saves(RequestMapper.toDTO(requestEntity));
            Optional<Request> searchRequest = requestServices.findEntityById(savedRequest.getIdRequest());

            Request requestAll;
            String requestJson;
            if (searchRequest.isPresent()) {
                // Convertir la solicitud guardada a JSON y devolverla
                ObjectMapper mapper = new ObjectMapper();
                mapper.registerModule(new JavaTimeModule());
                requestAll = searchRequest.get();
                requestAll.setUser(user);
                System.out.println("empieza " + requestAll);
                requestJson = mapper.writeValueAsString(requestAll);


            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Solicitud no encontrada");
            }

            byte[] pdf = pdfServices.generarPdfSolicitud(user, requestAll);

            System.out.println("archivo url: " + request.getArchivo());

            try {
                emailService.sendEmailWithPdf(
                        user.getEmail(),
                        "Detalle de Solicitud",
                        "Adjunto encontrarás el PDF con los detalles.",
                        pdf,
                        request.getArchivo()
                );
            } catch (RuntimeException emailException) {
                LOGGER.warn(
                        "La solicitud {} fue guardada, pero no se pudo enviar su correo de confirmación.",
                        savedRequest.getRadicado(),
                        emailException
                );
            }


            // 7️⃣ Devolver objeto directamente (Spring lo convierte a JSON)
            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(requestJson);

        } catch (GeoBoundaryUnavailableException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {

            e.printStackTrace();

            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error interno: " + e.getMessage());
        }
    }

    @PostMapping("/save/assisted")
    public ResponseEntity<?> saveAssistedRequest(@RequestBody RequestDTO request) {
        try {
            UserDetails userDetails = (UserDetails) SecurityContextHolder
                    .getContext().getAuthentication().getPrincipal();
            User registrar = userRepository.findByUser(userDetails.getUsername());
            if (registrar == null) {
                return ResponseEntity.badRequest().body("Funcionario autenticado no encontrado.");
            }

            validateLocation(request, true);
            RequestDTO saved = requestServices.saveAssisted(request, registrar);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (GeoBoundaryUnavailableException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(e.getMessage());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("No fue posible registrar la solicitud asistida.");
        }
    }

    @GetMapping(value = "/geo/municipality", produces = "application/geo+json")
    // Entrega el GeoJSON municipal que consumen los mapas del frontend.
    public ResponseEntity<?> getMunicipalityBoundary() {
        try {
            return ResponseEntity.ok(geoBoundaryService.getGeoJson());
        } catch (GeoBoundaryUnavailableException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(e.getMessage());
        }
    }

    // Devuelve conteos y celdas aplicando filtros opcionales de fecha, tipo y estado.
    @GetMapping("/geo/heatmap")
    public ResponseEntity<?> getHeatmap(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) Long requestTypeId,
            @RequestParam(required = false) Long requestStateId
    ) {
        try {
            HeatmapResponseDTO result =
                    geoAnalyticsService.getHeatmap(from, to, requestTypeId, requestStateId);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // Devuelve desgloses y solicitudes asociadas a los índices de la celda seleccionada.
    @GetMapping("/geo/heatmap/cell")
    public ResponseEntity<?> getHeatmapCellDetails(
            @RequestParam int latitudeIndex,
            @RequestParam int longitudeIndex,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
            @RequestParam(required = false) Long requestTypeId,
            @RequestParam(required = false) Long requestStateId
    ) {
        try {
            HeatmapZoneDetailsDTO result = geoAnalyticsService.getHeatmapZoneDetails(
                    from,
                    to,
                    requestTypeId,
                    requestStateId,
                    latitudeIndex,
                    longitudeIndex
            );
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    private void validateLocation(RequestDTO request, boolean assisted) {
        Double latitude = request.getLatitude();
        Double longitude = request.getLongitude();
        if (latitude == null && longitude == null) {
            request.setLocationSource(null);
            request.setLocationMethod(null);
            request.setLocationCapturedAt(null);
            return;
        }
        if (latitude == null || longitude == null
                || !Double.isFinite(latitude) || !Double.isFinite(longitude)
                || latitude < -90 || latitude > 90
                || longitude < -180 || longitude > 180) {
            throw new IllegalArgumentException("La latitud y longitud deben ser válidas.");
        }

        if (assisted) {
            if (request.getLocationMethod() == null) {
                throw new IllegalArgumentException(
                        "Selecciona si la ubicación se obtuvo por GPS o manualmente."
                );
            }
            request.setLocationSource(RequestLocationSource.FUNCIONARIO);
        } else {
            if (request.getLocationSource() == null
                    || request.getLocationSource() == RequestLocationSource.FUNCIONARIO
                    || request.getLocationMethod() == null
                    || !request.getLocationSource().name()
                    .equals(request.getLocationMethod().name())) {
                throw new IllegalArgumentException(
                        "La ubicación ciudadana debe indicar GPS o selección manual."
                );
            }
        }

        if (!geoBoundaryService.contains(latitude, longitude)) {
            throw new IllegalArgumentException(
                    "La ubicación seleccionada está fuera del municipio de Villanueva, Bolívar."
            );
        }
        if (request.getLocationCapturedAt() == null) {
            request.setLocationCapturedAt(Instant.now());
        }
    }

    @GetMapping("/get")
    public List<RequestDTO> get() {

        return requestServices.getAll();
    }

    @GetMapping("/getForDependence")
    public List<RequestDTO> getForDependence() {

        return requestServices.getForDependence();
    }

    @GetMapping("/get/pqrs")
    public List<RequestDTO> getPqrs() {
        // Obtenemos el usuario autenticado
        UserDetails userDetails = (UserDetails) SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        return requestServices.getPqrs(userDetails.getUsername());
    }

    @GetMapping("/{id}/history")
    public ResponseEntity<?> getRequestStateHistory(@PathVariable Long id) {
        Optional<Request> request = requestServices.findEntityById(id);
        if (request.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        UserDetails details = (UserDetails) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();
        User viewer = userRepository.findByUser(details.getUsername());
        if (!canViewRequestHistory(viewer, request.get())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("No tienes permiso para consultar el historial de esta solicitud.");
        }
        List<RequestStateHistoryDTO> history = requestServices.getStateHistory(id);
        return ResponseEntity.ok(history);
    }

    private boolean canViewRequestHistory(User viewer, Request request) {
        if (viewer == null || viewer.getRole() == null) return false;
        if (viewer.getRole() == Proyecto.PQRSMART.Persistence.Entity.Role.ADMIN) return true;
        if (viewer.getRole() == Proyecto.PQRSMART.Persistence.Entity.Role.USER) {
            return request.getUser() != null
                    && Objects.equals(viewer.getId(), request.getUser().getId());
        }
        return viewer.getRole() == Proyecto.PQRSMART.Persistence.Entity.Role.SECRE
                && viewer.getDependence() != null
                && request.getDependence() != null
                && Objects.equals(
                        viewer.getDependence().getIdDependence(),
                        request.getDependence().getIdDependence()
                );
    }


    @PutMapping("/cancel/{id}")
    public ResponseEntity<?> cancelarSolicitud(@PathVariable Long id) {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof UserDetails details)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        User viewer = userRepository.findByUser(details.getUsername());
        Optional<Request> request = requestServices.findEntityById(id);
        if (request.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        boolean isAdministrator = viewer != null
                && viewer.getRole() == Proyecto.PQRSMART.Persistence.Entity.Role.ADMIN;
        boolean isOwner = viewer != null
                && viewer.getRole() == Proyecto.PQRSMART.Persistence.Entity.Role.USER
                && request.get().getUser() != null
                && Objects.equals(viewer.getId(), request.get().getUser().getId());
        if (!isAdministrator && !isOwner) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("No tienes permiso para cancelar esta solicitud.");
        }

        return ResponseEntity.ok(requestServices.cancelar(id));
    }

    @PutMapping(value = "/update/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @RequestBody RequestDTO requestDTO) throws IOException {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof UserDetails details)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        User viewer = userRepository.findByUser(details.getUsername());
        Optional<RequestDTO> requestDTOOptional = requestServices.findById(id);
        if (requestDTOOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        RequestDTO existingRequest = requestDTOOptional.get();
        if (viewer == null
                || viewer.getRole() != Proyecto.PQRSMART.Persistence.Entity.Role.SECRE
                || viewer.getDependence() == null
                || existingRequest.getDependence() == null
                || !Objects.equals(
                        viewer.getDependence().getIdDependence(),
                        existingRequest.getDependence().getIdDependence()
                )) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("No tienes permiso para gestionar esta solicitud.");
        }

        existingRequest.setAnswer(requestDTO.getAnswer());
        return ResponseEntity.ok(requestServices.save(existingRequest));
    }

    @PatchMapping("/{id}/state")
    public ResponseEntity<?> updateState(
            @PathVariable Long id,
            @RequestBody RequestStateUpdateDTO update
    ) {
        try {
            if (update == null || update.getIdRequestState() == null) {
                return ResponseEntity.badRequest().body("El estado es obligatorio.");
            }
            return ResponseEntity.ok(requestServices.updateStateForSecretary(
                    id,
                    update.getIdRequestState(),
                    update.getObservation()
            ));
        } catch (AccessDeniedException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(e.getMessage());
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }


    @GetMapping("/report/{year}/{month}")
    public ResponseEntity<byte[]> generateReport(
            @PathVariable int year,
            @PathVariable int month) throws Exception {

        List<Request> pqrs = requestServices.getByMonth(year, month);

        byte[] pdf = requestServices.generateReport(pqrs, year);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentDisposition(
                ContentDisposition.attachment()
                        .filename("reporte_pqrs.pdf")
                        .build()
        );

        return new ResponseEntity<>(pdf, headers, HttpStatus.OK);
    }
}