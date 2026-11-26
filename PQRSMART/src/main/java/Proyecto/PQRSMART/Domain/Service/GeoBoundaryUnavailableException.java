package Proyecto.PQRSMART.Domain.Service;

public class GeoBoundaryUnavailableException extends RuntimeException {
    public GeoBoundaryUnavailableException(String message) {
        super(message);
    }

    public GeoBoundaryUnavailableException(String message, Throwable cause) {
        super(message, cause);
    }
}
