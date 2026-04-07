"use client";
import api from "@/app/api/api";
import { use, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { FaEye, FaEyeSlash } from "react-icons/fa";
import Popup from "./Popup";

type FormData = {
  name: string;
  lastName: string;
  user: string;
  email: string;
  password: string;
  number: string;
  role: string;
  personType: { idPersonType: number }; // Enviar el objeto completo,
  identificationType: { idIdentificationType: number }; // Enviar el objeto completo
  dependence: { idDependence: number }; // Enviar el objeto completo,
  identificationNumber: number;
};

export default function AddUserModal({
  onClose,
  onSave,
}: {
  onClose: () => void;
  onSave?: (data: FormData) => void;
}) {
  const { t } = useTranslation("common");
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [identificationTypes, setIdentificationTypes] = useState([]);
  const [personTypes, setPersonTypes] = useState([]);
  const [dependence, setDependence] = useState([]);
  const [showPopup, setShowPopup] = useState(false);
  const [error, setError] = useState("");
  const [formData, setFormData] = useState<FormData>({
    name: "",
    email: "",
    user: "",
    lastName: "",
    role: "",
    number: "",
    password: "",
    personType: { idPersonType: 0 },
    identificationType: { idIdentificationType: 0 },
    dependence: { idDependence: 0 },
    identificationNumber: 0,
  });
  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>,
  ) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };
  const togglePasswordVisibility = () => {
    setPasswordVisible(!passwordVisible);
  };
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Datos del usuario:", formData);
    if (onSave) onSave(formData);

    onClose(); // Cierra el modal después de guardar
  };

  useEffect(() => {
    const fetchIdentificationTypes = async () => {
      try {
        const response = await api.get("/identification_type/get");
        console.log("Tipos de identificación obtenidos:", response.data);
        setIdentificationTypes(response.data);
      } catch (error) {
        console.error(
          "Error al obtener tipos de identificación de la base de datos",
          error,
        );
      }
    };

    const fetchPersonTypes = async () => {
      try {
        const response = await api.get("/person_type/get");
        console.log("Tipos de persona obtenidos:", response.data);
        setPersonTypes(response.data);
      } catch (error) {
        console.error(
          "Error al obtener tipos de persona de la base de datos",
          error,
        );
      }
    };

    const fetchDependence = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token)
          return console.error("No se encontró el token de autenticación");
        const response = await api.get("/dependence/get", {
          headers: { Authorization: `Bearer ${token}` },
        });
        console.log("Dependencias obtenidas:", response.data);
        setDependence(response.data);
      } catch (error) {
        console.error(
          "Error al obtener dependencias de la base de datos",
          error,
        );
      }
    };

    fetchIdentificationTypes();
    fetchPersonTypes();
    fetchDependence();
  }, []);

  const closePopup = () => {
    setShowPopup(false);
  };
  return (
    <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50  ">
      {/* Contenedor del modal */}
      <div className="bg-white rounded-2xl shadow-xl w-96 p-6 relative animate-fade-in scroll-smooth">
        {/* Botón para cerrar */}
        <button
          onClick={onClose}
          className="absolute top-3 right-3 text-gray-400 hover:text-gray-600 text-lg"
        >
          ✕
        </button>

        {/* Contenido del modal */}
        <h2 className="text-xl font-semibold text-gray-800 mb-4">Add User</h2>

        <form
          onSubmit={handleSubmit}
          className="space-y-6 scrollbar-track-gray-100 overflow-y-auto max-h-[800px]"
        >
          <div className="relative">
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.name_label")}
            </label>
          </div>

          <div className="relative">
            <input
              type="text"
              name="lastName"
              value={formData.lastName}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.lastname_label")}
            </label>
          </div>

          {/* Correo */}
          <div className="relative">
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.email_label")}
            </label>
          </div>
          {/* user */}
          <div className="relative">
            <input
              type="user"
              name="user"
              value={formData.user}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.user_label")}
            </label>
          </div>
          {/* Número */}
          <div className="relative">
            <input
              type="number"
              name="number"
              value={formData.number}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.phone_label")}
            </label>
          </div>

          {/* Contraseña */}
          <div className="relative">
            <input
              type={passwordVisible ? "text" : "password"}
              name="password"
              value={formData.password}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.password_label")}
            </label>

            <span onClick={togglePasswordVisibility}>
              {passwordVisible ? <FaEye /> : <FaEyeSlash />}
            </span>
          </div>

          {/* Tipo de Persona */}
          <div className="relative">
            <select
              name="personType"
              value={formData.personType.idPersonType}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400 "
              required
            >
              <option key="" value="0" disabled hidden>
                {t("register.typePerson_placeholder")}
              </option>
              {personTypes.map((type: any) => (
                <option key={type.idPersonType} value={type.idPersonType}>
                  {type.namePersonType}
                </option>
              ))}
            </select>
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.typePerson_label")}
            </label>
          </div>

          {/* Tipo de Identificación */}
          <div className="relative">
            <select
              name="identificationType"
              value={formData.identificationType.idIdentificationType}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400 "
              required
            >
              <option key="" value="0" disabled hidden>
                {t("register.typeIdentification_placeholder")}
              </option>
              {identificationTypes.map((type: any) => (
                <option
                  key={type.idIdentificationType}
                  value={type.idIdentificationType}
                >
                  {type.nameIdentificationType}
                </option>
              ))}
            </select>
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.typeIdentification_label")}
            </label>
          </div>

          {/* Número de Identificación */}
          <div className="relative">
            <input
              type="number"
              name="identificationNumber"
              value={formData.identificationNumber}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400"
              required
            />
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              {t("register.identificationNumber_label")}
            </label>
          </div>

          {/* Rol */}
          <div className="relative">
            <select
              name="role"
              value={formData.role}
              onChange={handleChange}
              className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400 "
              required
            >
              <option value="" disabled hidden></option>
              <option value="ADMIN">Admin</option>
              <option value="USER">User</option>
              <option value="SECRE">SECRE</option>
            </select>
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              Role
            </label>
          </div>
          {formData.role === "SECRE" ? (
            /* Dependence */
            <div className="relative">
              <select
                name="dependence"
                value={formData.dependence.idDependence}
                onChange={handleChange}
                className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400 "
                required
              >
                <option value="0" disabled hidden>
                  seleccione una dependencia
                </option>
                {dependence.map((type: any) => (
                  <option key={type.idDependence} value={type.idDependence}>
                    {type.nameDependence}
                  </option>
                ))}
              </select>
              <label
                className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
              >
                Dependence
              </label>
            </div>
          ) : (
            <div className="relative">
              <select
                name="dependence"
                value={formData.dependence.idDependence || 7}
                onChange={handleChange}
                className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400 "
              >
                <option value={7}>N/A</option>
              </select>
              <label
                className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
              >
                Dependence
              </label>
            </div>
          )}

          <button
            type="submit"
            className="w-full bg-green-500 text-white py-2 rounded-md hover:bg-green-600 transition"
          >
            Save
          </button>
        </form>
      </div>
      {showPopup && <Popup message={error} onClose={closePopup} />}
    </div>
  );
}
