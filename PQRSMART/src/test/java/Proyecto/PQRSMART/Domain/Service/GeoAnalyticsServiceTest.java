package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Repository.RequestTypeRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.DefaultResourceLoader;

import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyDouble;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

// Pruebas del filtrado geográfico, la cuadrícula, los desgloses y los datos nulos.
class GeoAnalyticsServiceTest {
    private RequestRepository requestRepository;
    private RequestTypeRepository requestTypeRepository;
    private GeoBoundaryService boundaryService;
    private GeoAnalyticsService service;

    @BeforeEach
    void setUp() {
        requestRepository = mock(RequestRepository.class);
        requestTypeRepository = mock(RequestTypeRepository.class);
        boundaryService = mock(GeoBoundaryService.class);
        service = new GeoAnalyticsService(
                requestRepository,
                requestTypeRepository,
                boundaryService
        );
    }

    @Test
    void doesNotReturnHeatmapDataUntilOfficialBoundaryIsInstalled() {
        boundaryService = new GeoBoundaryService(
                new DefaultResourceLoader(),
                new ObjectMapper(),
                "classpath:geo/not-installed.geojson"
        );
        service = new GeoAnalyticsService(
                requestRepository,
                requestTypeRepository,
                boundaryService
        );

        var result = service.getHeatmap(null, null, null, null);

        assertFalse(result.isBoundaryAvailable());
        assertTrue(result.getCells().isEmpty());
        verifyNoInteractions(requestRepository);
    }

    @Test
    void heatmapCellsExposeDynamicTypeCategoryAndResponsibleDependenceCounts() {
        when(boundaryService.isAvailable()).thenReturn(true);
        when(boundaryService.contains(anyDouble(), anyDouble())).thenReturn(true);
        when(requestTypeRepository.findAll()).thenReturn(List.of(
                Proyecto.PQRSMART.Persistence.Entity.RequestType.builder()
                        .nameRequestType("Sugerencia")
                        .build()
        ));
        when(requestRepository.findGeolocatedForHeatmap(
                null, null, null, null, false, false, false, false
        )).thenReturn(List.of(
                request(1L, 10.123, -75.123, "Queja", "Alumbrado",
                        "Secretaría nueva", "Pendiente"),
                request(2L, 10.124, -75.124, "Petición", "Vía",
                        "Secretaría de Obras", "Pendiente"),
                request(3L, 10.125, -75.125, "Queja", "Alumbrado",
                        "Secretaría nueva", "Finalizado")
        ));

        var result = service.getHeatmap(null, null, null, null);

        assertEquals(0.01, result.getGridCellSizeDegrees());
        assertEquals(3, result.getTotalRequests());
        var cell = result.getCells().get(0);
        assertEquals(1012, cell.getLatitudeIndex());
        assertEquals(-7513, cell.getLongitudeIndex());
        assertEquals(3, cell.getCount());
        assertEquals(2L, cell.getTypeDistribution().get("Queja"));
        assertEquals(0L, cell.getTypeDistribution().get("Sugerencia"));
        assertEquals(0L, result.getTypeDistribution().get("Sugerencia"));
        assertEquals(2L, cell.getCategoryDistribution().get("Alumbrado"));
        assertEquals(2L, cell.getDependenceDistribution().get("Secretaría nueva"));
        assertEquals(2L, cell.getStatusDistribution().get("Pendiente"));
    }

    @Test
    void zoneDetailsApplyAllFiltersAndOnlyReturnRequestsFromTheSelectedCell() {
        LocalDate from = LocalDate.of(2026, 1, 1);
        LocalDate to = LocalDate.of(2026, 1, 31);
        when(boundaryService.isAvailable()).thenReturn(true);
        when(boundaryService.contains(anyDouble(), anyDouble())).thenReturn(true);
        when(requestRepository.findGeolocatedForHeatmap(
                eq(from), eq(to), eq(7L), eq(3L), eq(true), eq(true), eq(true), eq(true)
        )).thenReturn(List.of(
                request(7L, 10.123, -75.123, "Queja", "Alumbrado",
                        "Secretaría nueva", "Pendiente"),
                request(8L, 10.133, -75.123, "Queja", "Alumbrado",
                        "Secretaría nueva", "Pendiente"),
                request(9L, 10.124, -75.124, "Queja", "Alumbrado",
                        "Secretaría nueva", "Pendiente")
        ));

        var result = service.getHeatmapZoneDetails(from, to, 7L, 3L, 1012, -7513);

        assertEquals(2, result.getTotalRequests());
        assertEquals(List.of("PQR-7", "PQR-9"), result.getRequests().stream()
                .map(item -> item.getRadicado()).sorted().toList());
        assertEquals(2L, result.getDependenceDistribution().get("Secretaría nueva"));
        verify(requestRepository).findGeolocatedForHeatmap(
                from, to, 7L, 3L, true, true, true, true
        );
    }

