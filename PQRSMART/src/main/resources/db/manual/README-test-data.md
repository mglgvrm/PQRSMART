# Datos ficticios de PQRSMART (solo desarrollo local)

El cargador opt-in `testdata` crea exactamente diez cuentas `USER` y veinte
solicitudes ficticias. Requiere el esquema y los catálogos existentes y el
GeoJSON oficial en `geo/villanueva-bolivar.geojson`. No crea tablas, no aplica
migraciones y rechaza conexiones que no sean a `localhost`/loopback o a las
bases permitidas `pqrsmartdb`, `pqrsmart_dev` y `pqrsmart_test`.

Desde la carpeta del backend, ejecuta:

```powershell
.\mvnw.cmd "-Dspring-boot.run.profiles=testdata" "-Dspring-boot.run.arguments=--spring.datasource.url=jdbc:postgresql://localhost:5432/pqrsmartdb --spring.main.web-application-type=none --spring.jpa.hibernate.ddl-auto=none --spring.ai.openai.api-key=test-data-seed-no-network --pqrsmart.test-data.enabled=true" spring-boot:run
```

La ejecución requiere acceso local a PostgreSQL y que existan los catálogos
utilizados por la aplicación. La contraseña inicial compartida es
`PqrTest!2026`; se codifica con el `PasswordEncoder` configurado. La clave
`test-data-seed-no-network` solo permite inicializar Spring AI durante la carga;
el cargador no llama al asistente. No reutilices la contraseña de prueba
fuera de datos descartables. Para sustituirla, define la
propiedad `pqrsmart.test-data.password` en la configuración local de Spring.
El proceso imprime cantidades verificadas; si falla una precondición,
interrumpe la carga y revierte la transacción.

La carga es idempotente: la segunda ejecución valida los mismos registros sin
duplicarlos. Las solicitudes se marcan con el prefijo `TEST DATA - PQRSMART.`
y los radicados `TEST-PQRSMART-20261119-01` a `-20`; las cuentas usan
`pqrsmart_test_01` a `pqrsmart_test_10` y correos `@example.invalid`.
Los nombres, teléfonos e identificaciones son valores ficticios.

Para ver los mapas, inicia el backend normalmente con la configuración de
desarrollo habitual y abre el Dashboard de administrador. Las solicitudes
marcadas participan en el heatmap junto con cualquier otra solicitud real que
ya tenga coordenadas y cumpla los filtros; el mapa solo entrega celdas
agregadas, no datos personales.

Para eliminar únicamente los datos de esta carga, revisa y ejecuta
[`cleanup_pqrsmart_test_data.sql`](./cleanup_pqrsmart_test_data.sql) contra la
misma base local. El script elimina solo solicitudes que cumplen conjuntamente
el prefijo de radicado, el marcador de descripción, la cuenta y el correo
ficticios. Luego elimina esas cuentas solo si no tienen ninguna otra solicitud
asociada. No uses el script contra producción.
