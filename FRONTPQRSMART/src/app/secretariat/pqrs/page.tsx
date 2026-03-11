"use client";
import withAuth from "../../utils/withAuth";
import { useEffect, useState } from "react";
import api from "@/app/api/api";
import AnswerModal from "@/app/components/modals/AnswerModal";
import NavbarSecretariat from "@/app/components/navbar_secretariat";
import ViewPqrs from "@/app/components/modals/ViewPqrs";

function PqrsPageSecretariat() {
  type Pqrs = {
    id: number;
    title: string;
    description: string;
    status: string;
    createdAt: Date;
    user: {
      id: number;
      name: string;
    };
    pqrsType: {
      id: number;
      name: string;
    };
  };
  const [pqrs, setPqrs] = useState<Pqrs[]>([]);
  const [isOpenResponder, setIsOpenResponder] = useState(false);
  const [isOpenViewPqrs, setIsOpenViewPqrs] = useState(false);
  const [selectedPqrs, setSelectedPqrs] = useState<Pqrs | null>(null);
  const typeId =
    typeof window !== "undefined" ? localStorage.getItem("type") : null;
  useEffect(() => {
    const fetchPqrs = async () => {
      try {
        console.log("Fetching PQRS for User ID:", typeId);
        if (!typeId) return; // Espera hasta tener el userId
        const token = localStorage.getItem("token");
        if (!token)
          return console.error("No se encontró el token de autenticación");

        const response = await api.get(`/pqrs/type/${typeId}`, {
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

  const handleCancel = async (id: number) => {
    try {
      const token = localStorage.getItem("token");
      if (!token)
        return console.error("No se encontró el token de autenticación");
      const response = await api.patch(
        `/pqrs/${id}`,
        { status: "CLOSED" },
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      console.log("Respuesta de la cancelación:", response.data);
      if (response.status === 200) {
        // Actualiza la lista local con la respuesta del servidor (optimista/definitiva)
        setPqrs((prev) =>
          prev.map((pqrs) =>
            pqrs.id === id ? { ...pqrs, status: "CLOSED" } : pqrs
          )
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
                  ID
                </th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  title
                </th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  description
                </th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Type PQRS
                </th>
                <th className="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  status
                </th>
                <th className="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  create Date
                </th>
                <th className="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">
                  Action
                </th>
              </tr>
            </thead>

            <tbody className="bg-white divide-y divide-gray-100">
              {pqrs.map((pqrs: any) => (
                <tr
                  key={pqrs.id}
                  className="hover:bg-gray-100 transition duration-200"
                >
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">
                    {pqrs.id}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-800">
                    {pqrs.title}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {pqrs.description}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {pqrs.pqrsType.name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {pqrs.status}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {pqrs.createdAt}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right">
                    {pqrs.status === "PENDING" ? (
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
                          onClick={() => handleCancel(pqrs.id)}
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
                  prev.map((p) =>
                    p.id === selectedPqrs.id ? { ...p, status: "ANSWERED" } : p
                  )
                );
              }}
            />
          )}
        </div>
      </main>
    </div>
  );
}

export default withAuth(PqrsPageSecretariat, ["secretariat"]);
