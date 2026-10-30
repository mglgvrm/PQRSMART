"use client";
import { useState, useEffect } from "react";
import api from "@/app/api/api";

type State = {
  id: number;
  description: string;
};

type Dependence = {
  idDependence: number;
  nameDependence: string;
  state: { id: number; description: string } | null;
};

type Props = {
  onClose: () => void;
  dependence: Dependence;
  onSave: (data: { nameDependence: string; state: { id: number } }) => void;
};

export default function EditDependenceModal({
  onClose,
  dependence,
  onSave,
}: Props) {
  const [nameDependence, setNameDependence] = useState(
    dependence.nameDependence,
  );
  const [selectedState, setSelectedState] = useState<number | "">(
    dependence.state?.id ?? "",
  );
  const [states, setStates] = useState<State[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchStates = async () => {
      try {
        const token = localStorage.getItem("token");
        const response = await api.get("/state/get", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (response.status === 200) setStates(response.data);
      } catch (error) {
        console.error("Error al cargar estados:", error);
      }
    };
    fetchStates();
  }, []);

  const handleSubmit = async () => {
    if (!nameDependence.trim() || selectedState === "") return;
    setLoading(true);
    try {
      await onSave({
        nameDependence,
        state: { id: Number(selectedState) },
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8 relative">
        {/* Cerrar */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition"
        >
          <svg
            className="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>

        {/* Encabezado con badge del ID */}
        <div className="flex items-center gap-3 mb-1">
          <h2 className="text-xl font-bold text-gray-800">
            Editar Dependencia
          </h2>
          <span className="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full font-mono">
            #{dependence.idDependence}
          </span>
        </div>
        <p className="text-sm text-gray-400 mb-6">
          Modifica los datos de la dependencia.
        </p>

        <div className="space-y-4">
          {/* Nombre */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
              Nombre de la dependencia
            </label>
            <input
              type="text"
              value={nameDependence}
              onChange={(e) => setNameDependence(e.target.value)}
              className="w-full border border-gray-200 rounded-lg px-4 py-2.5 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#023047] transition"
            />
          </div>

          {/* Estado */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
              Estado
            </label>
            <select
              value={selectedState}
              onChange={(e) => setSelectedState(Number(e.target.value))}
              className="w-full border border-gray-200 rounded-lg px-4 py-2.5 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#023047] transition bg-white"
            >
              <option value="">Selecciona un estado</option>
              {states.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.description}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Acciones */}
        <div className="flex justify-end gap-3 mt-8">
          <button
            onClick={onClose}
            className="px-5 py-2 rounded-lg border border-gray-200 text-sm text-gray-600 hover:bg-gray-50 transition"
          >
            Cancelar
          </button>
          <button
            onClick={handleSubmit}
            disabled={loading || !nameDependence.trim() || selectedState === ""}
            className="px-5 py-2 rounded-lg bg-[#023047] text-white text-sm font-semibold hover:bg-[#023053] disabled:opacity-50 disabled:cursor-not-allowed transition"
          >
            {loading ? "Guardando..." : "Guardar Cambios"}
          </button>
        </div>
      </div>
    </div>
  );
}
