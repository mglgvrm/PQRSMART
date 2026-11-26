package Proyecto.PQRSMART.Domain.Service;

public class EmailDeliveryException extends RuntimeException {
    public EmailDeliveryException(Throwable cause) {
        super("No fue posible enviar el correo de verificación.", cause);
    }

    public EmailDeliveryException(String message, Throwable cause) {
        super(message, cause);
    }
}
