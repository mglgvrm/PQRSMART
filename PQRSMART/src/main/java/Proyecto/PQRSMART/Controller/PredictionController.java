package Proyecto.PQRSMART.Controller;



import Proyecto.PQRSMART.Domain.Dto.PredictionResponseDTO;
import Proyecto.PQRSMART.Domain.Service.PredictionServiceImpl;
import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/Prediction")
@RequiredArgsConstructor
@CrossOrigin
public class PredictionController {

    private final PredictionServiceImpl predictionService;

    @GetMapping("/dependencias")
    public ResponseEntity<PredictionResponseDTO> predecirDependencia() {

        PredictionResponseDTO resultado =
                predictionService.predecirDependencia();

        return ResponseEntity.ok(resultado);
    }
}