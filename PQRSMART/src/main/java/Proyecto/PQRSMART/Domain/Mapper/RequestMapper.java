package Proyecto.PQRSMART.Domain.Mapper;

import Proyecto.PQRSMART.Domain.Dto.*;
import Proyecto.PQRSMART.Persistence.Entity.*;

public class RequestMapper {

    public static Request toEntity(RequestDTO dto) {

        if (dto == null) return null;

        Request request = new Request();

        request.setIdRequest(dto.getIdRequest());
        request.setRadicado(dto.getRadicado());
        request.setDescription(dto.getDescription());
        request.setDate(dto.getDate());
        request.setAnswer(dto.getAnswer());
        request.setMediumAnswer(dto.getMediumAnswer());
        request.setArchivo(dto.getArchivo());
        request.setArchiveAnswer(dto.getArchiveAnswer());
        request.setLatitude(dto.getLatitude());
        request.setLongitude(dto.getLongitude());
        request.setLocationSource(dto.getLocationSource());
        request.setLocationMethod(dto.getLocationMethod());
        request.setLocationDescription(dto.getLocationDescription());
        request.setLocationCapturedAt(dto.getLocationCapturedAt());
        request.setCitizenName(dto.getCitizenName());
        request.setCitizenEmail(dto.getCitizenEmail());
        request.setCitizenPhone(dto.getCitizenPhone());

        // 🔥 Relaciones SOLO con ID (sin traer toda la entidad)

        if (dto.getUser() != null) {
            User user = new User();
            user.setId(dto.getUser().getId());
            request.setUser(user);
        }
        if (dto.getRegisteredBy() != null) {
            User registeredBy = new User();
            registeredBy.setId(dto.getRegisteredBy().getId());
            request.setRegisteredBy(registeredBy);
        }

        if (dto.getRequestType() != null) {
            RequestType type = new RequestType();
            type.setIdRequestType(dto.getRequestType().getIdRequestType());
            request.setRequestType(type);
        }

        if (dto.getCategory() != null) {
            Category category = new Category();
            category.setIdCategory(dto.getCategory().getIdCategory());
            request.setCategory(category);
        }

        if (dto.getDependence() != null) {
            Dependence dependence = new Dependence();
            dependence.setIdDependence(dto.getDependence().getIdDependence());
            request.setDependence(dependence);
        }

        if (dto.getRequestState() != null) {
            RequestState state = new RequestState();
            state.setIdRequestState(dto.getRequestState().getIdRequestState());
            request.setRequestState(state);
        }

        return request;
    }

    public static RequestDTO toDTO(Request request) {

        if (request == null) return null;

        RequestDTO dto = new RequestDTO();

        dto.setIdRequest(request.getIdRequest());
        dto.setRadicado(request.getRadicado());
        dto.setDescription(request.getDescription());
        dto.setDate(request.getDate());
        dto.setUpdatedAt(request.getUpdatedAt());
        dto.setAnswer(request.getAnswer());
        dto.setMediumAnswer(request.getMediumAnswer());
        dto.setArchivo(request.getArchivo());
        dto.setArchiveAnswer(request.getArchiveAnswer());
        dto.setLatitude(request.getLatitude());
        dto.setLongitude(request.getLongitude());
        dto.setLocationSource(request.getLocationSource());
        dto.setLocationMethod(request.getLocationMethod());
        dto.setLocationDescription(request.getLocationDescription());
        dto.setLocationCapturedAt(request.getLocationCapturedAt());
        dto.setCitizenName(request.getCitizenName());
        dto.setCitizenEmail(request.getCitizenEmail());
        dto.setCitizenPhone(request.getCitizenPhone());

        // 🔥 Convertimos Entity → DTO correctamente

        if (request.getUser() != null) {
            dto.setUser(
                    UsuarioDto.builder()
                            .id(request.getUser().getId())
                            .name(request.getUser().getName())
                            .lastName(request.getUser().getLastName())
                            .user(request.getUser().getUsername())
                            .email(request.getUser().getEmail())
                            .build()
            );
        }
        if (request.getRegisteredBy() != null) {
            dto.setRegisteredBy(
                    UsuarioDto.builder()
                            .id(request.getRegisteredBy().getId())
                            .name(request.getRegisteredBy().getName())
                            .lastName(request.getRegisteredBy().getLastName())
                            .user(request.getRegisteredBy().getUsername())
                            .role(request.getRegisteredBy().getRole())
                            .build()
            );
        }

        if (request.getRequestState() != null) {
            dto.setRequestState(
                    RequestStateDTO.builder()
                            .idRequestState(request.getRequestState().getIdRequestState())
                            .nameRequestState(request.getRequestState().getNameRequestState())
                            .build()
            );
        }
        if (request.getDependence() != null) {
            dto.setDependence(
                    DependenceDTO.builder()
                            .idDependence(request.getDependence().getIdDependence())
                            .nameDependence(request.getDependence().getNameDependence())
                            .build()
            );
        }
        if (request.getCategory() != null) {
            dto.setCategory(
                    CategoryDTO.builder()
                            .idCategory(request.getCategory().getIdCategory())
                            .nameCategory(request.getCategory().getNameCategory())
                            .build()
            );
        }
        if (request.getRequestType() != null) {
            dto.setRequestType(
                    RequestTypeDTO.builder()
                            .idRequestType(request.getRequestType().getIdRequestType())
                            .nameRequestType(request.getRequestType().getNameRequestType())
                            .build()
            );
        }
        // Puedes hacer lo mismo para Category, Dependence y RequestType

        return dto;
    }
}