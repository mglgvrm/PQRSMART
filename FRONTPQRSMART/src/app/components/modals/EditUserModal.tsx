"use client";
import api from "@/app/api/api";
import { useEffect, useState } from "react";

type User = {
  name: string;
  email: string;
  role: string;
  pqrsType?: { id: number; name: string };
};
type PqrsType = {
  id: number;
  name: string;
};
export default function EditUserModal({
  onClose,
  user,
  onSave,
}: {
  onClose: () => void;
  user?: User;
  onSave?: (data: User) => void;
}) {
  const [formData, setFormData] = useState<User>({
    name: "",
    email: "",
    role: "",
    pqrsType: undefined,
  });
  const [typePqrs, setTypePqrs] = useState<PqrsType[]>([]);
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
    if (user) setFormData(user);
    console.log("Usuario a editar:", user);
  }, [user]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (onSave) onSave(formData);
    onClose(); // Cierra el modal después de guardar
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-40 flex items-center justify-center z-50">
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
        <h2 className="text-xl font-semibold text-gray-800 mb-4">Edit User</h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-gray-600 mb-1">Name</label>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              placeholder="Ingrese el nombre"
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">Email</label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
              placeholder="Ingrese el correo"
            />
          </div>
          <div>
            <label className="block text-sm text-gray-600 mb-1">Role</label>
            <select
              name="role"
              value={formData.role}
              onChange={handleChange}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400"
            >
              <option>admin</option>
              <option>user</option>
            </select>
          </div>
          {formData.role === "secretariat" ? (
            /* Tipo de PQRS */
            <div className="relative">
              <label className="block text-sm text-gray-600 mb-1">
                Type PQRS
              </label>
              <select
                name="typePqrsId"
                value={formData.pqrsType ? formData.pqrsType.id : ""}
                onChange={handleChange}
                className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400 "
                required
              >
                {typePqrs.map((type) => (
                  <option key={type.id} value={type.id}>
                    {type.name}
                  </option>
                ))}
              </select>
            </div>
          ) : (
            <div className="relative">
              <label className="block text-sm text-gray-600 mb-1">
                Type PQRS
              </label>
              <select
                name="typePqrsId"
                className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-green-400 "
                required
              >
                <option value="" disabled hidden></option>
                <option value="">type not allowed</option>
              </select>
            </div>
          )}

          <button
            type="submit"
            className="w-full bg-green-600 text-white py-2 rounded-md hover:bg-green-500 transition"
          >
            Save
          </button>
        </form>
      </div>
    </div>
  );
}
