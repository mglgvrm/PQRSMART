package Proyecto.PQRSMART.Domain.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.DefaultResourceLoader;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class GeoBoundaryServiceTest {
    private final GeoBoundaryService boundaryService = new GeoBoundaryService(
            new DefaultResourceLoader(),
            new ObjectMapper(),
            "classpath:geo/test-boundary.geojson"
    );

    @Test
    void acceptsPointsInsidePolygonAndRejectsOutsideAndHole() {
        assertTrue(boundaryService.contains(0.2, 0.2));
        assertFalse(boundaryService.contains(1.2, 0.2));
        assertFalse(boundaryService.contains(0.5, 0.5));
    }

    @Test
    void recognizesPolygonGeoJsonAsAvailable() {
        assertTrue(boundaryService.isAvailable());
    }

    @Test
    void loadsOfficialVillanuevaBoundaryAndSamplesInteriorCoordinates() {
        GeoBoundaryService officialBoundary = new GeoBoundaryService(
                new DefaultResourceLoader(),
                new ObjectMapper(),
                "classpath:geo/villanueva-bolivar.geojson"
        );

        assertTrue(officialBoundary.isAvailable());
        assertTrue(officialBoundary.contains(10.4444, -75.2730));
        var points = officialBoundary.findInteriorSamplePoints(4);
        assertTrue(points.stream().allMatch(point ->
                officialBoundary.contains(point.latitude(), point.longitude())
        ));
    }
}
