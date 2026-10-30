"use client";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import withAuth from "../../utils/withAuth";
import api from "@/app/api/api";
import Navbar from "@/app/components/navbar";
import AddDependenceModal from "@/app/components/modals/AddDependenceModal";
import EditDependenceModal from "@/app/components/modals/EditDependenceModal";
import { useTranslation } from "react-i18next";

type Dependence = {
  idDependence: number;
  nameDependence: string;
  state: { id: number; description: string } | null;
};

function DependencePageAdmin() {
  const { t } = useTranslation("common");

  const [dependences, setDependences] = useState<Dependence[]>([]);
  const [search, setSearch] = useState("");
  const [isOpenAdd, setIsOpenAdd] = useState(false);
  const [isOpenEdit, setIsOpenEdit] = useState(false);
  const [selected, setSelected] = useState<Dependence | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [refreshFlag, setRefreshFlag] = useState(0);
  const itemsPerPage = 6;

  // ── Paginación ───────────────────────────────────────────────────────────
  const filtered = dependences.filter((d) =>
    d.nameDependence.toLowerCase().includes(search.toLowerCase()),
  );
  const indexOfLast = currentPage * itemsPerPage;
  const indexOfFirst = indexOfLast - itemsPerPage;
  const currentItems = filtered.slice(indexOfFirst, indexOfLast);
  const totalPages = Math.ceil(filtered.length / itemsPerPage);

  // ── Carga de datos ───────────────────────────────────────────────────────
  useEffect(() => {
    const fetchDependences = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) return console.error("No token found");
        const response = await api.get("/dependence/get", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (response.status === 200) setDependences(response.data);
        console.log("Dependences fetched:", response.data);
      } catch (error) {
        console.error("Error fetching dependences:", error);
      }
    };
    fetchDependences();
  }, [refreshFlag]); // ← se relanza al crear/editar

  // ── Crear dependencia ────────────────────────────────────────────────────
  const handleNew = async (data: { nameDependence: string }) => {
    try {
      const token = localStorage.getItem("token");
      if (!token) return;
      const response = await api.post("/dependence/create", data, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (response.status === 200) {
        setDependences((prev) => [...prev, response.data]);
        setRefreshFlag((f) => f + 1);
        alert("Dependencia creada con éxito");
      }
    } catch (error) {
      console.error("Error al crear dependencia:", error);
    } finally {
      setIsOpenAdd(false);
    }
  };

  // ── Editar dependencia ───────────────────────────────────────────────────
  const handleSave = async (data: { nameDependence: string }) => {
    try {
      const token = localStorage.getItem("token");
      if (!token || !selected) return;
      const response = await api.put(
        `/dependence/update/${selected.idDependence}`,
        data,
        { headers: { Authorization: `Bearer ${token}` } },
      );
      if (response.status === 200) {
        setDependences((prev) =>
          prev.map((d) =>
            d.idDependence === selected.idDependence ? response.data : d,
          ),
        );
        setRefreshFlag((f) => f + 1);
      }
    } catch (error) {
      console.error("Error al actualizar dependencia:", error);
    } finally {
      setIsOpenEdit(false);
      setSelected(null);
    }
  };

  // ── Render ───────────────────────────────────────────────────────────────
  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      <header className="w-full bg-green-600 text-white shadow-md">
        <Navbar />
      </header>

      <main className="w-full max-w-6xl mx-auto mt-10 px-6">
        <div className="flex justify-between items-center mb-5">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Dependencias</h2>
            <p className="text-gray-500 text-sm">
              Gestión de dependencias del sistema
            </p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={() => setIsOpenAdd(true)}
              className="bg-[#023047] hover:bg-[#023053] text-white font-semibold px-4 py-2 rounded-lg shadow-md transition"
            >
              Agregar Dependencia
            </button>
          </div>
        </div>

        {isOpenAdd && (
          <AddDependenceModal
            onClose={() => setIsOpenAdd(false)}
            onSave={handleNew}
          />
        )}

        {/* Buscador */}
        <div className="relative flex items-center mb-4">
          <input
            type="text"
            placeholder="Buscar por nombre..."
            value={search}
            onChange={(e) => {
              setSearch(e.target.value);
              setCurrentPage(1);
            }}
            className="w-full py-2 pl-10 pr-4 text-gray-700 bg-white border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <svg
            className="absolute left-3 h-5 w-5 text-gray-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
        </div>

        {/* Tabla */}
        <div className="overflow-hidden border border-gray-200 rounded-lg shadow-lg">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                {["ID", "Nombre Dependencia", "Estado", "Acciones"].map(
                  (h, i) => (
                    <th
                      key={i}
                      className={`px-6 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider ${i === 3 ? "text-right" : "text-left"}`}
                    >
                      {h}
                    </th>
                  ),
                )}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-100">
              {currentItems.map((dep) => (
                <tr
                  key={dep.idDependence}
                  className="hover:bg-gray-100 transition duration-200"
                >
                  <td className="px-6 py-4 text-sm text-gray-700">
                    {dep.idDependence}
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-gray-800">
                    {dep.nameDependence}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-600">
                    {dep.state?.description ?? "N/A"}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => {
                        setSelected(dep);
                        setIsOpenEdit(true);
                      }}
                      className="text-green-600 hover:text-green-500 font-medium"
                    >
                      Editar
                    </button>
                  </td>
                </tr>
              ))}
              {dependences.length === 0 && (
                <tr>
                  <td
                    colSpan={4}
                    className="text-center text-gray-500 py-6 text-sm"
                  >
                    No hay dependencias registradas.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {isOpenEdit && selected && (
          <EditDependenceModal
            onClose={() => {
              setIsOpenEdit(false);
              setSelected(null);
            }}
            dependence={selected}
            onSave={handleSave}
          />
        )}

        {/* Paginador */}
        <div className="flex justify-center items-center py-4 space-x-3 bg-gray-50">
          <button
            onClick={() => setCurrentPage((p) => Math.max(p - 1, 1))}
            disabled={currentPage === 1}
            className={`px-3 py-1 rounded-md border text-sm ${currentPage === 1 ? "text-gray-400 border-gray-200 cursor-not-allowed" : "text-green-600 border-green-300 hover:bg-green-100"}`}
          >
            Anterior
          </button>
          <span className="text-sm text-gray-700">
            Página {currentPage} de {totalPages || 1}
          </span>
          <button
            onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages))}
            disabled={currentPage === totalPages || totalPages === 0}
            className={`px-3 py-1 rounded-md border text-sm ${currentPage === totalPages || totalPages === 0 ? "text-gray-400 border-gray-200 cursor-not-allowed" : "text-green-600 border-green-300 hover:bg-green-100"}`}
          >
            Siguiente
          </button>
        </div>
      </main>
    </div>
  );
}

export default withAuth(DependencePageAdmin, ["ROLE_ADMIN"]);
