package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Domain.Dto.HeatmapCellDTO;
import Proyecto.PQRSMART.Domain.Dto.HeatmapResponseDTO;
import Proyecto.PQRSMART.Domain.Dto.HeatmapZoneDetailsDTO;
import Proyecto.PQRSMART.Domain.Dto.HeatmapZoneRequestDTO;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestTypeRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class GeoAnalyticsService {
    // Tamaño de celda compartido con el modelo y los índices calculados en Flutter.
    private static final double GRID_DEGREES = 0.01;

    private final RequestRepository requestRepository;
    private final RequestTypeRepository requestTypeRepository;
    private final GeoBoundaryService geoBoundaryService;

    public GeoAnalyticsService(
            RequestRepository requestRepository,
            RequestTypeRepository requestTypeRepository,
            GeoBoundaryService geoBoundaryService
    ) {
        this.requestRepository = requestRepository;
        this.requestTypeRepository = requestTypeRepository;
        this.geoBoundaryService = geoBoundaryService;
    }

    public HeatmapResponseDTO getHeatmap(
            LocalDate fromDate,
            LocalDate toDate,
            Long requestTypeId,
            Long requestStateId
    ) {
        // Valida el rango, filtra solicitudes y agrupa puntos dentro del límite municipal.
        if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
            throw new IllegalArgumentException("La fecha inicial debe ser anterior a la final.");
        }
        if (!geoBoundaryService.isAvailable()) {
            return HeatmapResponseDTO.builder()
                    .boundaryAvailable(false)
                    .message("El mapa de calor estará disponible cuando se instale "
                            + "el GeoJSON oficial del municipio.")
                    .period(period(fromDate, toDate))
                    .totalRequests(0)
                    .gridCellSizeDegrees(GRID_DEGREES)
                    .cells(List.of())
                    .build();
        }

        List<Request> requests = filteredRequests(
                fromDate,
                toDate,
                requestTypeId,
                requestStateId
        );

        // Con "todos los tipos" completa el catálogo real, incluso con conteo cero.
        Map<String, Long> typeDistribution = withKnownRequestTypes(
                distribution(
                        requests,
                        request -> request.getRequestType() == null
                                ? "Sin tipo"
                                : request.getRequestType().getNameRequestType()
                ),
                requestTypeId == null
        );

        // Agrupa por índices enteros para que detalle y raster identifiquen la misma celda.
        Map<CellKey, List<Request>> grouped = new HashMap<>();
        for (Request request : requests) {
            int latitudeIndex = (int) Math.floor(request.getLatitude() / GRID_DEGREES);
            int longitudeIndex = (int) Math.floor(request.getLongitude() / GRID_DEGREES);
            grouped.computeIfAbsent(
                    new CellKey(latitudeIndex, longitudeIndex),
                    ignored -> new ArrayList<>()
            ).add(request);
        }

        List<HeatmapCellDTO> cells = grouped.entrySet().stream()
                .map(entry -> toCell(
                        entry.getKey(),
                        entry.getValue(),
                        requestTypeId == null
                ))
                .sorted(Comparator.comparingLong(HeatmapCellDTO::getCount).reversed())
                .toList();

        return HeatmapResponseDTO.builder()
                .boundaryAvailable(true)
                .message(cells.isEmpty()
                        ? "No hay solicitudes georreferenciadas para los filtros seleccionados."
                        : null)
                .period(period(fromDate, toDate))
                .totalRequests(requests.size())
                .gridCellSizeDegrees(GRID_DEGREES)
                .typeDistribution(typeDistribution)
                .cells(cells)
                .build();
    }

    public HeatmapZoneDetailsDTO getHeatmapZoneDetails(
            LocalDate fromDate,
            LocalDate toDate,
            Long requestTypeId,
            Long requestStateId,
            int latitudeIndex,
            int longitudeIndex
    ) {
        // Reaplica filtros y selecciona solo las solicitudes de los índices elegidos.
        if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
            throw new IllegalArgumentException("La fecha inicial debe ser anterior a la final.");
        }

        List<Request> zoneRequests = filteredRequests(
                fromDate,
                toDate,
                requestTypeId,
                requestStateId
        ).stream()
                .filter(request -> latitudeIndex(request.getLatitude()) == latitudeIndex
                        && longitudeIndex(request.getLongitude()) == longitudeIndex)
                .toList();

        return HeatmapZoneDetailsDTO.builder()
                .latitudeIndex(latitudeIndex)
                .longitudeIndex(longitudeIndex)
                .totalRequests(zoneRequests.size())
                .typeDistribution(withKnownRequestTypes(
                        distribution(
                                zoneRequests,
                                request -> request.getRequestType() == null
                                        ? "Sin tipo"
                                        : request.getRequestType().getNameRequestType()
                        ),
                        requestTypeId == null
                ))
                .categoryDistribution(distribution(
                        zoneRequests,
                        request -> request.getCategory() == null
                                ? "Sin categoría"
                                : request.getCategory().getNameCategory()
                ))
                .dependenceDistribution(distribution(
                        zoneRequests,
                        this::dependenceName
                ))
                .statusDistribution(distribution(
                        zoneRequests,
                        request -> request.getRequestState() == null
                                ? "Sin estado"
                                : request.getRequestState().getNameRequestState()
                ))
                .requests(zoneRequests.stream()
                        .sorted(Comparator.comparing(
                                Request::getDate,
                                Comparator.nullsLast(Comparator.reverseOrder())
                        ))
                        .map(this::toZoneRequest)
                        .toList())
                .build();
    }

    private List<Request> filteredRequests(
            LocalDate fromDate,
            LocalDate toDate,
            Long requestTypeId,
            Long requestStateId
    ) {
        // La consulta de repositorio aplica filtros; aquí se excluyen coordenadas nulas
        // y puntos que no pertenecen al GeoJSON municipal oficial.
        if (!geoBoundaryService.isAvailable()) {
            return List.of();
        }
        return requestRepository.findGeolocatedForHeatmap(
                        fromDate,
                        toDate,
                        requestTypeId,
                        requestStateId,
                        fromDate != null,
                        toDate != null,
                        requestTypeId != null,
                        requestStateId != null
                ).stream()
                .filter(request -> request.getLatitude() != null
                        && request.getLongitude() != null)
                .filter(request -> geoBoundaryService.contains(
                        request.getLatitude(), request.getLongitude()
                ))
                .toList();
    }

    private HeatmapCellDTO toCell(
            CellKey key,
            List<Request> requests,
            boolean includeAllRequestTypes
    ) {
        // Prepara conteos por tipo, categoría, dependencia y estado para una celda.
        Map<String, Long> typeCounts = withKnownRequestTypes(
                distribution(
                        requests,
                        request -> request.getRequestType() == null
                                ? "Sin tipo"
                                : request.getRequestType().getNameRequestType()
                ),
                includeAllRequestTypes
        );
        String mostFrequentType = typeCounts.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("Sin tipo");

        return HeatmapCellDTO.builder()
                .latitudeIndex(key.latitudeIndex)
                .longitudeIndex(key.longitudeIndex)
                .latitude(center(key.latitudeIndex))
                .longitude(center(key.longitudeIndex))
                .count(requests.size())
                .mostFrequentType(mostFrequentType)
                .statusDistribution(distribution(
                        requests,
                        request -> request.getRequestState() == null
                                ? "Sin estado"
                                : request.getRequestState().getNameRequestState()
                ))
                .typeDistribution(typeCounts)
                .categoryDistribution(distribution(
                        requests,
                        request -> request.getCategory() == null
                                ? "Sin categoría"
                                : request.getCategory().getNameCategory()
                ))
                .dependenceDistribution(distribution(
                        requests,
                        this::dependenceName
                ))
                .build();
    }

    private <T> Map<String, Long> distribution(
            List<Request> requests,
            java.util.function.Function<Request, String> name
    ) {
        // Cuenta valores dinámicos y ordena el resultado por cantidad y nombre.
        Map<String, Long> counts = new HashMap<>();
        for (Request request : requests) {
            String value = name.apply(request);
            counts.merge(value == null || value.isBlank() ? "Sin dato" : value, 1L, Long::sum);
        }
        Map<String, Long> ordered = new LinkedHashMap<>();
        counts.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed()
                        .thenComparing(Map.Entry.comparingByKey()))
                .forEach(entry -> ordered.put(entry.getKey(), entry.getValue()));
        return ordered;
    }

    private Map<String, Long> withKnownRequestTypes(
            Map<String, Long> counts,
            boolean includeAllRequestTypes
    ) {
        // Lee los nombres desde el catálogo de tipos, sin listas fijas en el código.
        if (!includeAllRequestTypes) {
            return counts;
        }
        Map<String, Long> completeCounts = new HashMap<>(counts);
        requestTypeRepository.findAll().stream()
                .map(type -> type.getNameRequestType())
                .filter(name -> name != null && !name.isBlank())
                .forEach(name -> completeCounts.putIfAbsent(name, 0L));
        Map<String, Long> ordered = new LinkedHashMap<>();
        completeCounts.entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed()
                        .thenComparing(Map.Entry.comparingByKey()))
                .forEach(entry -> ordered.put(entry.getKey(), entry.getValue()));
        return ordered;
    }

    private HeatmapZoneRequestDTO toZoneRequest(Request request) {
        // Limita la respuesta de zona a los campos de solicitud usados en la interfaz.
        return HeatmapZoneRequestDTO.builder()
                .idRequest(request.getIdRequest())
                .radicado(request.getRadicado())
                .requestType(request.getRequestType() == null
                        ? "Sin tipo"
                        : request.getRequestType().getNameRequestType())
                .category(request.getCategory() == null
                        ? "Sin categoría"
                        : request.getCategory().getNameCategory())
                .dependence(dependenceName(request))
                .date(request.getDate())
                .state(request.getRequestState() == null
                        ? "Sin estado"
                        : request.getRequestState().getNameRequestState())
                .description(request.getDescription())
                .answer(request.getAnswer())
                .build();
    }

    private String dependenceName(Request request) {
        // Prefiere la dependencia relacionada con la categoría y usa la de la solicitud
        // como alternativa cuando esa relación no está disponible.
        if (request.getCategory() != null
                && request.getCategory().getDependence() != null) {
            return request.getCategory().getDependence().getNameDependence();
        }
        return request.getDependence() == null
                ? "Sin dependencia"
                : request.getDependence().getNameDependence();
    }

    private int latitudeIndex(double latitude) {
        // floor también conserva la misma asignación para coordenadas negativas.
        return (int) Math.floor(latitude / GRID_DEGREES);
    }

    private int longitudeIndex(double longitude) {
        return (int) Math.floor(longitude / GRID_DEGREES);
    }

    private double center(int index) {
        return (index + 0.5) * GRID_DEGREES;
    }

    private String period(LocalDate fromDate, LocalDate toDate) {
        if (fromDate == null && toDate == null) {
            return "Todas las fechas";
        }
        return (fromDate == null ? "Inicio" : fromDate)
                + " - "
                + (toDate == null ? "Actualidad" : toDate);
    }

    private record CellKey(int latitudeIndex, int longitudeIndex) {
    }
}
