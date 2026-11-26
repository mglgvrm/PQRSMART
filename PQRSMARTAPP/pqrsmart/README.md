# pqrsmart

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## PQRSMART: frontend actual

La aplicación Flutter conserva los servicios y modelos existentes. El acceso
dirige a cada persona según las autoridades reales devueltas por
`/api/auth/authenticate`. El backend identifica al secretario como `SECRE`.

El panel administrativo consume las listas existentes de usuarios,
dependencias, categorías y solicitudes. Las solicitudes globales usan
`GET /api/request/get` (solo Administrador); las asignadas a una dependencia
usan `GET /api/request/getForDependence` (solo Secretario); y la respuesta
institucional usa `PUT /api/request/update/{id}`, que en el backend guarda la
respuesta y finaliza la solicitud. Los cambios de estado de usuarios,
dependencias y categorías usan sus operaciones de actualización existentes.

El mapa territorial y el mapa de calor usan `flutter_map` y mosaicos de
OpenStreetMap. El backend expone el límite oficial por
`GET /api/request/geo/municipality` y la agregación administrativa por
`GET /api/request/geo/heatmap` (filtros de fecha, tipo y estado). El mapa de
calor solo recibe celdas agregadas, nunca coordenadas individuales ni datos
personales. El usuario puede filtrar el mapa y consultar el resumen de una
celda.

La captura de ubicación se activa únicamente al pulsar GPS o selección manual.
El permiso es de primer plano; si se deniega se puede intentar la selección
manual. Funcionarios y secretarios pueden registrar solicitudes para personas
sin cuenta; el secretario queda limitado a su dependencia y su identidad se
guarda desde la sesión autenticada. Las solicitudes antiguas y los registros
nuevos sin coordenadas continúan siendo válidos.

**Pendiente de fuente geográfica:** todavía no se encontró un GeoJSON oficial
verificable de Villanueva, Bolívar. No se dibujan contornos aproximados ni se
guardan coordenadas que no puedan validarse. Para habilitar mapas, captura GPS
y selección manual se requiere el GeoJSON oficial WGS84/EPSG:4326 en
`PQRSMART/src/main/resources/geo/villanueva-bolivar.geojson`, con procedencia,
fecha y licencia documentadas.

No se deben generar puntos de solicitudes de prueba para completar el mapa.
Los mosaicos cartográficos requieren conexión a Internet y conservan la
atribución a OpenStreetMap. La geolocalización requiere una acción explícita;
no se hace seguimiento en segundo plano.

### Contratos pendientes para ampliar los módulos

- La solicitud de usuario de edición general debe contar con un `PUT`
  administrativo que actualice los campos permitidos sin reemplazar la
  contraseña ni borrar relaciones omitidas. El mapeo actual de `UsuarioDto` no
  conserva todos esos campos; por eso la interfaz solo cambia el estado de
  cuenta y no presenta una edición general engañosa.
- `DependenceDTO` y `CategoryDTO` solo exponen nombre, estado y la relación
  categoría-dependencia. Sectores, descripciones, responsables y recuentos
  asociados requieren ampliar los DTO/entidades y las operaciones backend.
- `RequestDTO` no expone fecha de actualización ni responsable asignado. El
  detalle administrativo solo muestra los campos presentes; esos datos deben
  añadirse al DTO y al mapeo antes de presentarlos como disponibles.
- No existe un endpoint agregado de estadísticas; los indicadores actuales se
  calculan con los listados reales de usuarios y solicitudes. Si el volumen
  aumenta, conviene exponer estadísticas paginadas/agregadas en backend.

## Conexión Flutter ↔ Spring Boot

En Android Emulator, `localhost` apunta al emulador y no al equipo donde corre
Spring Boot. La aplicación selecciona automáticamente
`http://10.0.2.2:8080/api` en Android nativo; en Flutter Web conserva
`http://localhost:8080/api`. El permiso `INTERNET` está declarado en el
manifest. El tráfico HTTP sin TLS se permite únicamente en el manifest de
debug; para una compilación release se debe usar HTTPS.

Para un teléfono físico u otro servidor, especifica la IP/URL accesible desde
ese dispositivo:

```sh
flutter run --dart-define=PQRSMART_API_URL=http://<host>:8080/api
```

En un teléfono físico `<host>` debe ser la IP LAN del equipo, no `localhost` ni
`10.0.2.2`. El equipo y el teléfono deben estar en la misma red y el firewall
debe permitir el puerto 8080.

Para configurar PostgreSQL y las claves opcionales de Spring Boot, consulta el
[README del backend](../../PQRSMART/README.md).
