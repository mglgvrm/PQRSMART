package Proyecto.PQRSMART.Domain.Service;


import Proyecto.PQRSMART.Domain.Dto.RequestDTO;
import Proyecto.PQRSMART.Domain.Service.Interfaces.PdfServices;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Entity.User;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.io.ByteArrayOutputStream;

@Service
@RequiredArgsConstructor
public class PdfServicesImpl implements PdfServices {
    private final TemplateEngine templateEngine;

    public byte[] generarPdfSolicitud(User user, Request request) {

        try {
            Context context = getContext(user, request);

            String htmlContent = templateEngine.process("pdf/solicitud", context);

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.withHtmlContent(htmlContent, null);
            builder.toStream(outputStream);
            builder.run();

            return outputStream.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Error generando PDF", e);
        }
    }

    private static Context getContext(User user, Request request) {
        Context context = new Context();
        context.setVariable("radicado", request.getIdRequest());
        context.setVariable("fecha", request.getDate().toString());
        System.out.println("fecha "+ request.getDate().toString());
        context.setVariable("usuario", user.getName());
        context.setVariable("tipo", request.getRequestType().getNameRequestType());
        context.setVariable("categoria", request.getCategory().getNameCategory());
        context.setVariable("estado", request.getRequestState().getNameRequestState());
        context.setVariable("descripcion", request.getDescription());

        return context;
    }
}
