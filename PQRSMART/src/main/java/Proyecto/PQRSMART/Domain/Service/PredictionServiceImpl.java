package Proyecto.PQRSMART.Domain.Service;

import Proyecto.PQRSMART.Domain.Dto.PredictionResponseDTO;
import Proyecto.PQRSMART.Persistence.Entity.Request;
import Proyecto.PQRSMART.Persistence.Entity.Dependence;
import Proyecto.PQRSMART.Persistence.Repository.RequestRepository;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.YearMonth;

import java.util.*;
import java.util.stream.Collectors;

    @Service
    @RequiredArgsConstructor
    public class PredictionServiceImpl {

        private final RequestRepository requestRepository;

        private static final int MESES_ANALISIS = 6;
        private static final int SIMULACIONES = 20000;

        private static final Random RANDOM = new Random();

        private static class DatosDependencia {

            Long id;
            String nombre;

            Map<YearMonth, Double> historial = new TreeMap<>();

            double prediccion;
            double desviacion;

            DatosDependencia(Long id, String nombre) {
                this.id = id;
                this.nombre = nombre;
            }
        }

        @Transactional(readOnly = true)
        public PredictionResponseDTO predecirDependencia() {

            YearMonth mesActual = YearMonth.now();

            // Último mes que ya terminó.
            YearMonth ultimoMesCompleto = mesActual.minusMonths(1);

            // No incluir solicitudes del mes actual incompleto.
            LocalDate fechaLimite =
                    mesActual.atDay(1);
            // Mes que queremos predecir.
            YearMonth proximoMes = mesActual.plusMonths(1);

            List<Request> solicitudes =
                    requestRepository.obtenerHistorialPredictivo(fechaLimite);

            if (solicitudes.isEmpty()) {
                throw new IllegalStateException(
                        "No existen solicitudes históricas para realizar la predicción."
                );
            }

            // Agrupar solicitudes por dependencia.
            Map<Long, DatosDependencia> dependencias =
                    new HashMap<>();

            for (Request solicitud : solicitudes) {

                Dependence dependencia =
                        solicitud.getDependence();

                if (dependencia == null ||
                    dependencia.getIdDependence() == null ||
                    solicitud.getDate() == null) {
                    continue;
                }

                Long id = dependencia.getIdDependence();

                DatosDependencia datos =
                        dependencias.computeIfAbsent(
                                id,
                                key -> new DatosDependencia(
                                        id,
                                        dependencia.getNameDependence()
                                )
                        );

                YearMonth mes =
                        YearMonth.from(solicitud.getDate());

                datos.historial.merge(
                        mes,
                        1.0,
                        Double::sum
                );
            }

            if (dependencias.isEmpty()) {
                throw new IllegalStateException(
                        "No se encontraron dependencias válidas."
                );
            }

            // Crear los últimos seis meses completos.
            List<YearMonth> meses = new ArrayList<>();

            for (int i = MESES_ANALISIS - 1; i >= 0; i--) {

                meses.add(
                        ultimoMesCompleto.minusMonths(i)
                );
            }

            // Entrenar el modelo de cada dependencia.
            for (DatosDependencia datos : dependencias.values()) {

                double[] valores = new double[MESES_ANALISIS];

                for (int i = 0; i < MESES_ANALISIS; i++) {

                    valores[i] = datos.historial.getOrDefault(
                            meses.get(i),
                            0.0
                    );
                }

                long horizonte = java.time.temporal.ChronoUnit.MONTHS.between(
                        ultimoMesCompleto,
                        proximoMes
                );

                double[] resultado = calcularRegresion(
                        valores,
                        (int) horizonte
                );

                datos.prediccion = resultado[0];
                datos.desviacion = resultado[1];
            }

            // Simular cuál dependencia tendrá más solicitudes.
            Map<Long, Integer> victorias =
                    new HashMap<>();

            for (DatosDependencia datos : dependencias.values()) {
                victorias.put(datos.id, 0);
            }

            List<DatosDependencia> lista =
                    new ArrayList<>(dependencias.values());

            for (int i = 0; i < SIMULACIONES; i++) {

                DatosDependencia ganadora = null;
                double mayorCantidad = -1;

                for (DatosDependencia datos : lista) {

                    double cantidad =
                            datos.prediccion +
                            RANDOM.nextGaussian() * datos.desviacion;

                    cantidad = Math.max(0, cantidad);

                    if (ganadora == null ||
                        cantidad > mayorCantidad) {

                        mayorCantidad = cantidad;
                        ganadora = datos;
                    }
                }

                victorias.merge(
                        ganadora.id,
                        1,
                        Integer::sum
                );
            }

            // Seleccionar la dependencia con mayor probabilidad.
            DatosDependencia ganadora = lista.stream()
                    .max(Comparator.comparingInt(
                            d -> victorias.get(d.id)
                    ))
                    .orElseThrow();

            double probabilidad =
                    victorias.get(ganadora.id) * 100.0 /
                    SIMULACIONES;

            probabilidad =
                    Math.round(probabilidad * 100.0) / 100.0;



            String periodo =
                    proximoMes.toString();

            String nombreMes =
                    proximoMes.getMonth()
                            .getDisplayName(
                                    java.time.format.TextStyle.FULL,
                                    new Locale("es", "CO")
                            );

            String mensaje =
                    "Se estima que " +
                    ganadora.nombre +
                    " será la dependencia con mayor cantidad de solicitudes " +
                    "durante " + nombreMes +
                    " de " + proximoMes.getYear() +
                    ", con una probabilidad estimada del " +
                    probabilidad + "%.";

            return PredictionResponseDTO.builder()
                    .dependencia(ganadora.nombre)
                    .probabilidad(probabilidad)
                    .periodo(periodo)
                    .mensaje(mensaje)
                    .build();
        }

        private double[] calcularRegresion(
                double[] valores,
                int horizonte) {

            int n = valores.length;

            double sumaX = 0;
            double sumaY = 0;
            double sumaXY = 0;
            double sumaX2 = 0;

            for (int i = 0; i < n; i++) {

                double x = i + 1;
                double y = valores[i];

                sumaX += x;
                sumaY += y;
                sumaXY += x * y;
                sumaX2 += x * x;
            }

            double denominador =
                    n * sumaX2 - sumaX * sumaX;

            double pendiente =
                    denominador == 0 ? 0 :
                            (n * sumaXY - sumaX * sumaY) /
                            denominador;

            double intercepto =
                    (sumaY - pendiente * sumaX) / n;

            double prediccion =
                    intercepto + pendiente * (n + horizonte);

            // Calcular error histórico de la regresión.
            double sumaErrores = 0;

            for (int i = 0; i < n; i++) {

                double estimado =
                        intercepto + pendiente * (i + 1);

                double error =
                        valores[i] - estimado;

                sumaErrores += error * error;
            }

            double desviacion =
                    Math.sqrt(sumaErrores / Math.max(1, n - 2));

            // Evitar una desviación igual a cero.
            desviacion = Math.max(
                    desviacion,
                    0.5
            );

            return new double[] {
                    Math.max(0, prediccion),
                    desviacion
            };
        }
    }