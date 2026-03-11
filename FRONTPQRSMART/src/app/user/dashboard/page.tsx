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
import api from "@/app/api/api";
import withAuth from "@/app/utils/withAuth";
import NavbarUser from "@/app/components/navbar_user";
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

function DashboardPageUser() {
  const { t } = useTranslation("common");
  const [pqrsData, setPqrsData] = useState<any[]>([]);
  const [totalPQRS, setTotalPQRS] = useState(0);
  const [totalPQRSPorDependencia, setTotalPQRSPorDependencia] = useState<
    Record<string, number>
  >({});
  const [totalPQRSmes, setTotalPQRSmes] = useState<Record<string, number>>({});
  const [totalPQRSDepMes, setTotalPQRSDepMes] = useState<
    Record<string, number>
  >({});

  useEffect(() => {
    const fetchPqrs = async () => {
      try {
        /*console.log("Fetching PQRS for User ID:", userId);
        if (!userId) return; // Espera hasta tener el userId*/
        const token = localStorage.getItem("token");
        if (!token)
          return console.error("No se encontró el token de autenticación");

        const response = await api.get(`/request/get/pqrs`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (response.status === 200) {
          setPqrsData(response.data);
          calcularTotales(response.data);
          console.log(response.data);
        } else console.error("Error al obtener los usuarios");
      } catch (error) {
        console.error("Error en la solicitud:", error);
      }
    };

    fetchPqrs();
  }, []);

  const calcularTotales = (data: any[]) => {
    setTotalPQRS(data.length);

    // Total PQRS por Dependencia
    const dependenciaCount = data.reduce(
      (acc, pqrs) => {
        const dependence =
          pqrs.dependence?.nameDependence ||
          t("user.dashboard.no_pqrs_message");
        acc[dependence] = (acc[dependence] || 0) + 1;
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
        label: t("user.dashboard.pqrs_by_dependence"),
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
        label: t("user.dashboard.total_pqrs_by_month"),
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
        label: t("user.dashboard.pqrs_tendency"),
        data: Object.values(totalPQRSmes),
        fill: true,
        backgroundColor: "rgba(34, 197, 94, 0.1)",
        borderColor: "rgba(34, 197, 94, 1)",
        tension: 0.3,
      },
    ],
  };

  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      {/* Header */}
      <header className="w-full bg-green-600 text-white shadow-md">
        <NavbarUser />
      </header>
      <div className="px-6 py-10 max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold text-center text-green-700 mb-10">
          {t("user.dashboard.dashboard_title")}
        </h1>

        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {/* Total PQRS */}
          <div className="bg-white rounded-2xl shadow-md p-6 flex flex-col items-center text-center hover:shadow-lg transition">
            <ListTodo className="text-green-500 mb-3" size={36} />
            <h2 className="font-semibold text-gray-700 text-lg">
              {t("user.dashboard.total_pqrs")}
            </h2>
            <p className="text-4xl font-bold text-green-600 mt-2">
              {totalPQRS}
            </p>
          </div>

          {/* PQRS por Dependencia */}
          {Object.keys(totalPQRSPorDependencia).length > 0 && (
            <div className="bg-white rounded-2xl shadow-md p-6 hover:shadow-lg transition">
              <div className="flex items-center gap-2 mb-3">
                <Building className="text-indigo-500" />
                <h2 className="font-semibold text-gray-700">
                  {t("user.dashboard.pqrs_by_dependence")}
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
                  {t("user.dashboard.total_pqrs_by_month")}
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
                  {t("user.dashboard.pqrs_by_dependence_month")}
                </h2>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm">
                {Object.entries(totalPQRSDepMes).map(([key, count]) => (
                  <div
                    key={key}
                    className="bg-gray-100 p-3 rounded-xl flex justify-between"
                  >
                    <span className="font-medium text-gray-600">{key}</span>
                    <span className="text-green-600 font-semibold">
                      {count}
                    </span>
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
                  {t("user.dashboard.pqrs_tendency")}
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
export default withAuth(DashboardPageUser, ["ROLE_USER"]);
