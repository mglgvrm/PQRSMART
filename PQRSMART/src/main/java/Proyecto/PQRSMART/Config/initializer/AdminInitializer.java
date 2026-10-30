package Proyecto.PQRSMART.Config.initializer;


import Proyecto.PQRSMART.Persistence.Entity.Role;
import Proyecto.PQRSMART.Persistence.Entity.StateUser;
import Proyecto.PQRSMART.Persistence.Entity.User;
import Proyecto.PQRSMART.Persistence.Repository.DependenceRepository;
import Proyecto.PQRSMART.Persistence.Repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
@RequiredArgsConstructor
public class AdminInitializer implements CommandLineRunner {

    private final UsuarioRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final DependenceRepository dependenciaRepository;
    private final DataSource dataSource;

    @Override
    public void run(String... args) {


        if (!userRepository.existsByUser("admin")) {
            executeScriptSQL();

            var dependencia = dependenciaRepository.findById(7L)
                    .orElseThrow(() -> new RuntimeException("Dependencia 7 no existe"));
            var admin = User.builder()
                    .user("admin")
                    .name("Administrador")
                    .lastName("Sistema")
                    .email("admin@pqrsmart.com")
                    .password(passwordEncoder.encode("Admin123*"))
                    .role(Role.ADMIN)
                    .dependence(dependencia)
                    .stateUser(new StateUser(2L, "ACTIVO"))

                    .build();

            userRepository.save(admin);

            executeScriptSQLUsers();
            
        }
    }

    private void executeScriptSQL() {
        try {
            ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
            populator.addScript(new ClassPathResource("sql/data.sql"));
            populator.execute(dataSource);
            System.out.println("Script SQL ejecutado correctamente.");
        } catch (Exception e) {
            throw new RuntimeException("Error ejecutando el archivo SQL de inicialización", e);
        }
    }

    private void executeScriptSQLUsers() {
        try {
            ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
            populator.addScript(new ClassPathResource("sql/users.sql"));
            populator.execute(dataSource);
            System.out.println("Script SQL ejecutado correctamente.");
        } catch (Exception e) {
            throw new RuntimeException("Error ejecutando el archivo SQL de inicialización", e);
        }
    }
}