    @Test
    void nullCoordinatesAreExcludedWithoutFailingTheHeatmap() {
        when(boundaryService.isAvailable()).thenReturn(true);
        when(boundaryService.contains(anyDouble(), anyDouble())).thenReturn(true);
        when(requestRepository.findGeolocatedForHeatmap(
                null, null, null, null, false, false, false, false
        )).thenReturn(List.of(
                request(1L, null, null, "Queja", "Alumbrado",
                        "Secretaría nueva", "Pendiente")
        ));

        var result = service.getHeatmap(null, null, null, null);

        assertEquals(0, result.getTotalRequests());
        assertTrue(result.getCells().isEmpty());
        verify(boundaryService, never()).contains(anyDouble(), anyDouble());
    }

    @Test
    void zoneWithNoMatchingRequestsReturnsEmptyPrivacySafeBreakdowns() {
        when(boundaryService.isAvailable()).thenReturn(true);
        when(boundaryService.contains(anyDouble(), anyDouble())).thenReturn(true);
        when(requestRepository.findGeolocatedForHeatmap(
                null, null, null, null, false, false, false, false
        )).thenReturn(List.of(
                request(1L, 10.123, -75.123, "Queja", "Alumbrado",
                        "Secretaría nueva", "Pendiente")
        ));

        var result = service.getHeatmapZoneDetails(null, null, null, null, 999, 999);

        assertEquals(0, result.getTotalRequests());
        assertTrue(result.getRequests().isEmpty());
        assertTrue(result.getTypeDistribution().isEmpty());
        assertTrue(result.getDependenceDistribution().isEmpty());
    }

    @Test
    void nullCategoryAndDependenceAreRepresentedWithoutFailing() {
        when(boundaryService.isAvailable()).thenReturn(true);
        when(boundaryService.contains(anyDouble(), anyDouble())).thenReturn(true);
        var requestWithoutCatalogRelations = Proyecto.PQRSMART.Persistence.Entity.Request.builder()
                .idRequest(2L)
                .latitude(10.123)
                .longitude(-75.123)
                .requestType(null)
                .category(null)
                .requestState(null)
                .build();
        when(requestRepository.findGeolocatedForHeatmap(
                null, null, null, null, false, false, false, false
        )).thenReturn(List.of(requestWithoutCatalogRelations));

        var result = service.getHeatmap(null, null, null, null);

        assertEquals(1, result.getTotalRequests());
        assertEquals(1L, result.getCells().get(0).getCategoryDistribution().get("Sin categoría"));
        assertEquals(1L, result.getCells().get(0).getDependenceDistribution().get("Sin dependencia"));
        assertEquals(1L, result.getCells().get(0).getTypeDistribution().get("Sin tipo"));
    }

    private Request request(
            Long id,
            Double latitude,
            Double longitude,
            String type,
            String category,
            String dependence,
            String state
    ) {
        var responsibleDependence = Proyecto.PQRSMART.Persistence.Entity.Dependence.builder()
                .nameDependence(dependence)
                .build();
        var requestCategory = Proyecto.PQRSMART.Persistence.Entity.Category.builder()
                .nameCategory(category)
                .dependence(responsibleDependence)
                .build();
        return Proyecto.PQRSMART.Persistence.Entity.Request.builder()
                .idRequest(id)
                .radicado("PQR-" + id)
                .latitude(latitude)
                .longitude(longitude)
                .date(LocalDate.of(2026, 1, 10))
                .description("Descripción no personal")
                .requestType(Proyecto.PQRSMART.Persistence.Entity.RequestType.builder()
                        .nameRequestType(type)
                        .build())
                .category(requestCategory)
                .requestState(Proyecto.PQRSMART.Persistence.Entity.RequestState.builder()
                        .nameRequestState(state)
                        .build())
                .build();
    }
}
