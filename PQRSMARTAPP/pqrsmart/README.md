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

La aplicación Flutter conserva los servicios y modelos existentes. La pantalla
de acceso permite seleccionar Usuario, Administrador o Secretario, pero el
destino se decide comparando esa selección con las autoridades reales devueltas
por `/api/auth/authenticate`. El backend identifica al secretario como `SECRE`.

El panel administrativo consume las listas existentes de usuarios,
dependencias, categorías y solicitudes. Las solicitudes globales usan
`GET /api/request/get` (solo Administrador); las asignadas a una dependencia
usan `GET /api/request/getForDependence` (solo Secretario); y la respuesta
institucional usa `PUT /api/request/update/{id}`, que en el backend guarda la
respuesta y finaliza la solicitud. Los cambios de estado de usuarios,
dependencias y categorías usan sus operaciones de actualización existentes.

El dashboard usa OpenStreetMap para el mapa base de Villanueva, Bolívar. Los
mapas muestran controles de desplazamiento y zoom; el mapa de calor queda en
estado informativo hasta disponer de geografía real. El modelo y el DTO actual
de solicitud no contienen coordenadas, por lo que para habilitarlo el backend
deberá:

1. Añadir latitud/longitud opcionales (o una referencia geográfica equivalente)
   a la persistencia, DTO y mapeo de solicitudes, y aceptarlas al registrar una
   PQRS sin hacer obligatoria la ubicación.
2. Exponer un servicio de agregación espacial para el dashboard, con filtros
   temporales/categóricos cuando existan; entregar celdas o zonas agregadas,
   nunca coordenadas exactas de domicilios ciudadanos.
3. Aplicar autorización administrativa y límites de privacidad a ese servicio.

No se deben generar puntos de solicitudes de prueba para completar el mapa.
Los mosaicos cartográficos requieren conexión a Internet y conservan la
atribución a OpenStreetMap.

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

Para apuntar Flutter a otro servidor:

```sh
flutter run --dart-define=PQRSMART_API_URL=http://<host>:8080/api
```
