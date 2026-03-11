"use client";
import NavbarUser from "@/app/components/navbar_user";
import withAuth from "../../utils/withAuth";
import { useEffect, useState } from "react";
import api from "@/app/api/api";
import AddNewPqrsModal from "@/app/components/modals/AddNewPqrsModal";
import ViewPqrs from "@/app/components/modals/ViewPqrs";
import { set } from "react-hook-form";
import { useTranslation } from "react-i18next";
import Popup from "@/app/components/modals/Popup";
import { arch } from "os";

function PqrsPageUser() {
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
  const [pqrs, setPqrs] = useState<Pqrs[]>([]);
  const { t } = useTranslation("common");
  const [isOpenAddPqrs, setIsOpenAddPqrs] = useState(false);
  const [isOpenViewPqrs, setIsOpenViewPqrs] = useState(false);
  const [selectedPqrs, setSelectedPqrs] = useState<Pqrs | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = pqrs.slice(indexOfFirstItem, indexOfLastItem);
  const [showPopup, setShowPopup] = useState(false);
  const [error, setError] = useState("");

  const totalPages = Math.ceil(pqrs.length / itemsPerPage);

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
          setPqrs(response.data);
          console.log(response.data);
        } else console.error("Error al obtener los usuarios");
      } catch (error) {
        console.error("Error en la solicitud:", error);
      }
    };

    fetchPqrs();
  }, []);
  const handleNewPqrs = async (data: {
    mediumAnswer: string;
    description: string;
    date: Date;
    answer?: string;
    category: number | "";
    requestState: {
      idRequestState: number;
    };
    dependencia: number | "";
    requestType: number | "";
    archivo: File | null;
  }) => {
    try {
      const form = new FormData();
      const formData = {
        mediumAnswer: data.mediumAnswer,
        description: data.description,
        date: data.date,
        answer: data.answer,
        category: { idCategory: data.category },
        requestState: data.requestState,
        dependence: { idDependence: data.dependencia },
        requestType: { idRequestType: data.requestType },
      };
      form.append(
        "request",
        new Blob([JSON.stringify(formData)], {
          type: "application/json",
        }),
      );
      if (data.archivo) {
        form.append("archivo", data.archivo);
      }
      console.log("Datos enviados para la actualización:", form);
      setError("Espere.....");
      setShowPopup(true); // Mostrar popup
      const response = await api.post("/request/save", form, {
        headers: {
          "Content-Type": "multipart/form-data",
          Authorization: `Bearer ${localStorage.getItem("token")}`,
        },
      });
      console.log("Respuesta de la actualización:", response);
      const numRadicado = response.data.radicado;

      if (response.status === 201) {
        setPqrs((prev: any[]) => [...prev, response.data]);

        setError(
          "Solicitud Radicada Con Exito. Su numero de radicado es: " +
            numRadicado,
        );
        setShowPopup(true); // Mostrar popup
      }
    } catch (error) {
      console.error("Error al guardar usuario:", error);
    }
  };
  const handleCancel = async (idRequest: number) => {
    try {
      const token = localStorage.getItem("token");
      if (!token)
        return console.error("No se encontró el token de autenticación");
      const response = await api.put(
        `/request/cancel/${idRequest}`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        },
      );
      console.log("Respuesta de la cancelación:", response.data);
      if (response.status === 200) {
        setPqrs((prev) =>
          prev.map((pqrs) =>
            pqrs.idRequest === idRequest
              ? {
                  ...pqrs,
                  requestState: {
                    ...pqrs.requestState,
                    nameRequestState: "Rechazado",
                  },
                }
              : pqrs,
          ),
        );

        setError("PQRS cancelada con éxito");
        setShowPopup(true); // Mostrar popup
      } else {
        console.error("Error al cancelar la pqrs:", response);
      }
    } catch (error) {
      console.error("Error al cancelar la pqrs:", error);
    }
  };
  const closePopup = () => {
    setShowPopup(false);
  };

  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      {/* Header */}
      <header className="w-full bg-green-600 text-white shadow-md">
        <NavbarUser />
      </header>

      {/* Contenido principal */}
      <main className="w-full max-w-6xl mx-auto mt-10 px-6">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">
              {t("user.pqrs.pqrs_title")}
            </h2>
            <p className="text-gray-500 text-sm">
              {t("user.pqrs.pqrs_subtitle")}
            </p>
          </div>

          <button
            onClick={() => setIsOpenAddPqrs(true)}
            className="bg-green-600 hover:bg-green-500 text-white px-4 py-2 rounded-lg shadow-md transition"
          >
            {t("user.pqrs.add_pqrs_button")}
          </button>
          {isOpenAddPqrs && (
            <AddNewPqrsModal
              onClose={() => setIsOpenAddPqrs(false)}
              onSave={handleNewPqrs}
            />
          )}
        </div>

        {/* Tabla de usuarios */}
        <div className="overflow-x-auto border border-gray-200 rounded-lg shadow-lg">
          <table className="min-w-max divide-y divide-gray-200">
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
                    {pqrs.idRequest}
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
                          href={`/request/download/${encodeURIComponent(pqrs.archivo.split("\\").pop().split("/").pop())}`}
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
                          href={`/request/download/${encodeURIComponent(pqrs.archivoAnswer.split("\\").pop().split("/").pop())}`}
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
                          href={`/request/download/${encodeURIComponent(pqrs.archivoAnswer.split("\\").pop().split("/").pop())}`}
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
                    {pqrs.requestState.nameRequestState === "Pendiente" && (
                      <span
                        className="mr-4 cursor-pointer cancel-button"
                        title="Cancel"
                        onClick={() => handleCancel(pqrs.idRequest)}
                      >
                        ❌
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
                    {t("user.pqrs.table_no_registries")}
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
      {showPopup && <Popup message={error} onClose={closePopup} />}
    </div>
  );
}

export default withAuth(PqrsPageUser, ["ROLE_USER"]);
