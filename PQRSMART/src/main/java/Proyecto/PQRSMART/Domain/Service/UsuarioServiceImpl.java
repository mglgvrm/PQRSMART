package Proyecto.PQRSMART.Domain.Service;


import Proyecto.PQRSMART.Domain.Dto.UsuarioDto;
import Proyecto.PQRSMART.Domain.Mapper.UsuarioMapper;
import Proyecto.PQRSMART.Domain.Service.Interfaces.UsuarioService;
import Proyecto.PQRSMART.Persistence.Entity.StateUser;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UsuarioServiceImpl implements UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    private final PasswordEncoder passwordEncoder;


    public List<UsuarioDto> getAll() {
        return usuarioRepository.findAll().stream().map(UsuarioMapper::toDto).collect(Collectors.toList());
    }

    public Optional<UsuarioDto> findById(Long id) {
        return usuarioRepository.findById(id).map(UsuarioMapper::toDto);
    }

    public Optional<User> findByIds(Long id) {
        return usuarioRepository.findById(id);
    }

    public UsuarioDto save(UsuarioDto usuarioDto) {
        usuarioRepository.save(UsuarioMapper.toEntity(usuarioDto));
        return usuarioDto;
    }

    public User saves(User usuario) {
        usuarioRepository.save(usuario);
        return usuario;
    }

    public UsuarioDto upda(UsuarioDto userDTO) {
        Optional<User> existingUserOptional = usuarioRepository.findById(userDTO.getId());
        if (existingUserOptional.isPresent()) {
            User existingUser = existingUserOptional.get();
            existingUser.setStateUser(userDTO.getStateUser());
            usuarioRepository.save(existingUser);
            return userDTO;
        } else {
            usuarioRepository.save(UsuarioMapper.toEntity(userDTO));
            return userDTO;
        }
    }


    public void verifyUser(String username) {
        User user = usuarioRepository.findByUser(username);
        if (user != null){
            user.setStateUser(new StateUser(2L, "ACTIVO"));
            usuarioRepository.save(user);
        }
    }

    public User findByEmail(String email) {
        return usuarioRepository.findByEmail(email) ;
    }

    public void resetPassword(String email, String newPassword) {
        User user = usuarioRepository.findByEmail(email);
        if (user != null){
            user.setPassword(passwordEncoder.encode(newPassword));
            usuarioRepository.save(user);
        }
        else{
            System.out.println("Email no encontrado");
        }
    }

    public ResponseEntity<UsuarioDto> getProfile() {

        UserDetails userDetails = (UserDetails) SecurityContextHolder
                .getContext()
                .getAuthentication()
                .getPrincipal();

        User user = usuarioRepository.findByUser(userDetails.getUsername());

        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        UsuarioDto dto = UsuarioDto.builder()
                .id(user.getId())
                .name(user.getName())
                .lastName(user.getLastName())
                .email(user.getEmail())
                .user(user.getUser())
                .identificationNumber(user.getIdentificationNumber())
                .stateUser(user.getStateUser())
                .role(user.getRole())
                .number(user.getNumber())
                .build();

        return ResponseEntity.ok(dto);
    }
}
