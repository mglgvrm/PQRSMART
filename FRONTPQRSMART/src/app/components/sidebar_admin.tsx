"use client";
import { useRouter } from "next/navigation";

export default function Sidebar({ isOpen }: { isOpen: boolean }) {
  const router = useRouter();

  return (
    <aside
      className={`fixed top-16 left-0 h-[calc(100vh-4rem)] w-64 bg-green-700 text-white flex flex-col justify-between shadow-lg transform transition-transform duration-300 z-40
        ${isOpen ? "translate-x-0" : "-translate-x-full"} md:translate-x-0`}
    >
      {/* Navegación */}
      <div className="flex-1 overflow-y-auto">
        <nav className="flex flex-col p-4 space-y-2">
          <button
            onClick={() => router.push("/admin/users")}
            className="text-left px-4 py-2 rounded-lg hover:bg-green-600 transition"
          >
            Usuarios
          </button>
          <button
            onClick={() => router.push("/dashboard/reportes")}
            className="text-left px-4 py-2 rounded-lg hover:bg-green-600 transition"
          >
            Reportes
          </button>
          <button
            onClick={() => router.push("/dashboard/soporte")}
            className="text-left px-4 py-2 rounded-lg hover:bg-green-600 transition"
          >
            Soporte
          </button>

          <hr className="my-2 border-green-600" />

          <button
            onClick={() => router.push("/dashboard/configuracion")}
            className="text-left px-4 py-2 rounded-lg hover:bg-green-600 transition"
          >
            Configuración
          </button>
          <button
            onClick={() => router.push("/dashboard/perfil")}
            className="text-left px-4 py-2 rounded-lg hover:bg-green-600 transition"
          >
            Perfil
          </button>
          <button
            onClick={() => router.push("/dashboard/ayuda")}
            className="text-left px-4 py-2 rounded-lg hover:bg-green-600 transition"
          >
            Ayuda
          </button>
        </nav>
      </div>
    </aside>
  );
}
