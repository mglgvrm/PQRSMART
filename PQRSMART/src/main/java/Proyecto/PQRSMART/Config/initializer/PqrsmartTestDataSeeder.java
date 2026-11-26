package Proyecto.PQRSMART.Config.initializer;

import Proyecto.PQRSMART.Domain.Service.GeoBoundaryService;
import Proyecto.PQRSMART.Domain.Service.GeoAnalyticsService;
import Proyecto.PQRSMART.Persistence.Entity.*;
import Proyecto.PQRSMART.Persistence.Repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.math.BigInteger;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneOffset;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Component
@Profile("testdata")
@ConditionalOnProperty(name = "pqrsmart.test-data.enabled", havingValue = "true")
@RequiredArgsConstructor
// Genera solicitudes ficticias georreferenciadas solo en el perfil testdata y
// cuando la propiedad de carga de datos de prueba está habilitada.
public class PqrsmartTestDataSeeder implements ApplicationRunner {
    private static final String USER_PREFIX = "pqrsmart_test_";
    private static final String EMAIL_SUFFIX = "@example.invalid";
    private static final String REQUEST_PREFIX = "TEST-PQRSMART-20261119-";
    private static final String REQUEST_MARKER = "TEST DATA - PQRSMART.";
    private static final LocalDate LAST_DAY = LocalDate.of(2026, 11, 19);

    private final DataSource dataSource;
    private final UsuarioRepository userRepository;
    private final RequestRepository requestRepository;
    private final RequestTypeRepository requestTypeRepository;
    private final RequestStateRepository requestStateRepository;
    private final CategoryRepository categoryRepository;
    private final StateUserRepository stateUserRepository;
    private final PersonTypeRepository personTypeRepository;
    private final IdentificationTypeRepository identificationTypeRepository;
    private final PasswordEncoder passwordEncoder;
    private final GeoBoundaryService geoBoundaryService;
    private final GeoAnalyticsService geoAnalyticsService;

    @Value("${pqrsmart.test-data.password:PqrTest!2026}")
    private String testPassword;

    @Override
    @Transactional
    public void run(ApplicationArguments args) throws Exception {
        assertLocalDevelopmentDatabase();
        if (!geoBoundaryService.isAvailable()) {
            throw new IllegalStateException(
                    "No se cargan datos de prueba sin el GeoJSON oficial de Villanueva, Bolívar."
            );
        }
        if (testPassword == null || testPassword.isBlank()) {
            throw new IllegalStateException("Define una contraseña temporal para las cuentas de prueba.");
        }

        List<GeoBoundaryService.GeoCoordinate> samplePoints =
                geoBoundaryService.findInteriorSamplePoints(4);
        Map<String, RequestType> types = requestTypeRepository.findAll().stream()
                .collect(Collectors.toMap(
                        requestType -> normalize(requestType.getNameRequestType()),
                        Function.identity(),
                        (first, ignored) -> first
                ));
        Map<String, RequestState> states = requestStateRepository.findAll().stream()
                .collect(Collectors.toMap(
                        requestState -> normalize(requestState.getNameRequestState()),
                        Function.identity(),
                        (first, ignored) -> first
                ));
        RequestType[] requestTypes = {
                required(types, "peticion", "Petición"),
                required(types, "queja", "Queja"),
                required(types, "reclamo", "Reclamo"),
                required(types, "sugerencia", "Sugerencia")
        };
        RequestState[] requestStates = {
                required(states, "pendiente", "Pendiente"),
                required(states, "finalizado", "Finalizado"),
                required(states, "rechazado", "Rechazado"),
                required(states, "cancelado", "Cancelado")
        };
        List<Category> categories = categoryRepository.findAll();
        if (categories.isEmpty() || categories.stream().anyMatch(
                category -> category.getDependence() == null
        )) {
            throw new IllegalStateException("El catálogo existente no tiene categorías con dependencia.");
        }

        List<User> testUsers = createOrLoadTestUsers();
        int createdRequests = createMissingRequests(
                testUsers,
                categories,
                requestTypes,
                requestStates,
                samplePoints
        );
        List<Request> matchingTestRequests = requestRepository
                .findByRadicadoStartingWith(REQUEST_PREFIX)
                .stream()
                .filter(request -> request.getDescription() != null
                        && request.getDescription().startsWith(REQUEST_MARKER))
                .toList();
        long matchingRequests = matchingTestRequests.size();

        if (testUsers.size() != 10 || matchingRequests != 20) {
            throw new IllegalStateException(
                    "La verificación de datos de prueba esperaba 10 usuarios y 20 solicitudes; "
                            + "obtuvo " + testUsers.size() + " y " + matchingRequests + "."
            );
        }
        verifyTestRequests(matchingTestRequests, requestTypes, requestStates);
        verifyHeatmapFilters(requestTypes, requestStates);

        System.out.printf(
                "Datos de prueba PQRSMART verificados: usuarios=%d, solicitudes=%d, "
                        + "solicitudes_creadas_ahora=%d, DB=local/pqrsmartdb%n",
                testUsers.size(),
                matchingRequests,
                createdRequests
        );
    }

