package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Controller.models.RegisterRequest;
import Proyecto.PQRSMART.Persistence.Entity.Dependence;
import Proyecto.PQRSMART.Persistence.Entity.IdentificationType;
import Proyecto.PQRSMART.Persistence.Entity.PersonType;
import Proyecto.PQRSMART.Persistence.Entity.Role;
import Proyecto.PQRSMART.Persistence.Entity.State;
import Proyecto.PQRSMART.Persistence.Repository.DependenceRepository;
import Proyecto.PQRSMART.Persistence.Repository.IdentificationTypeRepository;
import Proyecto.PQRSMART.Persistence.Repository.PersonTypeRepository;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigInteger;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.clearInvocations;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuthServiceRegistrationTest {
    private UsuarioRepository userRepository;
    private EmailServiceImpl emailService;
    private PasswordEncoder passwordEncoder;
    private JwtService jwtService;
    private DependenceRepository dependenceRepository;
    private IdentificationTypeRepository identificationTypeRepository;
    private PersonTypeRepository personTypeRepository;
    private AuthServiceImpl service;

    @BeforeEach
    void setUp() {
        userRepository = mock(UsuarioRepository.class);
        emailService = mock(EmailServiceImpl.class);
        passwordEncoder = mock(PasswordEncoder.class);
        jwtService = mock(JwtService.class);
        dependenceRepository = mock(DependenceRepository.class);
        identificationTypeRepository = mock(IdentificationTypeRepository.class);
        personTypeRepository = mock(PersonTypeRepository.class);
        service = new AuthServiceImpl(
                userRepository,
                emailService,
                passwordEncoder,
                jwtService,
                mock(org.springframework.security.authentication.AuthenticationManager.class),
                dependenceRepository,
                identificationTypeRepository,
                personTypeRepository
        );

        IdentificationType identificationType = mock(IdentificationType.class);
        when(identificationType.getIdIdentificationType()).thenReturn(1L);
        when(identificationTypeRepository.findById(1L))
                .thenReturn(Optional.of(identificationType));
        PersonType personType = mock(PersonType.class);
        when(personTypeRepository.findById(1L)).thenReturn(Optional.of(personType));
        when(passwordEncoder.encode("SecretPass1!")).thenReturn("bcrypt-hash");
        when(jwtService.genereteToken(any(UserDetails.class))).thenReturn("test-token");
        when(userRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
    }

    @Test
    void registersSecretariesWithEachActiveDependenceAndHashesPassword() {
        for (long dependenceId = 1; dependenceId <= 6; dependenceId++) {
            Dependence dependence = Dependence.builder()
                    .idDependence(dependenceId)
                    .state(State.builder().id(1L).description("ACTIVADO").build())
                    .build();
            when(dependenceRepository.findById(dependenceId))
                    .thenReturn(Optional.of(dependence));

            var request = validRequest(dependenceId);
            clearInvocations(userRepository);
            service.registerApp(request);

            var savedUser = org.mockito.ArgumentCaptor.forClass(
                    Proyecto.PQRSMART.Persistence.Entity.User.class
            );
            verify(userRepository).save(savedUser.capture());
            assertEquals(Role.SECRE, savedUser.getValue().getRole());
            assertEquals(dependenceId,
                    savedUser.getValue().getDependence().getIdDependence());
            assertEquals("bcrypt-hash", savedUser.getValue().getPassword());
            assertEquals(2L, savedUser.getValue().getStateUser().getId());
        }
        verify(emailService, never()).sendEmails(any(), any(), any());
    }

    @Test
    void rejectsSecretaryWithoutDependenceBeforeSaving() {
        RegisterRequest request = validRequest(null);
        request.setDependence(null);

        assertThrows(IllegalArgumentException.class, () -> service.registerApp(request));
        verify(userRepository, never()).save(any());
    }

    private RegisterRequest validRequest(Long dependenceId) {
        var identificationType = mock(IdentificationType.class);
        when(identificationType.getIdIdentificationType()).thenReturn(1L);
        var personType = mock(PersonType.class);
        when(personType.getIdPersonType()).thenReturn(1L);
        return RegisterRequest.builder()
                .user("secretary-" + dependenceId)
                .name("Secretario")
                .lastName("Prueba")
                .email("secretary-" + dependenceId + "@example.invalid")
                .password("SecretPass1!")
                .identificationType(identificationType)
                .identificationNumber(BigInteger.valueOf(100000 + (dependenceId == null ? 0 : dependenceId)))
                .personType(personType)
                .number(BigInteger.valueOf(3000000000L + (dependenceId == null ? 0 : dependenceId)))
                .role(Role.SECRE)
                .dependence(dependenceId == null
                        ? null
                        : Dependence.builder().idDependence(dependenceId).build())
                .build();
    }
}
