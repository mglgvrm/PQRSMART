import React, { useEffect, useState } from "react";
import "../Admin/GestionDependencia.css";
import axios from "axios";
import Popup from "../../componentes/Popup";
import { HeaderAdmin } from "../../componentes/Inicio/Header";

const GestionDependencia = () => {
  const [data, setData] = useState([]);
  const [showPopup, setShowPopup] = useState(false);
  const [error, setError] = useState("");
  const [filterText, setFilterText] = useState(""); // Estado para el texto de búsqueda
  const [currentPage, setCurrentPage] = useState(0);
  const usuariosPorPagina = 6; // Cambia esto para ajustar cuántos usuarios mostrar por página

  const fetchData = async () => {
    try {
      const response = await axios.get("/api/dependence/get");
      setData(response.data);
      console.log(response.data);
    } catch (error) {
      console.error("Error en la data: ", error);
    }
  };

  useEffect(() => {
    document.title = "Gestion de Dependencias";
    fetchData();
  }, []);

  const handleCancel = async (idDependence) => {
    try {
      await axios.put(`/api/dependence/cancel/${idDependence}`);
      // Actualizar la tabla después de cancelar la solicitud
      console.log("Dependencia desactivada", idDependence);
      setError("Dependencia Desactivada.");
      setShowPopup(true); // Mostrar popup
      fetchData();
      return;
    } catch (error) {
      console.error("Error al eliminar la dependencia: ", error);
      setError("Error al guardar información.");
      setShowPopup(true); // Mostrar popup
      return;
    }
  };
  const handleActivate = async (idDependence) => {
    try {
      await axios.put(`/api/dependence/activate/${idDependence}`);
      // Actualizar la tabla después de cancelar la solicitud
      console.log("Dependencia activada", idDependence);
      setError("Dependencia Activada.");
      setShowPopup(true); // Mostrar popup
      fetchData();
      return;
    } catch (error) {
      console.error("Error al eliminar la dependencia: ", error);
      setError("Error al guardar información.");
      setShowPopup(true); // Mostrar popup
      return;
    }
  };
  const filtered = data.filter(
    (item) =>
      String(item.nameDependence)
        .toLowerCase()
        .includes(filterText.toLowerCase()) ||
      String(item.state.description)
        .toLowerCase()
        .includes(filterText.toLowerCase()),
  );
  const paginacion = filtered.slice(
    currentPage * usuariosPorPagina,
    (currentPage + 1) * usuariosPorPagina,
  );

  const totalPaginas = Math.ceil(filtered.length / usuariosPorPagina);

  const closePopup = () => {
    setShowPopup(false);
  };
  return (
    <div className="GestionDependencia">
      <HeaderAdmin />
      <div className="cuerpos-GestionDependencia">
        <div className="tabla-dependencia">
          <h2>Lista de Dependencias</h2>

          <div className="buscador-usuario">
            <input
              type="text"
              placeholder="Buscar en la tabla..."
              value={filterText}
              onChange={(e) => setFilterText(e.target.value)}
              className="buscador"
            />
            <img
              src="/images/search.svg"
              alt="Buscar"
              className="icono-busqueda"
            />
          </div>

          <table className="tabla-minimalista-usuario">
            <thead>
              <tr>
                <th onClick={() => ordenarPor("dependencia")}>Dependencia</th>
                <th onClick={() => ordenarPor("estado.description")}>Estado</th>
                <th onClick={() => ordenarPor("accion")}>Accion</th>
              </tr>
            </thead>
            <tbody>
              {paginacion.length > 0 ? (
                paginacion.map((dependence) => (
                  <tr key={dependence.idDependence}>
                    <td>{dependence.nameDependence}</td>
                    <td>
                      <span
                        className={`estado ${dependence.state?.description?.toLowerCase()}`}
                      >
                        {dependence.state?.description === "ACTIVADO"
                          ? "✔️"
                          : "❌"}
                      </span>
                      {dependence.state?.description}
                    </td>
                    <td>
                      <span
                        className="activar"
                        onClick={() => handleActivate(dependence.idDependence)}
                      >
                        {"✔️"}
                      </span>
                      <span
                        className="activar"
                        onClick={() => handleCancel(dependence.idDependence)}
                      >
                        {"❌"}
                      </span>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" style={{ textAlign: "center" }}>
                    No hay datos disponibles
                  </td>
                </tr>
              )}
            </tbody>
          </table>

          <div className="paginacion">
            <button
              onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 0))}
              disabled={currentPage === 0}
            >
              Anterior
            </button>
            <span>
              {currentPage + 1} de {totalPaginas}
            </span>
            <button
              onClick={() =>
                setCurrentPage((prev) => Math.min(prev + 1, totalPaginas - 1))
              }
              disabled={currentPage >= totalPaginas - 1}
            >
              Siguiente
            </button>
          </div>
        </div>
      </div>
      {showPopup && <Popup message={error} onClose={closePopup} />}
    </div>
  );
};

export default GestionDependencia;
