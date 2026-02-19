import React, { useEffect, useState } from "react";
import "../Admin/CrearDependencias.css";
import axios from "axios";
import Popup from "../../componentes/Popup";
import { HeaderAdmin } from "../../componentes/Inicio/Header";

const CrearDependencias = () => {
  const [data, setData] = useState([]);
  const [showPopup, setShowPopup] = useState(false);
  const [error, setError] = useState("");
  const [formData, setFormData] = useState({
    dependence: "",
  });

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
    document.title = "Tipos de Dependencia";
    fetchData();
  }, []);
  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleReset = () => {
    setFormData({
      dependence: "",
    });
  };
  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      console.log("Datos del formulario a enviar:", formData);
      await axios.post("/api/dependence/save", {
        nameDependence: formData.dependence,
        state: { id: 1 },
      });
      handleReset();
      fetchData();
      setError("Dependencia registrada correctamente.");
      setShowPopup(true); // Mostrar popup
      return;
    } catch (error) {
      const status = error.response && error.response.status;
      // Manejo de errores
      if (status === 403) {
        setError("Error la dependencia ya se encuentra registrada.");
      } else {
        setError("Error en el servidor. Intente nuevamente más tarde.");
      }
      setShowPopup(true); // Mostrar popup
      return;
    }
  };
  const closePopup = () => {
    setShowPopup(false);
  };

  return (
    <div className="CrearDependencias">
      <HeaderAdmin />
      <div className="cuerpos-creardepe">
        <div className="form-creardepe">
          <form onSubmit={handleSubmit}>
            <h1 className="title-creardepe">CREAR DEPENDENCIA</h1>

            <div className="input-box-creardepe">
              <label htmlFor="dependence">Dependencia:</label>
              <br />
              <input
                type="text"
                id="dependence"
                name="dependence"
                value={formData.dependence}
                onChange={handleChange}
                required
              />
            </div>
            <div className="btnCreardepe">
              <button type="submit">Registrar</button>
            </div>
          </form>
        </div>
      </div>
      {showPopup && <Popup message={error} onClose={closePopup} />}
    </div>
  );
};

export default CrearDependencias;
