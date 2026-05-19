"use client";
import { useState, useEffect } from "react";
import api from "@/app/api/api";

type Dependence = { idDependence: number; nameDependence: string };


type Category = {
  idCategory: number;
  nameCategory: string;
  dependence: Dependence | null;
  state: State | null;
};

type Props = {
  onClose: () => void;
  category: Category;
  onSave: (data: {
    nameCategory: string;
    dependence: { idDependence: number };
    state: { idState: number };
  }) => void;
};

export default function EditCategoryModal({ onClose, category, onSave }: Props) {
  const [nameCategory, setNameCategory] = useState(category.nameCategory);
  const [selectedDependence, setSelectedDependence] = useState<number | "">(
    category.dependence?.idDependence ?? "",
  );

  const [dependences, setDependences] = useState<Dependence[]>([]);
 
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("token");
    const headers = { Authorization: `Bearer ${token}` };

    Promise.all([
      api.get("/dependence/get", { headers }),
    ]).then(([depRes, stateRes]) => {
      if (depRes.status === 200) setDependences(depRes.data);
      if (stateRes.status === 200) setStates(stateRes.data);
    }).catch((e) => console.error("Error cargando catálogos:", e));
  }, []);

  const isValid = nameCategory.trim() && selectedDependence !== "" ;

  const handleSubmit = async () => {
    if (!isValid) return;
    setLoading(true);
    try {
      await onSave({
        nameCategory,
        dependence: { idDependence: Number(selectedDependence) },
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-md p-8 relative">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <div className="flex items-center gap-3 mb-1">
          <h2 className="text-xl font-bold text-gray-800">Editar Categoría</h2>
          <span className="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full font-mono">
            #{category.idCategory}
          </span>
        </div>
        <p className="text-sm text-gray-400 mb-6">Modifica los datos de la categoría.</p>

        <div className="space-y-4">
          {/* Nombre */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
              Nombre de la categoría
            </label>
            <input
              type="text"
              value={nameCategory}
              onChange={(e) => setNameCategory(e.target.value)}
              className="w-full border border-gray-200 rounded-lg px-4 py-2.5 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#023047] transition"
            />
          </div>

          {/* Dependencia */}
          <div>
            <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">
              Dependencia
            </label>
            <select
              value={selectedDependence}
              onChange={(e) => setSelectedDependence(Number(e.target.value))}
              className="w-full border border-gray-200 rounded-lg px-4 py-2.5 text-sm text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#023047] transition bg-white"
            >
              <option value="">Selecciona una dependencia</option>
              {dependences.map((d) => (
                <option key={d.idDependence} value={d.idDependence}>
                  {d.nameDependence}
                </option>
              ))}
            </select>
          </div>

         
        </div>

        <div className="flex justify-end gap-3 mt-8">
          <button
            onClick={onClose}
            className="px-5 py-2 rounded-lg border border-gray-200 text-sm text-gray-600 hover:bg-gray-50 transition"
          >
            Cancelar
          </button>
          <button
            onClick={handleSubmit}
            disabled={loading || !isValid}
            className="px-5 py-2 rounded-lg bg-[#023047] text-white text-sm font-semibold hover:bg-[#023053] disabled:opacity-50 disabled:cursor-not-allowed transition"
          >
            {loading ? "Guardando..." : "Guardar Cambios"}
          </button>
        </div>
      </div>
    </div>
  );
}