    private List<User> createOrLoadTestUsers() {
        List<StateUser> activeStates = stateUserRepository.findAll().stream()
                .filter(state -> "activo".equals(normalize(state.getState())))
                .toList();
        if (activeStates.isEmpty()) {
            throw new IllegalStateException("No existe el estado ACTIVO en el catálogo de usuarios.");
        }

        PersonType personType = personTypeRepository
                .findByNamePersonTypeIgnoreCase("Persona Natural");
        IdentificationType identificationType =
                identificationTypeRepository.findByNameIdentificationTypeIgnoreCase(
                        "Cédula de ciudadanía"
                );
        if (personType == null || identificationType == null) {
            throw new IllegalStateException(
                    "Falta el tipo de persona natural o el tipo de identificación ciudadana."
            );
        }

        List<User> users = new ArrayList<>();
        for (int index = 1; index <= 10; index++) {
            String username = USER_PREFIX + String.format("%02d", index);
            String email = "pqrsmart.test." + String.format("%02d", index) + EMAIL_SUFFIX;
            User existing = userRepository.findByUser(username);
            if (existing != null) {
                if (!email.equalsIgnoreCase(existing.getEmail())
                        || existing.getRole() != Role.USER
                        || existing.getName() == null
                        || !existing.getName().startsWith("Usuario Prueba")) {
                    throw new IllegalStateException(
                            "Colisión con una cuenta ajena al conjunto de prueba: " + username
                    );
                }
                users.add(existing);
                continue;
            }
            if (userRepository.existsByEmail(email)) {
                throw new IllegalStateException(
                        "Colisión con un correo existente ajeno a la prueba: " + email
                );
            }

            User user = User.builder()
                    .user(username)
                    .name("Usuario Prueba " + String.format("%02d", index))
                    .lastName("Datos Ficticios")
                    .email(email)
                    .password(passwordEncoder.encode(testPassword))
                    .role(Role.USER)
                    .stateUser(activeStates.get(0))
                    .identificationType(identificationType)
                    .identificationNumber(BigInteger.valueOf(990_000_000_000L + index))
                    .number(BigInteger.valueOf(300_555_0100L + index))
                    .personType(personType)
                    .build();
            users.add(userRepository.save(user));
        }
        return users;
    }

