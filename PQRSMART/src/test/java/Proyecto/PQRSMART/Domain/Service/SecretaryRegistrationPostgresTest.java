package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Domain.Mapper.UsuarioMapper;
import Proyecto.PQRSMART.Persistence.Entity.Dependence;
import Proyecto.PQRSMART.Persistence.Entity.IdentificationType;
import Proyecto.PQRSMART.Persistence.Entity.PersonType;
import Proyecto.PQRSMART.Persistence.Entity.Role;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.DependenceRepository;
import Proyecto.PQRSMART.Persistence.Repository.IdentificationTypeRepository;
import Proyecto.PQRSMART.Persistence.Repository.PersonTypeRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestStateHistoryRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestStateRepository;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import Proyecto.PQRSMART.Controller.models.RegisterRequest;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.math.BigInteger;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@EnabledIfEnvironmentVariable(
        named = "PQRSMART_RUN_LOCAL_DB_INTEGRATION",
        matches = "true"
)
class SecretaryRegistrationPostgresTest {
    @Autowired private TestEntityManager entityManager;
    @Autowired private UsuarioRepository userRepository;
    @Autowired private DependenceRepository dependenceRepository;
    @Autowired private IdentificationTypeRepository identificationTypeRepository;
    @Autowired private PersonTypeRepository personTypeRepository;
    @Autowired private RequestRepository requestRepository;
    @Autowired private RequestStateRepository requestStateRepository;
    @Autowired private RequestStateHistoryRepository requestStateHistoryRepository;

    @AfterEach
    void clearAuthentication() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void persistsEducationAndGovernmentSecretariesAndScopesTheirRequests() {
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        EmailServiceImpl emailService = mock(EmailServiceImpl.class);
        JwtService jwtService = mock(JwtService.class);
        when(jwtService.genereteToken(any(UserDetails.class))).thenReturn("local-test-token");
        AuthServiceImpl authService = new AuthServiceImpl(
                userRepository,
                emailService,
                passwordEncoder,
                jwtService,
                mock(AuthenticationManager.class),
                dependenceRepository,
                identificationTypeRepository,
                personTypeRepository
        );
        Dependence education = dependenceRepository.findById(2L).orElseThrow();
        Dependence government = dependenceRepository.findById(3L).orElseThrow();
        IdentificationType identificationType =
                identificationTypeRepository.findAll().stream().findFirst().orElseThrow();
        PersonType personType = personTypeRepository.findAll().stream().findFirst().orElseThrow();
        String suffix = UUID.randomUUID().toString().replace("-", "");

        authService.registerApp(buildRequest(
                "edu_" + suffix,
                "edu_" + suffix + "@example.invalid",
                2L,
                education,
                identificationType,
                personType
        ));
        authService.registerApp(buildRequest(
                "gov_" + suffix,
                "gov_" + suffix + "@example.invalid",
                3L,
                government,
                identificationType,
                personType
        ));

        entityManager.flush();
        entityManager.clear();

        assertSecretaryAndScope("edu_" + suffix, education, passwordEncoder);
        assertSecretaryAndScope("gov_" + suffix, government, passwordEncoder);
        verify(emailService, never()).sendEmails(any(), any(), any());
    }

    private void assertSecretaryAndScope(
            String username,
            Dependence expectedDependence,
            BCryptPasswordEncoder passwordEncoder
    ) {
        User persisted = userRepository.findUserByUser(username).orElseThrow();
        assertEquals(Role.SECRE, persisted.getRole());
        assertEquals(expectedDependence.getIdDependence(),
                persisted.getDependence().getIdDependence());
        assertEquals(expectedDependence.getNameDependence(),
                UsuarioMapper.toDto(persisted).getDependence().getNameDependence());
        assertEquals(2L, persisted.getStateUser().getId());
        assertTrue(passwordEncoder.matches("SecretPass1!", persisted.getPassword()));

        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(
                        persisted,
                        null,
                        persisted.getAuthorities()
                )
        );
        RequestServicesImpl requestServices = new RequestServicesImpl();
        ReflectionTestUtils.setField(requestServices, "requestRepository", requestRepository);
        ReflectionTestUtils.setField(requestServices, "userRepository", userRepository);
        ReflectionTestUtils.setField(
                requestServices,
                "requestStateRepository",
                requestStateRepository
        );
        ReflectionTestUtils.setField(
                requestServices,
                "requestStateHistoryRepository",
                requestStateHistoryRepository
        );
        assertTrue(requestServices.getForDependence().stream().allMatch(
                request -> request.getDependence() != null
                        && expectedDependence.getIdDependence().equals(
                                request.getDependence().getIdDependence()
                        )
        ));
    }

    private RegisterRequest buildRequest(
            String username,
            String email,
            long idOffset,
            Dependence dependence,
            IdentificationType identificationType,
            PersonType personType
    ) {
        BigInteger numberSuffix = BigInteger.valueOf(System.nanoTime()).abs();
        return RegisterRequest.builder()
                .user(username)
                .name("Secretario")
                .lastName("Integración")
                .email(email)
                .password("SecretPass1!")
                .role(Role.SECRE)
                .dependence(dependence)
                .identificationType(identificationType)
                .identificationNumber(BigInteger.valueOf(8_000_000_000_000_000L)
                        .add(numberSuffix.mod(BigInteger.valueOf(1_000_000_000L)))
                        .add(BigInteger.valueOf(idOffset)))
                .personType(personType)
                .number(BigInteger.valueOf(3_000_000_000L)
                        .add(numberSuffix.mod(BigInteger.valueOf(1_000_000_000L)))
                        .add(BigInteger.valueOf(idOffset)))
                .build();
    }
}
