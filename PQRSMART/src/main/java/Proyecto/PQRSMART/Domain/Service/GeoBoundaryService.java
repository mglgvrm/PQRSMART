package Proyecto.PQRSMART.Domain.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.Comparator;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

@Service
public class GeoBoundaryService {
    // Carga y valida el GeoJSON oficial; el polígono se reutiliza desde caché.
    private final Resource resource;
    private final ObjectMapper objectMapper;
    private volatile List<List<List<Coordinate>>> cachedPolygons;

    public GeoBoundaryService(
            ResourceLoader resourceLoader,
            ObjectMapper objectMapper,
            @Value("${pqrsmart.geo.municipality-resource:classpath:geo/villanueva-bolivar.geojson}")
            String boundaryLocation
    ) {
        this.resource = resourceLoader.getResource(boundaryLocation);
        this.objectMapper = objectMapper;
    }

    public boolean isAvailable() {
        if (!resource.exists()) {
            return false;
        }
        try {
            readPolygons();
            return true;
        } catch (IOException | IllegalArgumentException exception) {
            return false;
        }
    }

    public String getGeoJson() {
        if (!resource.exists()) {
            throw unavailable();
        }
        try {
            readPolygons();
            try (InputStream input = resource.getInputStream()) {
                return new String(input.readAllBytes(), java.nio.charset.StandardCharsets.UTF_8);
            }
        } catch (IOException | IllegalArgumentException exception) {
            throw new GeoBoundaryUnavailableException(
                    "El GeoJSON municipal oficial no está disponible o no es válido.",
                    exception
            );
        }
    }

    public boolean contains(double latitude, double longitude) {
        // Comprueba anillos exteriores y excluye huecos del polígono municipal.
        List<List<List<Coordinate>>> polygons;
        try {
            polygons = readPolygons();
        } catch (IOException | IllegalArgumentException exception) {
            throw new GeoBoundaryUnavailableException(
                    "El GeoJSON municipal oficial no está disponible o no es válido.",
                    exception
            );
        }

        for (List<List<Coordinate>> polygon : polygons) {
            if (insideRing(longitude, latitude, polygon.get(0))) {
                boolean insideHole = false;
                for (int ringIndex = 1; ringIndex < polygon.size(); ringIndex++) {
                    if (insideRing(longitude, latitude, polygon.get(ringIndex))) {
                        insideHole = true;
                        break;
                    }
                }
                if (!insideHole) {
                    return true;
                }
            }
        }
        return false;
    }

    public List<GeoCoordinate> findInteriorSamplePoints(int count) {
        if (count < 1 || count > 20) {
            throw new IllegalArgumentException("La cantidad de puntos de prueba debe estar entre 1 y 20.");
        }

        List<List<List<Coordinate>>> polygons;
        try {
            polygons = readPolygons();
        } catch (IOException | IllegalArgumentException exception) {
            throw new GeoBoundaryUnavailableException(
                    "No se pueden generar puntos sin un GeoJSON municipal válido.",
                    exception
            );
        }

        double minLongitude = Double.POSITIVE_INFINITY;
        double maxLongitude = Double.NEGATIVE_INFINITY;
        double minLatitude = Double.POSITIVE_INFINITY;
        double maxLatitude = Double.NEGATIVE_INFINITY;
        for (List<List<Coordinate>> polygon : polygons) {
            for (List<Coordinate> ring : polygon) {
                for (Coordinate coordinate : ring) {
                    minLongitude = Math.min(minLongitude, coordinate.longitude);
                    maxLongitude = Math.max(maxLongitude, coordinate.longitude);
                    minLatitude = Math.min(minLatitude, coordinate.latitude);
                    maxLatitude = Math.max(maxLatitude, coordinate.latitude);
                }
            }
        }

        List<GeoCoordinate> candidates = new ArrayList<>();
        double step = 0.002;
        for (double latitude = minLatitude + step / 2;
             latitude < maxLatitude;
             latitude += step) {
            for (double longitude = minLongitude + step / 2;
                 longitude < maxLongitude;
                 longitude += step) {
                if (contains(latitude, longitude)) {
                    candidates.add(new GeoCoordinate(latitude, longitude));
                }
            }
        }
        if (candidates.size() < count) {
            throw new IllegalStateException(
                    "El polígono no contiene suficientes puntos interiores para los datos de prueba."
            );
        }

        double centerLatitude = (minLatitude + maxLatitude) / 2;
        double centerLongitude = (minLongitude + maxLongitude) / 2;
        GeoCoordinate first = candidates.stream()
                .min(Comparator.comparingDouble(point ->
                        squaredDistance(point, centerLatitude, centerLongitude)))
                .orElseThrow();
        List<GeoCoordinate> selected = new ArrayList<>();
        selected.add(first);
        candidates.remove(first);

        while (selected.size() < count) {
            GeoCoordinate next = candidates.stream()
                    .max(Comparator.comparingDouble(candidate ->
                            selected.stream()
                                    .mapToDouble(point -> squaredDistance(
                                            candidate,
                                            point.latitude(),
                                            point.longitude()
                                    ))
                                    .min()
                                    .orElse(0)))
                    .orElseThrow();
            selected.add(next);
            candidates.remove(next);
        }
        return Collections.unmodifiableList(selected);
    }

