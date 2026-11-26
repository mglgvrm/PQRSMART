package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Domain.Dto.CategoryDTO;
import Proyecto.PQRSMART.Domain.Dto.DependenceDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestStateDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestTypeDTO;
import Proyecto.PQRSMART.Persistence.Entity.Category;
import Proyecto.PQRSMART.Persistence.Entity.Dependence;
import Proyecto.PQRSMART.Persistence.Entity.RequestState;
import Proyecto.PQRSMART.Persistence.Entity.RequestType;
import Proyecto.PQRSMART.Persistence.Entity.Role;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.CategoryRepository;
import Proyecto.PQRSMART.Persistence.Repository.DependenceRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestStateRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestTypeRepository;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RequestServicesAssistedTest {
    @Test
    void secretaryCannotRegisterForAnotherDependence() {
        RequestRepository requestRepository = mock(RequestRepository.class);
        RequestTypeRepository requestTypeRepository = mock(RequestTypeRepository.class);
        CategoryRepository categoryRepository = mock(CategoryRepository.class);
        DependenceRepository dependenceRepository = mock(DependenceRepository.class);
        RequestStateRepository requestStateRepository = mock(RequestStateRepository.class);

        RequestServicesImpl service = new RequestServicesImpl();
        ReflectionTestUtils.setField(service, "requestRepository", requestRepository);
        ReflectionTestUtils.setField(service, "requestTypeRepository", requestTypeRepository);
        ReflectionTestUtils.setField(service, "categoryRepository", categoryRepository);
        ReflectionTestUtils.setField(service, "dependenceRepository", dependenceRepository);
        ReflectionTestUtils.setField(service, "requestStateRepository", requestStateRepository);

        Dependence secretaryDependence = Dependence.builder().idDependence(1L).build();
        Dependence requestedDependence = Dependence.builder().idDependence(2L).build();
        RequestType requestType = RequestType.builder().idRequestType(1L).build();
        Category category = Category.builder()
                .idCategory(1L)
                .dependence(requestedDependence)
                .build();
        RequestState requestState = RequestState.builder().idRequestState(1L).build();

        when(requestTypeRepository.findById(1L)).thenReturn(Optional.of(requestType));
        when(categoryRepository.findById(1L)).thenReturn(Optional.of(category));
        when(dependenceRepository.findById(2L)).thenReturn(Optional.of(requestedDependence));
        when(requestStateRepository.findById(1L)).thenReturn(Optional.of(requestState));

        RequestDTO dto = RequestDTO.builder()
                .citizenName("Ciudadano de prueba")
                .requestType(RequestTypeDTO.builder().idRequestType(1L).build())
                .category(CategoryDTO.builder().idCategory(1L).build())
                .dependence(DependenceDTO.builder().idDependence(2L).build())
                .requestState(RequestStateDTO.builder().idRequestState(1L).build())
                .build();
        User secretary = User.builder()
                .role(Role.SECRE)
                .dependence(secretaryDependence)
                .build();

        assertThrows(IllegalArgumentException.class, () -> service.saveAssisted(dto, secretary));
        verify(requestRepository, never()).save(any());
    }
}
