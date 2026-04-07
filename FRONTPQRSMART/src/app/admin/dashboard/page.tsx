"use client";

import { useEffect, useState } from "react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from "chart.js";
import { Bar, Line } from "react-chartjs-2";
import {
  Building,
  Calendar,
  BarChart3,
  TrendingUp,
  ListTodo,
} from "lucide-react";
import Navbar from "@/app/components/navbar";
import api from "@/app/api/api";
import withAuth from "@/app/utils/withAuth";
import { useTranslation } from "react-i18next";
ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  LineElement,
  PointElement,
  Title,
  Tooltip,
  Legend,
  Filler,
);

import { CalendarDays } from "lucide-react";

function DashboardPageAdmin() {
  const [pqrsData, setPqrsData] = useState<any[]>([]);
  const { t } = useTranslation("common");
  const [totalPQRS, setTotalPQRS] = useState(0);
  const [totalPQRSPorDependencia, setTotalPQRSPorDependencia] = useState<
    Record<string, number>
  >({});
  const [totalPQRSmes, setTotalPQRSmes] = useState<Record<string, number>>({});
  const [totalPQRSDepMes, setTotalPQRSDepMes] = useState<
    Record<string, number>
  >({});

  useEffect(() => {
    const fetchData = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token)
          return console.error("No se encontró el token de autenticación");
        console.log("Token de autenticación encontrado:", token);
        const response = await api.get("/request/get", {
          headers: { Authorization: `Bearer ${token}` },
        });
        const data = response.data;
        console.log("Fetched PQRS data:", data);
        setPqrsData(data);
        calcularTotales(data);
      } catch (error) {
        console.error("Error fetching PQRS data:", error);
      }
    };

    fetchData();
  }, []);

  const calcularTotales = (data: any[]) => {
    setTotalPQRS(data.length);

    // Total PQRS por Dependencia
    const dependenciaCount = data.reduce(
      (acc, pqrs) => {
        const dependencia =
          pqrs.dependence?.nameDependence || "Sin Dependencia";
        acc[dependencia] = (acc[dependencia] || 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );
    setTotalPQRSPorDependencia(dependenciaCount);

    // Total PQRS por Mes
    const pqrsPorMes = data.reduce(
      (acc, pqrs) => {
        const mes = new Date(pqrs.date).toLocaleString("default", {
          month: "long",
          year: "numeric",
        });
        acc[mes] = (acc[mes] || 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );
    setTotalPQRSmes(pqrsPorMes);

    // Total PQRS por Dependencia al Mes
    const pqrsPorDepMes = data.reduce(
      (acc, pqrs) => {
        const mes = new Date(pqrs.date).toLocaleString("default", {
          month: "long",
          year: "numeric",
        });
        const dependencia =
          pqrs.dependence?.nameDependence || "Sin Dependencia";
        const key = `${dependencia} - ${mes}`;
        acc[key] = (acc[key] || 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );
    setTotalPQRSDepMes(pqrsPorDepMes);
  };

  const dataChartDependencia = {
    labels: Object.keys(totalPQRSPorDependencia),
    datasets: [
      {
        label: t("admin.dashboard.total_pqrs_by_dependence"),
        data: Object.values(totalPQRSPorDependencia),
        backgroundColor: "rgba(99, 102, 241, 0.5)",
        borderColor: "rgba(99, 102, 241, 1)",
        borderWidth: 1,
        borderRadius: 8,
      },
    ],
  };

  const dataChartMes = {
    labels: Object.keys(totalPQRSmes),
    datasets: [
      {
        label: t("admin.dashboard.total_pqrs_by_month"),
        data: Object.values(totalPQRSmes),
        backgroundColor: "rgba(34, 197, 94, 0.5)",
        borderColor: "rgba(34, 197, 94, 1)",
        borderWidth: 1,
        borderRadius: 8,
      },
    ],
  };

  const lineChartData = {
    labels: Object.keys(totalPQRSmes),
    datasets: [
      {
        label: t("admin.dashboard.pqrs_tendency"),
        data: Object.values(totalPQRSmes),
        fill: true,
        backgroundColor: "rgba(34, 197, 94, 0.1)",
        borderColor: "rgba(34, 197, 94, 1)",
        tension: 0.3,
      },
    ],
  };
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
        <Navbar />
      </header>
      <div className="px-6 py-10 max-w-7xl mx-auto">
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

        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {/* Total PQRS */}
          <div className="bg-white rounded-2xl shadow-md p-6 flex flex-col items-center text-center hover:shadow-lg transition">
            <ListTodo className="text-[#023047] mb-3" size={36} />
            <h2 className="font-semibold text-gray-700 text-lg">
              {t("admin.dashboard.total_pqrs")}
            </h2>
            <p className="text-4xl font-bold text-[#023047] mt-2">
              {totalPQRS}
            </p>
          </div>

          {/* PQRS por Dependencia */}
          {Object.keys(totalPQRSPorDependencia).length > 0 && (
            <div className="bg-white rounded-2xl shadow-md p-6 hover:shadow-lg transition">
              <div className="flex items-center gap-2 mb-3">
                <Building className="text-indigo-500" />
                <h2 className="font-semibold text-gray-700">
                  {t("admin.dashboard.pqrs_by_dependence")}
                </h2>
              </div>
              <Bar
                data={dataChartDependencia}
                options={{
                  responsive: true,
                  plugins: { legend: { display: false } },
                }}
              />
            </div>
          )}

          {/* PQRS por Mes */}
          {Object.keys(totalPQRSmes).length > 0 && (
            <div className="bg-white rounded-2xl shadow-md p-6 hover:shadow-lg transition">
              <div className="flex items-center gap-2 mb-3">
                <Calendar className="text-green-500" />
                <h2 className="font-semibold text-gray-700">
                  {t("admin.dashboard.pqrs_by_month")}
                </h2>
              </div>
              <Bar
                data={dataChartMes}
                options={{
                  responsive: true,
                  plugins: { legend: { display: false } },
                }}
              />
            </div>
          )}

          {/* PQRS por Dependencia al Mes */}
          {Object.keys(totalPQRSDepMes).length > 0 && (
            <div className="bg-white rounded-2xl shadow-md p-6 col-span-full hover:shadow-lg transition">
              <div className="flex items-center gap-2 mb-3">
                <BarChart3 className="text-purple-500" />
                <h2 className="font-semibold text-gray-700">
                  {t("admin.dashboard.pqrs_by_dependence_month")}
                </h2>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm">
                {Object.entries(totalPQRSDepMes).map(([key, count]) => (
                  <div
                    key={key}
                    className="bg-gray-100 p-3 rounded-xl flex justify-between"
                  >
                    <span className="font-medium text-gray-600">{key}</span>
                    <span className="text-[#023047]font-semibold">{count}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Tendencia */}
          {Object.keys(totalPQRSmes).length > 0 && (
            <div className="bg-white rounded-2xl shadow-md p-6 col-span-full hover:shadow-lg transition">
              <div className="flex items-center gap-2 mb-3">
                <TrendingUp className="text-green-500" />
                <h2 className="font-semibold text-gray-700">
                  {t("admin.dashboard.pqrs_tendency")}
                </h2>
              </div>
              <Line
                data={lineChartData}
                options={{
                  responsive: true,
                  plugins: { legend: { position: "bottom" } },
                }}
              />
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
export default withAuth(DashboardPageAdmin, ["ROLE_ADMIN"]);