    // Coloca datos ficticios en celdas dentro del límite municipal para pruebas locales.
    private int createMissingRequests(
            List<User> users,
            List<Category> categories,
            RequestType[] types,
            RequestState[] states,
            List<GeoBoundaryService.GeoCoordinate> samplePoints
    ) {
        List<Request> existingRequests = requestRepository.findByRadicadoStartingWith(REQUEST_PREFIX);
        List<Request> toCreate = new ArrayList<>();
        for (int index = 0; index < 20; index++) {
            String radicado = REQUEST_PREFIX + String.format("%02d", index + 1);
            Request existing = existingRequests.stream()
                    .filter(request -> radicado.equals(request.getRadicado()))
                    .findFirst()
                    .orElse(null);
            int userIndex = index / 2;
            if (existing != null) {
                if (existing.getDescription() == null
                        || !existing.getDescription().startsWith(REQUEST_MARKER)
                        || existing.getUser() == null
                        || !Objects.equals(
                                existing.getUser().getId(),
                                users.get(userIndex).getId()
                        )) {
                    throw new IllegalStateException(
                            "Colisión con un radicado ajeno a la prueba: " + radicado
                    );
                }
                if (existing.getLatitude() == null || existing.getLongitude() == null
                        || !geoBoundaryService.contains(
                                existing.getLatitude(), existing.getLongitude()
                        )) {
                    throw new IllegalStateException(
                            "La solicitud de prueba tiene una ubicación inválida: " + radicado
                    );
                }
                continue;
            }

            int cluster = clusterFor(index);
            GeoBoundaryService.GeoCoordinate point = samplePoints.get(cluster);
            if (!geoBoundaryService.contains(point.latitude(), point.longitude())) {
                throw new IllegalStateException("Se generó un punto de prueba fuera del municipio.");
            }
            RequestType type = types[index % types.length];
            Category category = categories.get(index % categories.size());
            LocalDate date = requestDate(index);
            Request request = Request.builder()
                    .radicado(radicado)
                    .user(users.get(userIndex))
                    .requestType(type)
                    .category(category)
                    .description(REQUEST_MARKER + " Solicitud ficticia de tipo "
                            + type.getNameRequestType() + " y categoría "
                            + category.getNameCategory()
                            + ". No corresponde a un ciudadano ni reporte real.")
                    .date(date)
                    .requestState(states[index % states.length])
                    .mediumAnswer("Prueba local, sin envío")
                    .dependence(category.getDependence())
                    .priority(Priority.values()[index % Priority.values().length])
                    .latitude(point.latitude())
                    .longitude(point.longitude())
                    .locationSource(RequestLocationSource.MANUAL)
                    .locationMethod(RequestLocationMethod.MANUAL)
                    .locationDescription("Sector ficticio de prueba " + (cluster + 1))
                    .locationCapturedAt(date.atTime(LocalTime.NOON).toInstant(ZoneOffset.UTC))
                    .build();
            toCreate.add(request);
        }
        requestRepository.saveAll(toCreate);
        return toCreate.size();
    }

    private void verifyTestRequests(
            List<Request> testRequests,
            RequestType[] types,
            RequestState[] states
    ) {
        Map<Long, Long> requestsPerUser = testRequests.stream()
                .filter(request -> request.getUser() != null)
                .collect(Collectors.groupingBy(
                        request -> request.getUser().getId(),
                        Collectors.counting()
                ));
        if (requestsPerUser.size() != 10
                || requestsPerUser.values().stream().anyMatch(count -> count != 2)) {
            throw new IllegalStateException(
                    "Los datos de prueba deben asociar exactamente dos solicitudes a cada cuenta."
            );
        }

        for (Request request : testRequests) {
            if (request.getLatitude() == null || request.getLongitude() == null
                    || !geoBoundaryService.contains(
                            request.getLatitude(),
                            request.getLongitude()
                    )
                    || request.getDate() == null
                    || request.getDate().isBefore(LAST_DAY.minusDays(29))
                    || request.getDate().isAfter(LAST_DAY)
                    || request.getRequestType() == null
                    || request.getRequestState() == null) {
                throw new IllegalStateException(
                        "La solicitud de prueba tiene datos inválidos: " + request.getRadicado()
                );
            }
        }
        long lastDayCount = testRequests.stream()
                .filter(request -> LAST_DAY.equals(request.getDate()))
                .count();
        if (lastDayCount != 4) {
            throw new IllegalStateException(
                    "Se esperaban cuatro solicitudes de prueba fechadas el 19/11/2026."
            );
        }
        for (RequestType type : types) {
            long count = testRequests.stream()
                    .filter(request -> Objects.equals(
                            request.getRequestType().getIdRequestType(),
                            type.getIdRequestType()
                    ))
                    .count();
            if (count != 5) {
                throw new IllegalStateException(
                        "Se esperaban cinco solicitudes de prueba del tipo "
                                + type.getNameRequestType() + "."
                );
            }
        }
        for (RequestState state : states) {
            long count = testRequests.stream()
                    .filter(request -> Objects.equals(
                            request.getRequestState().getIdRequestState(),
                            state.getIdRequestState()
                    ))
                    .count();
            if (count != 5) {
                throw new IllegalStateException(
                        "Se esperaban cinco solicitudes de prueba en estado "
                                + state.getNameRequestState() + "."
                );
            }
        }
        Map<String, Long> cellCounts = testRequests.stream()
                .collect(Collectors.groupingBy(
                        request -> heatmapCellKey(request.getLatitude(), request.getLongitude()),
                        Collectors.counting()
                ));
        List<Long> concentrationCounts = cellCounts.values().stream()
                .sorted(java.util.Comparator.reverseOrder())
                .toList();
        if (!List.of(10L, 5L, 3L, 2L).equals(concentrationCounts)) {
            throw new IllegalStateException(
                    "Las solicitudes de prueba no forman cuatro concentraciones geográficas."
            );
        }
    }

