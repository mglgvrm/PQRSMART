"use client";
import withAuth from "../../utils/withAuth";
import { useEffect, useState } from "react";
import api from "@/app/api/api";
import AnswerModal from "@/app/components/modals/AnswerModal";
import NavbarSecretariat from "@/app/components/navbar_secretariat";
import ViewPqrs from "@/app/components/modals/ViewPqrs";
import { useTranslation } from "react-i18next";

function PqrsPageSecretariat() {
  type Pqrs = {
    idRequest: number;
    mediumAnswer: string;
    description: string;
    date: Date;
    answer?: string;
    category: {
      idCategory: number;
      nameCategory: string;
    };
    requestState: {
      idRequestState: number;
      nameRequestState: string;
    };
    dependence: {
      idDependence: number;
      nameDependence: string;
    };
    requestType: {
      idRequestType: number;
      nameRequestType: string;
    };
  };
  const { t } = useTranslation("common");
  const [pqrs, setPqrs] = useState<Pqrs[]>([]);
  const [isOpenResponder, setIsOpenResponder] = useState(false);
  const [isOpenViewPqrs, setIsOpenViewPqrs] = useState(false);
  const [selectedPqrs, setSelectedPqrs] = useState<Pqrs | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = pqrs.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(pqrs.length / itemsPerPage);
  const typeId =
    typeof window !== "undefined" ? localStorage.getItem("type") : null;
  useEffect(() => {
    const fetchPqrs = async () => {
      try {
        console.log("Fetching PQRS for User ID:", typeId);
        // if (!typeId) return; // Espera hasta tener el userId
        const token = localStorage.getItem("token");
        if (!token)
          return console.error("No se encontró el token de autenticación");

        const response = await api.get("/request/getForDependence", {
          headers: { Authorization: `Bearer ${token}` },
        });
        console.log(response);

        if (response.status === 200) {
          setPqrs(response.data);
          console.log(response.data);
        } else console.error("Error al obtener los usuarios");
      } catch (error) {
        console.error("Error en la solicitud:", error);
      }
    };

    fetchPqrs();
  }, []);

  const handleCancel = async (id: number) => {
    try {
      const token = localStorage.getItem("token");
      if (!token)
        return console.error("No se encontró el token de autenticación");
      const response = await api.put(`/request/cancel/${id}`, null, {
        headers: { Authorization: `Bearer ${token}` },
      });
      console.log("Respuesta de la cancelación:", response.data);
      if (response.status === 200) {
        // Actualiza la lista local con la respuesta del servidor (optimista/definitiva)

        setPqrs((prev) =>
          prev.map((pqrs) =>
            pqrs.idRequest === id
              ? {
                  ...pqrs,
                  requestState: {
                    ...pqrs.requestState,
                    nameRequestState: "Cancelado",
                  },
                }
              : pqrs,
          ),
        );
        alert("PQRS cancelada con éxito");
      } else {
        console.error("Error al cancelar la pqrs:", response);
      }
    } catch (error) {
      console.error("Error al cancelar la pqrs:", error);
    }
  };

  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      {/* Header */}
      <header className="w-full bg-green-600 text-white shadow-md">
        <NavbarSecretariat />
      </header>

      {/* Contenido principal */}
      <main className="w-full max-w-6xl mx-auto mt-10 px-6">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">PQRS</h2>
            <p className="text-gray-500 text-sm">
              Complete list of PQRS registered to your User.
            </p>
          </div>
        </div>

        {/* Tabla de usuarios */}
        <div className="overflow-hidden border border-gray-200 rounded-lg shadow-lg">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  {t("user.pqrs.table_id_header")}
                </th>
                <th className="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  {t("user.pqrs.table_created_at_header")}
                </th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  {t("user.pqrs.table_description_header")}
                </th>
                <th>
                  <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                    {t("user.pqrs.table_evidence_header")}
                  </th>
                </th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  {t("user.pqrs.table_status_header")}
                </th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  {t("user.pqrs.table_answer_header")}
                </th>

                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  {t("user.pqrs.table_evidenceAnswer_header")}
                </th>
                <th className="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  {t("user.pqrs.table_actions_header")}
                </th>
              </tr>
            </thead>

            <tbody className="bg-white divide-y divide-gray-100">
              {currentItems.map((pqrs: any) => (
                <tr
                  key={pqrs.idRequest}
                  className="hover:bg-gray-100 transition duration-200"
                >
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {pqrs.radicado}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-800">
                    {pqrs.date}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    <div
                      style={{
                        whiteSpace: "nowrap",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                        maxWidth: "150px",
                      }}
                    >
                      {pqrs.description.length > 50
                        ? `${pqrs.description.slice(0, 50)}...`
                        : pqrs.description}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    <span className="span-descargar">
                      {pqrs.archivo ? (
                        <a
                          href={pqrs.archivo}
                          download
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <button className="flex items-center gap-2 bg-[#0B3C49] to-bg-[#0B3C49] text-white px-4 py-2 rounded-lg font-semibold shadow-md hover:from-green-600 hover:bg-[#0B3C49] hover:shadow-lg transform hover:-translate-y-1 active:scale-95 transition-all duration-300">
                            Abrir
                          </button>
                        </a>
                      ) : (
                        <div>
                          <span>No disponible</span>
                        </div>
                      )}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    <span
                      className={`estado ${pqrs.requestState?.nameRequestState?.toLowerCase()}`}
                    >
                      {pqrs.requestState?.nameRequestState === "Finalizado"
                        ? "✔️"
                        : pqrs.requestState?.nameRequestState === "Pendiente"
                          ? "🔎"
                          : "❌"}
                    </span>
                    {pqrs.requestState?.nameRequestState}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    <span className="span-descargar">
                      {pqrs.archivoAnswer ? (
                        <a
                          href={pqrs.archivoAnswer}
                          download
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <button className="btn-descargar">Descargar</button>
                        </a>
                      ) : (
                        <div>
                          <span>No disponible</span>
                        </div>
                      )}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    <span className="span-descargar">
                      {pqrs.archivoAnswer ? (
                        <a
                          href={pqrs.archivoAnswer}
                          download
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          <button className="btn-descargar">Descargar</button>
                        </a>
                      ) : (
                        <div>
                          <span>No disponible</span>
                        </div>
                      )}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right">
                    {pqrs.requestState.nameRequestState === "Pendiente" ? (
                      <div className="">
                        <span
                          className="mr-4 cursor-pointer"
                          title="Details"
                          onClick={() => {
                            setIsOpenViewPqrs(true);
                            setSelectedPqrs(pqrs);
                          }}
                        >
                          {"🔎"}
                        </span>
                        <span
                          className="mr-4 cursor-pointer text-green-600 hover:text-green-700"
                          title="Responder"
                          onClick={() => {
                            setSelectedPqrs(pqrs);
                            setIsOpenResponder(true);
                          }}
                        >
                          {"📩"}
                        </span>
                        <span
                          className="mr-4 cursor-pointer cancel-button"
                          title="Cancel"
                          onClick={() => handleCancel(pqrs.idRequest)}
                        >
                          ❌
                        </span>
                      </div>
                    ) : (
                      <span
                        className="mr-4 cursor-pointer"
                        title="Details"
                        onClick={() => {
                          setIsOpenViewPqrs(true);
                          setSelectedPqrs(pqrs);
                        }}
                      >
                        {"🔎"}
                      </span>
                    )}
                  </td>
                </tr>
              ))}

              {pqrs.length === 0 && (
                <tr>
                  <td
                    colSpan={5}
                    className="text-center text-gray-500 py-6 text-sm"
                  >
                    There are no PQRS registered.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
          {isOpenViewPqrs && selectedPqrs && (
            <ViewPqrs
              onClose={() => {
                setIsOpenViewPqrs(false);
                setSelectedPqrs(null);
              }}
              pqrs={selectedPqrs}
            />
          )}
          {isOpenResponder && selectedPqrs && (
            <AnswerModal
              pqrs={selectedPqrs}
              onClose={() => {
                setIsOpenResponder(false);
                setSelectedPqrs(null);
              }}
              onSave={() => {
                // Refresca la lista de PQRS tras responder
                setPqrs((prev) =>
                  prev.map((p: Pqrs) =>
                    p.idRequest === selectedPqrs.idRequest
                      ? {
                          ...p,
                          requestState: {
                            ...p.requestState,
                            nameRequestState: "Finalizado",
                          },
                        }
                      : p,
                  ),
                );
              }}
            />
          )}
        </div>
        <div className="flex justify-center mt-5 gap-3 mb-5">
          <button
            onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
            className="px-3 py-1 bg-gray-200 rounded"
          >
            Anterior
          </button>

          <span className="px-3 py-1">
            Página {currentPage} de {totalPages}
          </span>

          <button
            onClick={() =>
              setCurrentPage((prev) => Math.min(prev + 1, totalPages))
            }
            className="px-3 py-1 bg-gray-200 rounded"
          >
            Siguiente
          </button>
        </div>
      </main>
    </div>
  );
}

export default withAuth(PqrsPageSecretariat, ["ROLE_SECRE"]);
