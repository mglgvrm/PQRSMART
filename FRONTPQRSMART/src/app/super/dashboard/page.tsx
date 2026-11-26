"use client";

import { useEffect, useState } from "react";

import api from "@/app/api/api";
import withAuth from "@/app/utils/withAuth";
import { useTranslation } from "react-i18next";

import { CalendarDays } from "lucide-react";
import NavbarSuper from "@/app/components/navbar_super";

function DashboardPageSuper() {
  const [pqrsDataPrediction, setPqrsDataPrediction] = useState<any[]>([]);
  const { t } = useTranslation("common");

  useEffect(() => {
    const fetchDataPrediction = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token)
          return console.error("No se encontró el token de autenticación");
        console.log("Token de autenticación encontrado:", token);
        const response = await api.get("/Prediction/dependencias", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = response.data;
        console.log("Fetched prediction PQRS data:", data);
        setPqrsDataPrediction(Array.isArray(data) ? data : data ? [data] : []);
      } catch (error) {
        console.error("Error fetching prediction PQRS data:", error);
      }
    };

    fetchDataPrediction();
  }, []);

  const [isOpen, setIsOpen] = useState(false);
  const [selectedYear, setSelectedYear] = useState<number | null>(null);
  const [selectedMonth, setSelectedMonth] = useState<number | null>(null);

  const handleConfirm = async () => {
    console.log("📅 Año:", selectedYear, "🗓️ Mes:", selectedMonth);
    const response = await api.get(
      `/request/report/${selectedYear}/${selectedMonth}`,
      {
        responseType: "blob",
        headers: {
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      },
    );
    // Crear la URL temporal del PDF
    const blob = new Blob([response.data], { type: "application/pdf" });
    const url = window.URL.createObjectURL(blob);

    // Crear un enlace invisible para descargar
    const link = document.createElement("a");
    link.href = url;
    link.download = `reporte_pqrs_${selectedYear}_${selectedMonth}.pdf`;
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(url);
    console.log("Reporte generado:", response);
    setSelectedMonth(null);
    setSelectedYear(null);
    setIsOpen(false);
  };

  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      {/* Header */}
      <header className="w-full bg-green-600 text-white shadow-md">
        <NavbarSuper />
      </header>
      <div className="mx-auto w-full max-w-7xl px-6 py-10">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-3xl font-bold text-[#023047]">
            {t("admin.dashboard.dashboard_title")}
          </h1>

          <button
            onClick={() => setIsOpen(true)}
            className="bg-[#023047] hover:bg-[#023053] text-white font-semibold px-4 py-2 rounded-lg shadow-md transition-all duration-300"
          >
            Generar Reporte
          </button>

          {/* Modal */}
          {isOpen && (
            <div className="fixed inset-0 flex items-center justify-center bg-black/40 z-50">
              <div className="bg-white rounded-lg shadow-lg w-[90%] max-w-md p-6">
                <h2 className="text-xl font-bold text-center text-[#023047] mb-4">
                  Selecciona el año y el mes
                </h2>

                <div className="flex flex-col gap-4">
                  {/* Año */}
                  <div>
                    <label className="block text-sm font-medium text-[#023047] mb-1">
                      Año
                    </label>
                    <input
                      type="number"
                      min="2000"
                      max={new Date().getFullYear()}
                      value={selectedYear || ""}
                      onChange={(e) =>
                        setSelectedYear(parseInt(e.target.value))
                      }
                      className="w-full border border-gray-300 rounded-md p-2 focus:outline-none focus:ring-2 focus:ring-[#023047]"
                      placeholder="Ej: 2025"
                    />
                  </div>

                  {/* Mes */}
                  <div>
                    <label className="block text-sm font-medium text-[#023047] mb-1">
                      Mes
                    </label>
                    <select
                      value={selectedMonth || ""}
                      onChange={(e) =>
                        setSelectedMonth(parseInt(e.target.value))
                      }
                      className="w-full border border-gray-300 rounded-md p-2 focus:outline-none focus:ring-2 focus:ring-[#023047]"
                    >
                      <option value="">Seleccionar mes</option>
                      <option value="1">Enero</option>
                      <option value="2">Febrero</option>
                      <option value="3">Marzo</option>
                      <option value="4">Abril</option>
                      <option value="5">Mayo</option>
                      <option value="6">Junio</option>
                      <option value="7">Julio</option>
                      <option value="8">Agosto</option>
                      <option value="9">Septiembre</option>
                      <option value="10">Octubre</option>
                      <option value="11">Noviembre</option>
                      <option value="12">Diciembre</option>
                    </select>
                  </div>
                </div>

                {/* Botones */}
                <div className="flex justify-end gap-3 mt-6">
                  <button
                    onClick={() => setIsOpen(false)}
                    className="px-4 py-2 rounded-md bg-gray-200 text-gray-700 hover:bg-gray-300 transition"
                  >
                    Cancelar
                  </button>
                  <button
                    onClick={handleConfirm}
                    disabled={!selectedYear || !selectedMonth}
                    className={`px-4 py-2 rounded-md text-white transition ${
                      !selectedYear || !selectedMonth
                        ? "bg-gray-400 cursor-not-allowed"
                        : "bg-[#023047] hover:bg-[#023053]"
                    }`}
                  >
                    Confirmar
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>

        <div className="grid w-full grid-cols-1 gap-6">
          {/* Total PQRS */}

          <div className="w-full rounded-2xl bg-white p-6 shadow-md">
            <h2 className="text-xl font-bold text-[#023047] mb-5">
              Predicción IA Próximo Mes
            </h2>

            <div className="space-y-4">
              {pqrsDataPrediction.map((item, index) => (
                <div
                  key={index}
                  className="grid grid-cols-1 gap-4 md:grid-cols-[minmax(0,1fr)_minmax(0,2fr)_minmax(0,1fr)]"
                >
                  <div className="min-w-0 rounded-lg border border-gray-200 bg-gray-50 p-4">
                    <p className="mb-2 text-xs font-semibold uppercase text-gray-500">
                      Dependencia
                    </p>
                    <p className="break-words font-semibold text-[#023047]">
                      {item.dependencia ?? item.dependence ?? "Sin dependencia"}
                    </p>
                  </div>

                  <div className="min-w-0 rounded-lg border border-gray-200 bg-gray-50 p-4">
                    <p className="mb-2 text-xs font-semibold uppercase text-gray-500">
                      Interpretación
                    </p>
                    <p className="break-words text-sm leading-relaxed text-gray-600">
                      {item.mensaje ??
                        (typeof item.predictedRequests === "number"
                          ? `${item.predictedRequests.toFixed(0)} solicitudes estimadas`
                          : "Sin información disponible")}
                    </p>
                    {item.periodo && (
                      <p className="mt-2 text-xs text-gray-500">
                        Periodo: {item.periodo}
                      </p>
                    )}
                  </div>

                  <div className="min-w-0 rounded-lg border border-gray-200 bg-gray-50 p-4">
                    <p className="mb-2 text-xs font-semibold uppercase text-gray-500">
                      Porcentaje
                    </p>
                    <p className="text-2xl font-bold text-red-500">
                      {Number(
                        item.probabilidad ?? item.percentage ?? 0,
                      ).toFixed(1)}
                      %
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
export default withAuth(DashboardPageSuper, ["ROLE_SUPER"]);
