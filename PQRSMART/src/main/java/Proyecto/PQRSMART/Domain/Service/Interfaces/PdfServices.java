package Proyecto.PQRSMART.Domain.Service.Interfaces;

import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Entity.User;

public interface PdfServices {
    public byte[] generarPdfSolicitud(User user, RequestDTO request);



}
