"use client";
import { useEffect, useState, useRef, useCallback } from "react";
import { useRouter } from "next/navigation";
import withAuth from "../../utils/withAuth";
import api from "@/app/api/api";
import Navbar from "@/app/components/navbar";
import AddUserModal from "@/app/components/modals/AddUserModal";
import EditUserModal from "@/app/components/modals/EditUserModal";
import { useTranslation } from "react-i18next";

type User = {
  id: number;
  name: string;
  lastName: string;
  email: string;
  role: string;
  password?: string;
  number?: string;
  dependence: {
    idDependence: number;
    nameDependence: string;
  };
};

type Mensaje = { de: "bot" | "usuario"; texto: string };

function DashboardPageAdmin() {
  const router = useRouter();
  const { t } = useTranslation("common");

  // ── Estado de datos ──────────────────────────────────────────────────────
  const [users, setUsers] = useState<User[]>([]);
  const [search, setSearch] = useState("");
  const [isOpenAddUser, setIsOpenAddUser] = useState(false);
  const [isOpenEditUser, setIsOpenEditUser] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [refreshFlag, setRefreshFlag] = useState(0); // ← trigger para re-ejecutar useEffect
  const usersPerPage = 6;

  // ── Estado del chat ──────────────────────────────────────────────────────
  const [chatAbierto, setChatAbierto] = useState(false);
  const [mensajes, setMensajes] = useState<Mensaje[]>([
  {
    de: "bot",
    texto: `¡Hola! Soy tu asistente administrador de PQRSMART 👋

Puedo ayudarte con las siguientes acciones: 

• Listar todos los usuarios.
• Buscar un usuario por correo electrónico.
• Cambiar el rol de un usuario.
• Actualizar nombre y apellido.
• Actualizar número de teléfono.
• Eliminar usuarios por ID o correo.
• Crear un nuevo usuario con sus datos (nombre, apellido, username, correo, contraseña, rol, tipo de identificación, número de identificación, teléfono, tipo de persona y dependencia).

Escribe la acción que deseas realizar.`,
  },
]);
  const [inputChat, setInputChat] = useState("");
  const [chatCargando, setChatCargando] = useState(false);
  const endRef = useRef<HTMLDivElement>(null);

  // ── Paginación ───────────────────────────────────────────────────────────
  const filteredRecords = users.filter(
    (item) =>
      item.email.toLowerCase().includes(search.toLowerCase()) ||
      item.role.toLowerCase().includes(search.toLowerCase()),
  );
  const indexOfLastUser = currentPage * usersPerPage;
  const indexOfFirstUser = indexOfLastUser - usersPerPage;
  const currentUsers = filteredRecords.slice(indexOfFirstUser, indexOfLastUser);
  const totalPages = Math.ceil(filteredRecords.length / usersPerPage);

  // ── useEffect: carga usuarios — se relanza cuando refreshFlag cambia ─────
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) return console.error("No se encontró el token de autenticación");

        const response = await api.get("/Usuario/get", {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (response.status === 200) setUsers(response.data);
        else console.error("Error al obtener los usuarios");
      } catch (error) {
        console.error("Error en la solicitud:", error);
      }
    };

    fetchUsers();
  }, [refreshFlag]); // ← refreshFlag es la dependencia clave

  // ── Auto-scroll al último mensaje ────────────────────────────────────────
  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [mensajes]);

  // ── chatBoxUser: método que llama el chatbox ──────────────────────────────
  const chatBoxUser = async (texto: string) => {
    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("No se encontró el token de autenticación");

      const response = await api.get(
        "/chat/user", {
         params: { message: texto },
         headers: { Authorization: `Bearer ${token}` } ,
        }
      );

      if (response.status === 200) {
        // ✅ Éxito → mostrar respuesta del bot y refrescar la tabla
        setMensajes((prev) => [
          ...prev,
          {
            de: "bot",
            texto: response.data ?? "✅ Operación realizada con éxito.",
          },
        ]);

        // Relanza el useEffect incrementando el flag
        setRefreshFlag((n) => n + 1);
      } else {
        setMensajes((prev) => [
          ...prev,
          { de: "bot", texto: "⚠️ Respuesta inesperada del servidor." },
        ]);
      }
    } catch (error: any) {
      setMensajes((prev) => [
        ...prev,
        {
          de: "bot",
          texto: `❌ ${// Primero intenta el string plano, luego el objeto con .message
error?.response?.data ?? error?.response?.data?.message ?? error.message?? "Error al procesar la solicitud."}`,
        },
      ]);
    }
  };

  // ── Enviar mensaje del chat ───────────────────────────────────────────────
  const enviarMensaje = async () => {
    const texto = inputChat.trim();
    if (!texto || chatCargando) return;

    setInputChat("");
    setMensajes((prev) => [...prev, { de: "usuario", texto }]);
    setChatCargando(true);

    await chatBoxUser(texto); // ← llama al método con el texto del input

    setChatCargando(false);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") enviarMensaje();
  };

  // ── handleSaveUser ────────────────────────────────────────────────────────
  const handleSaveUser = async (data: {
    name: string;
    lastName: string;
    email: string;
    role: string;
    password?: string;
    number?: string;
    dependence: { idDependence: number; nameDependence: string };
  }) => {
    try {
      const token = localStorage.getItem("token");
      if (!token) return console.error("No se encontró el token");
      if (!selectedUser?.id) return console.error("Usuario seleccionado inválido");

      const response = await api.put(`/Usuario/Update`, data, {
        headers: { Authorization: `Bearer ${token}` },
      });

      if (response.status === 200) {
        setUsers((prev) =>
          prev.map((u) => (u.id === selectedUser.id ? response.data : u)),
        );
      } else {
        console.error("Error al actualizar el usuario:", response);
      }
    } catch (error) {
      console.error("Error al guardar usuario:", error);
    } finally {
      setIsOpenAddUser(false);
    }
  };

  // ── handleNewUser ─────────────────────────────────────────────────────────
  const handleNeweUser = async (data: {
    name: string;
    lastName: string;
    user: string;
    email: string;
    password: string;
    number: string;
    role: string;
    personType: { idPersonType: number };
    identificationType: { idIdentificationType: number };
    dependence: { idDependence: number };
    identificationNumber: number;
  }) => {
    try {
      const formData = {
        name: data.name,
        lastName: data.lastName,
        user: data.user,
        email: data.email,
        role: data.role,
        number: data.number,
        password: data.password,
        personType: { idPersonType: data.personType },
        identificationType: { idIdentificationType: data.identificationType },
        dependence: { idDependence: data.dependence },
        identificationNumber: data.identificationNumber,
      };

      const response = await api.post(`/auth/register`, formData, {
        headers: { Authorization: `Bearer ${localStorage.getItem("token")}` },
      });

      if (response.status === 200) {
        setUsers((prev) => [...prev, response.data]);
        alert("Usuario creado con éxito");
      } else {
        console.error("Error al crear el usuario:", response);
      }
    } catch (error) {
      console.error("Error al guardar usuario:", error);
    } finally {
      setIsOpenEditUser(false);
      setSelectedUser(null);
    }
  };

  // ── Render ─────────────────────────────────────────────────────────────────
  return (
    <div className="min-h-screen bg-white flex flex-col items-center font-sans">
      {/* Header */}
      <header className="w-full bg-green-600 text-white shadow-md">
        <Navbar />
      </header>

      {/* Contenido principal */}
      <main className="w-full max-w-6xl mx-auto mt-10 px-6">
        <div className="flex justify-between items-center mb-5">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">
              {t("admin.users.users_title")}
            </h2>
            <p className="text-gray-500 text-sm">
              {t("admin.users.users_subtitle")}
            </p>
          </div>
          <button
            className="bg-[#023047] hover:bg-[#023053] text-white font-semibold px-4 py-2 rounded-lg shadow-md transition-all duration-300"
            onClick={async () => {
              const token = localStorage.getItem("token");
              if (!token) return console.error("No se encontró el token");
              const response = await api.get("/Usuario/report", {
                headers: { Authorization: `Bearer ${token}` },
                responseType: "blob",
              });
              if (response.status === 200) {
                const url = window.URL.createObjectURL(new Blob([response.data]));
                const link = document.createElement("a");
                link.href = url;
                link.setAttribute("download", "user_report.xlsx");
                document.body.appendChild(link);
                link.click();
                link.parentNode?.removeChild(link);
              }
            }}
          >
            Generar Reporte
          </button>
          <button
            onClick={() => setIsOpenAddUser(true)}
            className="bg-[#023047] hover:bg-[#023053] text-white font-semibold px-4 py-2 rounded-lg shadow-md transition"
          >
            {t("admin.users.add_user_button")}
          </button>
          {isOpenAddUser && (
            <AddUserModal
              onClose={() => setIsOpenAddUser(false)}
              onSave={handleNeweUser}
            />
          )}
        </div>

        {/* Buscador */}
        <div className="relative flex items-center mb-2">
          <input
            type="text"
            placeholder={t("admin.users.user_search_placeholder")}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full py-2 pl-10 pr-4 text-gray-700 bg-white border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
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
                {["ID", t("admin.users.table_name_header"), t("admin.users.table_email_header"), t("admin.users.table_role_header"), t("admin.users.table_dependence_header"), t("admin.users.table_actions_header")].map(
                  (h, i) => (
                    <th
                      key={i}
                      className={`px-6 py-3 text-xs font-semibold text-gray-600 uppercase tracking-wider ${i === 5 ? "text-right" : "text-left"}`}
                    >
                      {h}
                    </th>
                  ),
                )}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-100">
              {currentUsers.map((user) => (
                <tr key={user.id} className="hover:bg-gray-100 transition duration-200">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{user.id}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-800">{user.name}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{user.email}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{user.role}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    {user.dependence ? user.dependence.nameDependence : "N/A"}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right">
                    <button
                      onClick={() => { setIsOpenEditUser(true); setSelectedUser(user); }}
                      className="text-green-600 hover:text-green-500 font-medium"
                    >
                      | {t("admin.users.table_edit_button")}
                    </button>
                  </td>
                </tr>
              ))}
              {users.length === 0 && (
                <tr>
                  <td colSpan={6} className="text-center text-gray-500 py-6 text-sm">
                    There are no registered users.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {isOpenEditUser && selectedUser && (
          <EditUserModal
            onClose={() => { setIsOpenEditUser(false); setSelectedUser(null); }}
            user={selectedUser}
            onSave={handleSaveUser}
          />
        )}

        {/* Paginador */}
        <div className="flex justify-center items-center py-4 space-x-3 bg-gray-50">
          <button
            onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
            className={`px-3 py-1 rounded-md border text-sm ${currentPage === 1 ? "text-gray-400 border-gray-200 cursor-not-allowed" : "text-green-600 border-green-300 hover:bg-green-100"}`}
          >
            {t("admin.users.pagination_previous_button")}
          </button>
          <span className="text-sm text-gray-700">
            {t("admin.users.table_pagination_info", { start: currentPage, total: totalPages })}
          </span>
          <button
            onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
            disabled={currentPage === totalPages}
            className={`px-3 py-1 rounded-md border text-sm ${currentPage === totalPages ? "text-gray-400 border-gray-200 cursor-not-allowed" : "text-green-600 border-green-300 hover:bg-green-100"}`}
          >
            {t("admin.users.pagination_next_button")}
          </button>
        </div>
      </main>

      {/* ── Chatbox ── */}
      {chatAbierto && (
        <div className="fixed bottom-28 right-6 z-50 flex h-[460px] w-[340px] flex-col overflow-hidden rounded-2xl border border-green-500/30 bg-slate-900 shadow-2xl shadow-black/60">
          {/* Header */}
          <div className="flex items-center gap-3 bg-gradient-to-r from-green-700 to-[#023047] px-4 py-3.5">
            <span className="text-xl">🤖</span>
            <span className="flex-1 text-sm font-bold text-white">Asistente de Usuarios</span>
            <button
              onClick={() => setChatAbierto(false)}
              className="text-white/70 transition hover:text-white text-lg leading-none"
            >
              ✕
            </button>
          </div>

          {/* Mensajes */}
          <div className="flex flex-1 flex-col gap-2.5 overflow-y-auto p-4 whitespace-pre-line">
            {mensajes.map((m, i) => (
              <div
                key={i}
                className={`max-w-[83%] rounded-2xl px-4 py-2.5 text-[13.5px] leading-relaxed ${
                  m.de === "usuario"
                    ? "self-end rounded-br-sm bg-gradient-to-br from-green-700 to-[#023047] text-white"
                    : "self-start rounded-bl-sm bg-green-500/15 text-green-100"
                }`}
              >
                {m.texto}
              </div>
            ))}

            {chatCargando && (
              <div className="self-start rounded-2xl rounded-bl-sm bg-green-500/15 px-4 py-3">
                <span className="flex gap-1.5">
                  {[0, 1, 2].map((i) => (
                    <span
                      key={i}
                      className="inline-block h-2 w-2 rounded-full bg-green-400 animate-bounce"
                      style={{ animationDelay: `${i * 0.15}s` }}
                    />
                  ))}
                </span>
              </div>
            )}
            <div ref={endRef} />
          </div>

          {/* Input */}
          <div className="flex gap-2 border-t border-white/5 bg-slate-900 p-3">
            <input
              value={inputChat}
              onChange={(e) => setInputChat(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={chatCargando}
              placeholder="Escribe tu mensaje…"
              className="flex-1 rounded-xl border border-green-500/30 bg-white/5 px-4 py-2.5 text-[13.5px] text-slate-200 placeholder-slate-500 outline-none transition focus:border-green-500/60 disabled:opacity-50"
            />
            <button
              onClick={enviarMensaje}
              disabled={chatCargando}
              className="flex w-11 items-center justify-center rounded-xl bg-gradient-to-br from-green-700 to-[#023047] text-lg text-white transition hover:opacity-90 disabled:opacity-50"
            >
              ➤
            </button>
          </div>
        </div>
      )}

      {/* ── Botón robot flotante ── */}
      <button
        onClick={() => setChatAbierto((v) => !v)}
        title="Abrir asistente"
        className={`fixed bottom-6 right-6 z-50 flex h-[60px] w-[60px] items-center justify-center rounded-full bg-gradient-to-br from-green-700 to-[#023047] shadow-lg shadow-green-900/40 transition-all duration-300 hover:scale-110 ${
          chatAbierto ? "rotate-12 scale-110" : ""
        }`}
      >
        <RobotIcon />
      </button>

      <style>{`
        @keyframes bounce {
          0%, 100% { transform: translateY(0); }
          50%       { transform: translateY(-5px); }
        }
        .animate-bounce { animation: bounce .8s infinite; }
      `}</style>
    </div>
  );
}

// ── Ícono SVG del robot ───────────────────────────────────────────────────────
function RobotIcon() {
  return (
    <svg width="28" height="28" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="18" y="20" width="28" height="24" rx="6" fill="white" fillOpacity=".95" />
      <rect x="24" y="27" width="6"  height="6"  rx="3" fill="#16a34a" />
      <rect x="34" y="27" width="6"  height="6"  rx="3" fill="#16a34a" />
      <rect x="26" y="37" width="12" height="3"  rx="1.5" fill="#16a34a" />
      <rect x="30" y="12" width="4"  height="8"  rx="2" fill="white" fillOpacity=".95" />
      <circle cx="32" cy="10" r="3" fill="white" fillOpacity=".95" />
      <rect x="10" y="28" width="6"  height="10" rx="3" fill="white" fillOpacity=".8" />
      <rect x="48" y="28" width="6"  height="10" rx="3" fill="white" fillOpacity=".8" />
      <rect x="22" y="44" width="6"  height="8"  rx="3" fill="white" fillOpacity=".8" />
      <rect x="36" y="44" width="6"  height="8"  rx="3" fill="white" fillOpacity=".8" />
    </svg>
  );
}

export default withAuth(DashboardPageAdmin, ["ROLE_ADMIN"]);