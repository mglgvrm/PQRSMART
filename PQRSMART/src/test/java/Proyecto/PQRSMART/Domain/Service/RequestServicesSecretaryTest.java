package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Persistence.Entity.Dependence;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Entity.RequestState;
import Proyecto.PQRSMART.Persistence.Entity.RequestStateHistory;
import Proyecto.PQRSMART.Persistence.Entity.Role;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestStateHistoryRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestStateRepository;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RequestServicesSecretaryTest {
    @AfterEach
    void clearAuthentication() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void secretaryCanOnlyLoadRequestsFromTheirAssignedDependence() {
        RequestRepository requestRepository = mock(RequestRepository.class);
        UsuarioRepository userRepository = mock(UsuarioRepository.class);
        Dependence dependence = Dependence.builder().idDependence(3L).build();
        User secretary = secretary(dependence);
        when(userRepository.findByUser("secretary")).thenReturn(secretary);
        when(requestRepository.findByDependence(dependence)).thenReturn(List.of());
        authenticate();

        RequestServicesImpl service = service(requestRepository, userRepository);
        service.getForDependence();

        verify(requestRepository).findByDependence(dependence);
    }

    @Test
    void secretaryCannotChangeARequestFromAnotherDependence() {
        RequestRepository requestRepository = mock(RequestRepository.class);
        UsuarioRepository userRepository = mock(UsuarioRepository.class);
        Dependence secretaryDependence = Dependence.builder().idDependence(3L).build();
        Dependence otherDependence = Dependence.builder().idDependence(4L).build();
        when(userRepository.findByUser("secretary"))
                .thenReturn(secretary(secretaryDependence));
        when(requestRepository.findById(42L)).thenReturn(Optional.of(
                Request.builder().dependence(otherDependence).build()
        ));
        authenticate();

        RequestServicesImpl service = service(requestRepository, userRepository);
        assertThrows(
                AccessDeniedException.class,
                () -> service.updateStateForSecretary(42L, 2L, "Prueba")
        );
        verify(requestRepository, never()).save(any());
    }

    @Test
    void secretaryCanChangeTheirRequestAndTheChangeIsRecorded() {
        RequestRepository requestRepository = mock(RequestRepository.class);
        UsuarioRepository userRepository = mock(UsuarioRepository.class);
        RequestStateRepository stateRepository = mock(RequestStateRepository.class);
        RequestStateHistoryRepository historyRepository =
                mock(RequestStateHistoryRepository.class);
        Dependence dependence = Dependence.builder().idDependence(3L).build();
        User secretary = secretary(dependence);
        Request request = Request.builder()
                .idRequest(42L)
                .dependence(dependence)
                .requestState(RequestState.builder()
                        .idRequestState(1L)
                        .nameRequestState("Pendiente")
                        .build())
                .build();
        RequestState newState = RequestState.builder()
                .idRequestState(2L)
                .nameRequestState("Finalizado")
                .build();

        when(userRepository.findByUser("secretary")).thenReturn(secretary);
        when(requestRepository.findById(42L)).thenReturn(Optional.of(request));
        when(stateRepository.findById(2L)).thenReturn(Optional.of(newState));
        when(requestRepository.save(any(Request.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        authenticate();

        RequestServicesImpl service = service(requestRepository, userRepository);
        ReflectionTestUtils.setField(service, "requestStateRepository", stateRepository);
        ReflectionTestUtils.setField(
                service,
                "requestStateHistoryRepository",
                historyRepository
        );
        var updated = service.updateStateForSecretary(42L, 2L, "Revisión completada");

        org.junit.jupiter.api.Assertions.assertEquals(2L, updated.getRequestState().getIdRequestState());
        var history = org.mockito.ArgumentCaptor.forClass(RequestStateHistory.class);
        verify(historyRepository).save(history.capture());
        org.junit.jupiter.api.Assertions.assertEquals(
                "Revisión completada",
                history.getValue().getObservation()
        );
    }

    private RequestServicesImpl service(
            RequestRepository requestRepository,
            UsuarioRepository userRepository
    ) {
        RequestServicesImpl service = new RequestServicesImpl();
        ReflectionTestUtils.setField(service, "requestRepository", requestRepository);
        ReflectionTestUtils.setField(service, "userRepository", userRepository);
        ReflectionTestUtils.setField(
                service,
                "requestStateRepository",
                mock(RequestStateRepository.class)
        );
        ReflectionTestUtils.setField(
                service,
                "requestStateHistoryRepository",
                mock(RequestStateHistoryRepository.class)
        );
        return service;
    }

    private User secretary(Dependence dependence) {
        return User.builder()
                .user("secretary")
                .role(Role.SECRE)
                .dependence(dependence)
                .build();
    }

    private void authenticate() {
        UserDetails principal = org.springframework.security.core.userdetails.User
                .withUsername("secretary")
                .password("hashed")
                .roles("SECRE")
                .build();
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(
                        principal,
                        null,
                        principal.getAuthorities()
                )
        );
    }
}
