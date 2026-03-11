"use client";
import api from "@/app/api/api";
import { use, useEffect, useState } from "react";

type FormData = {
  name: string;
  email: string;
  role: string;
  number: string;
  password: string;
  typePqrsId?: string;
};
type PqrsType = {
  id: number;
  name: string;
};

export default function AddUserModal({
  onClose,
  onSave,
}: {
  onClose: () => void;
  onSave?: (data: FormData) => void;
}) {
  const [formData, setFormData] = useState<FormData>({
    name: "",
    email: "",
    role: "",
    number: "",
    password: "",
    typePqrsId: "",
  });
  const [typePqrs, setTypePqrs] = useState<PqrsType[]>([]);
  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (onSave) onSave(formData);
    console.log("Datos del usuario:", formData);
    onClose(); // Cierra el modal después de guardar
  };
  const fetchTypePqrs = async () => {
    try {
      const response = await api.get("/pqrs-type");
      if (response.status === 200) {
        setTypePqrs(response.data);
        console.log(response.data);
      } else console.error("Error al obtener los tipos de pqrs");
    } catch (error) {
      console.error("Error en la solicitud:", error);
    }
  };
  useEffect(() => {
    fetchTypePqrs();
  }, []);
  return (
    <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50 ">
      {/* Contenedor del modal */}
      <div className="bg-white rounded-2xl shadow-xl w-96 p-6 relative animate-fade-in">
        {/* Botón para cerrar */}
        <button
          onClick={onClose}
          className="absolute top-3 right-3 text-gray-400 hover:text-gray-600 text-lg"
        >
          ✕
        </button>

        {/* Contenido del modal */}
        <h2 className="text-xl font-semibold text-gray-800 mb-4">Add User</h2>

        <form onSubmit={handleSubmit} className="space-y-6">
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
              Full Name
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
              Email
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
              Number
            </label>
          </div>

          {/* Contraseña */}
          <div className="relative">
            <input
              type="password"
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
              Password
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
              <option value="admin">Admin</option>
              <option value="user">User</option>
              <option value="secretariat">Secretariat</option>
            </select>
            <label
              className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
            >
              Role
            </label>
          </div>
          {formData.role === "secretariat" ? (
            /* Tipo de PQRS */
            <div className="relative">
              <select
                name="typePqrsId"
                value={formData.typePqrsId}
                onChange={handleChange}
                className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400 "
                required
              >
                <option value="" disabled hidden></option>
                {typePqrs.map((type) => (
                  <option key={type.id} value={type.id}>
                    {type.name}
                  </option>
                ))}
              </select>
              <label
                className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
              >
                Type PQRS
              </label>
            </div>
          ) : (
            <div className="relative">
              <select
                name="typePqrsId"
                className="peer w-full border border-gray-300 rounded-md px-3 pt-5 pb-2 bg-white text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-400 "
                required
              >
                <option value="" disabled hidden></option>
                <option value="">type not allowed</option>
              </select>
              <label
                className="absolute left-3 top-3 text-gray-500 text-base transition-all duration-200 
      peer-focus:top-1 peer-focus:text-sm peer-focus:text-green-600
      peer-valid:top-1 peer-valid:text-sm peer-valid:text-green-600"
              >
                Type PQRS
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
    </div>
  );
}
