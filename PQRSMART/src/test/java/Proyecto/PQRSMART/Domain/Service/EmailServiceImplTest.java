package Proyecto.PQRSMART.Domain.Service;

import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class EmailServiceImplTest {
    @Test
    void missingMailApiKeyFailsBeforeMakingAnExternalRequest() {
        EmailServiceImpl service = new EmailServiceImpl();
        ReflectionTestUtils.setField(service, "brevoApiKey", "");

        EmailDeliveryException error = assertThrows(
                EmailDeliveryException.class,
                () -> service.sendEmails(
                        new String[]{"test@example.invalid"},
                        "Prueba",
                        "Contenido de prueba"
                )
        );

        assertTrue(error.getMessage().contains("Configure BREVO_API_KEY"));
    }
}