    private String heatmapCellKey(double latitude, double longitude) {
        return (int) Math.floor(latitude / 0.01)
                + ":" + (int) Math.floor(longitude / 0.01);
    }

    private void verifyHeatmapFilters(RequestType[] types, RequestState[] states) {
        if (geoAnalyticsService.getHeatmap(
                LAST_DAY, LAST_DAY, null, null
        ).getTotalRequests() < 4) {
            throw new IllegalStateException(
                    "El filtro geográfico del 19/11/2026 no encuentra las solicitudes de prueba."
            );
        }
        for (RequestType type : types) {
            if (geoAnalyticsService.getHeatmap(
                    null, null, type.getIdRequestType(), null
            ).getTotalRequests() < 5) {
                throw new IllegalStateException(
                        "El filtro geográfico no encuentra las solicitudes del tipo "
                                + type.getNameRequestType() + "."
                );
            }
        }
        for (RequestState state : states) {
            if (geoAnalyticsService.getHeatmap(
                    null, null, null, state.getIdRequestState()
            ).getTotalRequests() < 5) {
                throw new IllegalStateException(
                        "El filtro geográfico no encuentra solicitudes en estado "
                                + state.getNameRequestState() + "."
                );
            }
        }
    }

    private int clusterFor(int index) {
        if (index < 10) return 0;
        if (index < 15) return 1;
        if (index < 18) return 2;
        return 3;
    }

    private LocalDate requestDate(int index) {
        if (index % 5 == 0) {
            return LAST_DAY;
        }
        return LAST_DAY.minusDays(1 + index % 29);
    }

    private <T> T required(Map<String, T> values, String name, String label) {
        T value = values.get(name);
        if (value == null) {
            throw new IllegalStateException("No se encontró el valor existente del catálogo: " + label);
        }
        return value;
    }

    private String normalize(String value) {
        if (value == null) return "";
        return Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .toLowerCase(Locale.ROOT)
                .trim();
    }

    private void assertLocalDevelopmentDatabase() throws SQLException {
        try (Connection connection = dataSource.getConnection()) {
            String url = connection.getMetaData().getURL();
            String database = connection.getCatalog();
            boolean localUrl = url != null && url.matches(
                    "(?i)^jdbc:postgresql://(localhost|127\\.0\\.0\\.1|\\[::1\\])(?::\\d+)?/[^?]+(?:\\?.*)?$"
            );
            boolean developmentDatabase = "pqrsmartdb".equalsIgnoreCase(database)
                    || "pqrsmart_dev".equalsIgnoreCase(database)
                    || "pqrsmart_test".equalsIgnoreCase(database);
            if (!localUrl || !developmentDatabase) {
                throw new IllegalStateException(
                        "Se canceló la carga: solo se permite localhost y una base "
                                + "pqrsmartdb/pqrsmart_dev/pqrsmart_test; conexión detectada: "
                                + url
                );
            }
        }
    }
}