    private double squaredDistance(GeoCoordinate point, double latitude, double longitude) {
        double longitudeScale = Math.cos(Math.toRadians(point.latitude));
        double longitudeDelta = (point.longitude - longitude) * longitudeScale;
        double latitudeDelta = point.latitude - latitude;
        return longitudeDelta * longitudeDelta + latitudeDelta * latitudeDelta;
    }

    private List<List<List<Coordinate>>> readPolygons() throws IOException {
        // Interpreta Feature, FeatureCollection, Polygon o MultiPolygon y valida CRS.
        if (!resource.exists()) {
            throw unavailable();
        }
        List<List<List<Coordinate>>> cached = cachedPolygons;
        if (cached != null) {
            return cached;
        }
        synchronized (this) {
            if (cachedPolygons != null) {
                return cachedPolygons;
            }
            JsonNode root;
            try (InputStream input = resource.getInputStream()) {
                root = objectMapper.readTree(input);
            }
            validateCoordinateReference(root);
            List<List<List<Coordinate>>> polygons = new ArrayList<>();

            if ("FeatureCollection".equals(root.path("type").asText())) {
                for (JsonNode feature : root.path("features")) {
                    addGeometry(feature.path("geometry"), polygons);
                }
            } else if ("Feature".equals(root.path("type").asText())) {
                addGeometry(root.path("geometry"), polygons);
            } else {
                addGeometry(root, polygons);
            }

            if (polygons.isEmpty()) {
                throw new IllegalArgumentException("GeoJSON sin polígonos municipales.");
            }
            cachedPolygons = polygons.stream()
                    .map(polygon -> polygon.stream().map(List::copyOf).toList())
                    .toList();
            return cachedPolygons;
        }
    }

    private void validateCoordinateReference(JsonNode root) {
        JsonNode crsName = root.path("crs").path("properties").path("name");
        if (!crsName.isMissingNode()) {
            String name = crsName.asText().toUpperCase();
            if (!name.contains("4326") && !name.contains("CRS84")
                    && !name.contains("WGS84") && !name.contains("WGS 84")) {
                throw new IllegalArgumentException(
                        "El GeoJSON del límite debe usar WGS84/EPSG:4326."
                );
            }
        }
    }

    private void addGeometry(
            JsonNode geometry,
            List<List<List<Coordinate>>> polygons
    ) {
        String type = geometry.path("type").asText();
        JsonNode coordinates = geometry.path("coordinates");
        if ("Polygon".equals(type)) {
            polygons.add(parsePolygon(coordinates));
        } else if ("MultiPolygon".equals(type)) {
            for (JsonNode polygon : coordinates) {
                polygons.add(parsePolygon(polygon));
            }
        } else {
            throw new IllegalArgumentException(
                    "La geometría municipal debe ser Polygon o MultiPolygon."
            );
        }
    }

    private List<List<Coordinate>> parsePolygon(JsonNode polygonNode) {
        List<List<Coordinate>> rings = new ArrayList<>();
        for (JsonNode ringNode : polygonNode) {
            List<Coordinate> ring = new ArrayList<>();
            Iterator<JsonNode> points = ringNode.elements();
            while (points.hasNext()) {
                JsonNode point = points.next();
                if (point.size() < 2) {
                    throw new IllegalArgumentException("Coordenada GeoJSON incompleta.");
                }
                double longitude = point.get(0).asDouble(Double.NaN);
                double latitude = point.get(1).asDouble(Double.NaN);
                if (!Double.isFinite(latitude) || !Double.isFinite(longitude)
                        || latitude < -90 || latitude > 90
                        || longitude < -180 || longitude > 180) {
                    throw new IllegalArgumentException("Coordenada GeoJSON inválida.");
                }
                ring.add(new Coordinate(longitude, latitude));
            }
            if (ring.size() < 4) {
                throw new IllegalArgumentException("Anillo GeoJSON incompleto.");
            }
            rings.add(ring);
        }
        if (rings.isEmpty()) {
            throw new IllegalArgumentException("Polígono GeoJSON sin anillo exterior.");
        }
        return rings;
    }

    private boolean insideRing(double longitude, double latitude, List<Coordinate> ring) {
        boolean inside = false;
        for (int i = 0, j = ring.size() - 1; i < ring.size(); j = i++) {
            Coordinate current = ring.get(i);
            Coordinate previous = ring.get(j);
            boolean crossesLatitude = (current.latitude > latitude)
                    != (previous.latitude > latitude);
            if (crossesLatitude) {
                double crossingLongitude = (previous.longitude - current.longitude)
                        * (latitude - current.latitude)
                        / (previous.latitude - current.latitude)
                        + current.longitude;
                if (longitude < crossingLongitude) {
                    inside = !inside;
                }
            }
        }
        return inside;
    }

    private GeoBoundaryUnavailableException unavailable() {
        return new GeoBoundaryUnavailableException(
                "Falta el límite municipal oficial. Agrega el GeoJSON WGS84 de "
                        + "Villanueva, Bolívar en src/main/resources/geo/"
                        + "villanueva-bolivar.geojson."
        );
    }

    private record Coordinate(double longitude, double latitude) {
    }

    public record GeoCoordinate(double latitude, double longitude) {
    }
}
