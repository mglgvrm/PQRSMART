# PQRSMART backend

## PostgreSQL

Spring Boot escucha por defecto en el puerto `8080` y conecta a
`jdbc:postgresql://localhost:5432/pqrsmartdb`. Configura las credenciales
fuera del código con `DB_URL`, `DB_USERNAME` y `DB_PASSWORD`. En IntelliJ IDEA,
decláralas en **Run/Debug Configurations → Environment variables**. Para
ejecutar desde PowerShell:

```powershell
$env:DB_URL = 'jdbc:postgresql://localhost:5432/pqrsmartdb'
$env:DB_USERNAME = 'postgres'
$env:DB_PASSWORD = '<contraseña-local-de-PostgreSQL>'
.\mvnw.cmd spring-boot:run
```

La base de datos `pqrsmartdb` debe existir antes de iniciar la aplicación. Para
comprobar la conexión con el cliente de PostgreSQL:

```powershell
psql -h localhost -p 5432 -U postgres -d pqrsmartdb -c "select current_database();"
```

Se conserva `spring.jpa.hibernate.ddl-auto: update`. Los campos GIS nuevos son
opcionales, por lo que las solicitudes históricas siguen siendo válidas sin
coordenadas. Para aplicar el cambio de forma controlada, revisa y ejecuta el
script aditivo:

```powershell
psql -h localhost -p 5432 -U postgres -d pqrsmartdb `
  -f .\src\main\resources\db\manual\V1__request_geolocation.sql
```

El script resuelve la tabla de solicitudes existente por nombre (incluido el
espacio final histórico de la anotación JPA), agrega columnas nullable y no
altera ni elimina registros. También relaja (sin borrar valores existentes) la
restricción `NOT NULL` de la referencia al usuario ciudadano para permitir
solicitudes asistidas de personas sin cuenta. Verifica primero el esquema y el
respaldo de tu base real. Hibernate también puede crear las columnas al
iniciar, conforme a la configuración previa.

## Datos geográficos de PQRS

Las solicitudes admiten latitud, longitud, fuente (`GPS`, `MANUAL` o
`FUNCIONARIO`), método de captura, descripción del lugar, fecha de captura y
datos mínimos para ciudadanos sin cuenta (nombre y contacto opcional). La
identidad del funcionario se toma del token autenticado, nunca del cuerpo del
cliente. El secretario solo puede registrar solicitudes para su propia
dependencia.

El límite oficial se debe instalar como GeoJSON `Polygon` o `MultiPolygon`
WGS84/EPSG:4326 en:

```text
src/main/resources/geo/villanueva-bolivar.geojson
```

No se incluye una geometría aproximada. Hasta que exista ese archivo, el
servicio indica que el límite no está disponible, impide guardar coordenadas
sin validación municipal y no genera mapa de calor.
Al instalar el archivo, documenta junto a él la fuente oficial, la fecha de
descarga/edición, el sistema EPSG y la licencia de uso.

Rutas autenticadas:

- `GET /api/request/geo/municipality`: límite oficial para renderizarlo en
  Flutter.
- `GET /api/request/geo/heatmap`: solo administrador; acepta `from`, `to`,
  `requestTypeId` y `requestStateId`. Devuelve celdas agregadas (resolución
  0.01 grados), conteos por tipo/estado y el periodo; nunca devuelve puntos
  individuales ni datos personales.
- `POST /api/request/save`: conserva el flujo ciudadano existente y acepta
  ubicación GPS/manual validada.
- `POST /api/request/save/assisted`: administrador o secretario; registra un
  ciudadano sin cuenta, y conserva al funcionario autenticado como registrador.

## Claves de servicios externos

Las claves externas no son necesarias para iniciar el backend:

- `GROQ_API_KEY` habilita el chat con IA.
- El SDK de correo configurado es Brevo. `BREVO_API_KEY` habilita el envío de
  correos; `RESEND_API_KEY` se admite como nombre anterior por compatibilidad.

Sin esas claves las funciones externas no podrán completar sus llamadas, pero
los servicios REST y la conexión a PostgreSQL pueden arrancar.
