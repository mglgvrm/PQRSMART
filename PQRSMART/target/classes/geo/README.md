# Límite municipal de Villanueva, Bolívar

`villanueva-bolivar.geojson` es una entidad `Polygon` del servicio municipal
de límites publicado por el Instituto Geográfico Agustín Codazzi (IGAC).
El recurso se consultó el 19 de noviembre de 2026 con el filtro DIVIPOLA
`MpCodigo = 13873`; el servicio devolvió `MpNombre = Villanueva`.

- Capa oficial IGAC: [Municipios / FeatureServer/0](https://services2.arcgis.com/RVvWzU3lgJISqdke/arcgis/rest/services/Municipios/FeatureServer/0)
- Consulta exacta GeoJSON: [DIVIPOLA 13873, WGS84](https://services2.arcgis.com/RVvWzU3lgJISqdke/arcgis/rest/services/Municipios/FeatureServer/0/query?where=MpCodigo%3D%2713873%27&outFields=MpCodigo%2CMpNombre%2CMpArea%2CMpNorma&returnGeometry=true&outSR=4326&f=geojson)
- Sistema de coordenadas guardado: WGS 84 / EPSG:4326.
- Feature source attributes: `MpCodigo`, `MpNombre`, `MpArea`, `MpNorma`.

La capa indicada inicialmente (`sigi.igac.gov.co/dip/rest/services/Limites/MapServer/0`)
no contiene este municipio: sus consultas por nombre solo devolvieron
Villanueva, La Guajira y el servicio se describe como una capa de municipios
priorizados. Por eso se usó la capa municipal nacional del IGAC, verificando el
código 13873 antes de descargar la geometría. No se generaron vértices a mano.
