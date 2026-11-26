package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Domain.Dto.CategoryDTO;
import Proyecto.PQRSMART.Domain.Dto.DependenceDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestStateDTO;
import Proyecto.PQRSMART.Domain.Dto.RequestTypeDTO;
import Proyecto.PQRSMART.Domain.Dto.UsuarioDto;
import Proyecto.PQRSMART.Persistence.Entity.Category;
import Proyecto.PQRSMART.Persistence.Entity.Dependence;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Entity.RequestState;
import Proyecto.PQRSMART.Persistence.Entity.RequestType;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.CategoryRepository;
import Proyecto.PQRSMART.Persistence.Repository.DependenceRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestStateRepository;
import Proyecto.PQRSMART.Persistence.Repository.RequestTypeRepository;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class RequestServicesCatalogTest {
    @Test
    void resolvesSelectedCatalogIdsToNamesForRequestAnalysis() {
        RequestRepository requestRepository = mock(RequestRepository.class);
        RequestTypeRepository requestTypeRepository = mock(RequestTypeRepository.class);
        CategoryRepository categoryRepository = mock(CategoryRepository.class);
        DependenceRepository dependenceRepository = mock(DependenceRepository.class);
        RequestStateRepository requestStateRepository = mock(RequestStateRepository.class);
        UsuarioRepository usuarioRepository = mock(UsuarioRepository.class);

        Dependence dependence = Dependence.builder()
                .idDependence(3L)
                .nameDependence("Servicios Públicos")
                .build();
        Category category = Category.builder()
                .idCategory(4L)
                .nameCategory("Alumbrado público")
                .dependence(dependence)
                .build();
        RequestType type = RequestType.builder()
                .idRequestType(2L)
                .nameRequestType("Queja")
                .build();
        RequestState state = RequestState.builder()
                .idRequestState(1L)
                .nameRequestState("Pendiente")
                .build();
        User user = User.builder().id(5L).build();

        when(requestTypeRepository.findById(2L)).thenReturn(Optional.of(type));
        when(categoryRepository.findById(4L)).thenReturn(Optional.of(category));
        when(dependenceRepository.findById(3L)).thenReturn(Optional.of(dependence));
        when(requestStateRepository.findById(1L)).thenReturn(Optional.of(state));
        when(usuarioRepository.findById(5L)).thenReturn(Optional.of(user));

        RequestServicesImpl service = new RequestServicesImpl();
        ReflectionTestUtils.setField(service, "requestRepository", requestRepository);
        ReflectionTestUtils.setField(service, "requestTypeRepository", requestTypeRepository);
        ReflectionTestUtils.setField(service, "categoryRepository", categoryRepository);
        ReflectionTestUtils.setField(service, "dependenceRepository", dependenceRepository);
        ReflectionTestUtils.setField(service, "requestStateRepository", requestStateRepository);
        ReflectionTestUtils.setField(service, "userRepository", usuarioRepository);

        Request resolved = service.findEntityByIds(RequestDTO.builder()
                .user(UsuarioDto.builder().id(5L).build())
                .requestType(RequestTypeDTO.builder().idRequestType(2L).build())
                .category(CategoryDTO.builder().idCategory(4L).build())
                .dependence(DependenceDTO.builder().idDependence(3L).build())
                .requestState(RequestStateDTO.builder().idRequestState(1L).build())
                .build());

        assertSame(type, resolved.getRequestType());
        assertSame(category, resolved.getCategory());
        assertSame(dependence, resolved.getDependence());
        assertSame(state, resolved.getRequestState());
        assertSame(dependence, resolved.getCategory().getDependence());
    }
}
