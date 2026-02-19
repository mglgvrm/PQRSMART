import React, { useEffect, useState } from "react";
import "../Admin/GestionUsuario.css";
import axios from "axios";
import Popup from "../../componentes/Popup";
import ModificarUsuario from "../TablasCuadroVerModi/ModificarUsuario.jsx";
import { HeaderAdmin } from "../../componentes/Inicio/Header.jsx";

const GestionUsuario = () => {
  const [data, setData] = useState([]);
  const [showPopup, setShowPopup] = useState(false);
  const [show, setShow] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null); // Estado para el usuario seleccionado
  const [error, setError] = useState("");
  const token = localStorage.getItem("token");
  const [filterText, setFilterText] = useState("");
  const [currentPage, setCurrentPage] = useState(0);
  const usuariosPorPagina = 6;

  const fetchData = async () => {
    try {
      const response = await axios.get("/api/Usuario/get", {
        Authorization: `Bearer ${token}`,
      });
      setData(response.data);
    } catch (error) {
      console.error("Error en la data: ", error);
    }
  };

  const handleCancel = async (id) => {
    try {
      await axios.patch(`/api/Usuario/cancel/${id}`);
      fetchData();
      setError("Usuario Bloqueado.");
      setShow(true);
    } catch (error) {
      console.error("Error al desactivar el usuario: ", error);
      setError("Error al guardar información.");
      setShow(true);
    }
  };

  const handleActivate = async (id) => {
    try {
      const response = await axios.patch(
        `/api/Usuario/activate/${id}`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        },
      );
      console.log("Usuario activado", response.data);
      fetchData();
      setError("Usuario Activado.");
      setShow(true);
    } catch (error) {
      console.error("Error al Activar el usuario: ", error);
      setError("Error al guardar información.");
      setShow(true);
    }
  };

  const handleEditUser = (user) => {
    setSelectedUser(user); // Establece el usuario seleccionado
    console.log(user);
    setShowPopup(true); // Abre el popup
  };

  const handleSaveUser = async (updatedUser) => {
    // Aquí puedes hacer la lógica para guardar el usuario

    const update = updatedUser;
    console.log("Usuario guardado:", update);

    try {
      await axios.put(`/api/Usuario/Update`, update);
      fetchData();
      setShowPopup(false);
      console.log("Usuario guardado:", updatedUser);
      setError("Usuario guardado.");
      setShow(true);
      fetchData(); // Actualiza la tabla con los datos modificados
    } catch (error) {
      console.error("Error al guardar el usuario: ", error);
      setError("Error al guardar el usuario");
      setShow(true);
    }
  };

  useEffect(() => {
    document.title = "Gestionar Usuarios";
    fetchData();
  }, []);

  const filtered = data.filter(
    (item) =>
      String(item.user).toLowerCase().includes(filterText.toLowerCase()) ||
      String(item.name).toLowerCase().includes(filterText.toLowerCase()) ||
      String(item.lastName).toLowerCase().includes(filterText.toLowerCase()) ||
      String(item.identificationNumber)
        .toLowerCase()
        .includes(filterText.toLowerCase()) ||
      String(item.role).toLowerCase().includes(filterText.toLowerCase()) ||
      String(item.stateUser.state)
        .toLowerCase()
        .includes(filterText.toLowerCase()),
  );

  const paginacion = filtered.slice(
    currentPage * usuariosPorPagina,
    (currentPage + 1) * usuariosPorPagina,
  );

  const totalPaginas = Math.ceil(filtered.length / usuariosPorPagina);

  const closePopup = () => {
    setShow(false);
  };
  return (
    <div className="GestionUsuario">
      <HeaderAdmin />
      <div className="cuerpos-GestionUsuario">
        <div className="tabla-usuario-admin">
          <h2>Lista de Usuarios</h2>

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
                <th>Usuario</th>
                <th>Nombre</th>
                <th>Apellido</th>
                <th>Identificación</th>
                <th>Rol</th>
                <th>Estado</th>
                <th>Accion</th>
              </tr>
            </thead>
            <tbody>
              {paginacion.length > 0 ? (
                paginacion.map((user) => (
                  <tr key={user.id}>
                    <td>{user.user}</td>
                    <td>{user.name}</td>
                    <td>{user.lastName}</td>
                    <td>{user.identificationNumber}</td>
                    <td>{user.role}</td>
                    <td>
                      <span
                        className={`estado ${user.stateUser?.state?.toLowerCase()}`}
                      >
                        {user.stateUser?.state === "ACTIVO" ? "✔️" : "❌"}
                      </span>
                      {user.stateUser?.state}
                    </td>
                    <td>
                      <span
                        className="activar"
                        onClick={() => handleActivate(user.id)}
                      >
                        {"✔️"}
                      </span>
                      <span
                        className="activar"
                        onClick={() => handleCancel(user.id)}
                      >
                        {"❌"}
                      </span>

                      <span
                        className="activar"
                        onClick={() => handleEditUser(user)}
                      >
                        {"🔎"}
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
      {showPopup && (
        <ModificarUsuario
          isOpen={showPopup}
          onClose={() => setShowPopup(false)}
          usuario={selectedUser}
          onSave={handleSaveUser}
        />
      )}
      {show && <Popup message={error} onClose={closePopup} />}
    </div>
  );
};

export default GestionUsuario;
