"use client";
import { useState, useEffect } from "react";
import api from "@/app/api/api";



type Props = {
  onClose: () => void;
  onSave: (data: {
    nameDependence: string;
  }) => void;
};

export default function AddDependenceModal({ onClose, onSave }: Props) {
  const [nameDependence, setNameDependence] = useState("");
 
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    if (!nameDependence.trim() || selectedState === "") return;
    setLoading(true);
    try {
      await onSave({
        nameDependence,
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
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <h2 className="text-xl font-bold text-gray-800 mb-1">Nueva Dependencia</h2>
        <p className="text-sm text-gray-400 mb-6">Completa los datos para registrar la dependencia.</p>

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
              placeholder="Ej: Dirección de Sistemas"
              className="w-full border border-gray-200 rounded-lg px-4 py-2.5 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#023047] transition"
            />
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
            {loading ? "Guardando..." : "Crear Dependencia"}
          </button>
        </div>
      </div>
    </div>
  );
}