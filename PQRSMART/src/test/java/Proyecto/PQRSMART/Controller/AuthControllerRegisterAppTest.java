package Proyecto.PQRSMART.Controller;

import Proyecto.PQRSMART.Domain.Service.EmailDeliveryException;
import Proyecto.PQRSMART.Domain.Service.Interfaces.AuthService;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class AuthControllerRegisterAppTest {
    @Test
    void emailFailureReturnsSafeJsonAndIdentifiesThatNoAccountWasCreated() {
        AuthService authService = mock(AuthService.class);
        when(authService.registerApp(any()))
                .thenThrow(new EmailDeliveryException(new IllegalStateException("provider details")));
        AuthController controller = new AuthController();
        ReflectionTestUtils.setField(controller, "authService", authService);

        var response = controller.registerApp(null);

        assertEquals(HttpStatus.BAD_GATEWAY, response.getStatusCode());
        Map<?, ?> body = (Map<?, ?>) response.getBody();
        assertEquals("EMAIL_DELIVERY_FAILED", body.get("code"));
        assertEquals(
                "No fue posible enviar el correo de verificación. La cuenta no fue creada.",
                body.get("message")
        );
        assertFalse(body.toString().contains("provider details"));
    }

    @Test
    void unexpectedFailureReturnsJsonWithLogCorrelationId() {
        AuthService authService = mock(AuthService.class);
        when(authService.registerApp(any()))
                .thenThrow(new IllegalStateException("database password"));
        AuthController controller = new AuthController();
        ReflectionTestUtils.setField(controller, "authService", authService);

        var response = controller.registerApp(null);

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        Map<?, ?> body = (Map<?, ?>) response.getBody();
        assertEquals("REGISTRATION_INTERNAL_ERROR", body.get("code"));
        assertNotNull(body.get("errorId"));
        assertFalse(body.toString().contains("database password"));
    }
}
