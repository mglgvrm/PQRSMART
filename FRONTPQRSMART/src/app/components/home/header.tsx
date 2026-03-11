"use client";

import { useState } from "react";
import Modal from "./modal";
import { useRouter } from "next/navigation";
import { Menu, X } from "lucide-react";

export default function Header() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const router = useRouter();

  const handleOpenModal = () => setIsModalOpen(true);
  const handleCloseModal = () => setIsModalOpen(false);
  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  return (
    <header className="w-full bg-white/90 backdrop-blur-md shadow-sm fixed top-0 left-0 z-50">
      <div className="max-w-7xl mx-auto flex justify-between items-center px-6 py-4">
        {/* Logo */}
        <h1 className="text-2xl font-bold text-[#023047] tracking-tight">
          PQRSmart
        </h1>

        {/* Botón menú móvil */}
        <button
          className="md:hidden text-gray-700 hover:text-[#023047] transition"
          onClick={toggleMenu}
          aria-label="Toggle menu"
        >
          {isMenuOpen ? <X size={28} /> : <Menu size={28} />}
        </button>

        {/* Navegación */}
        <nav
          className={`${
            isMenuOpen
              ? "block absolute top-16 left-0 w-full bg-white border-t border-gray-200 shadow-lg"
              : "hidden"
          } md:flex md:static md:w-auto md:bg-transparent md:border-none md:shadow-none`}
        >
          <ul className="flex flex-col md:flex-row md:space-x-8 items-center md:items-center text-gray-700 font-medium">
            <li>
              <a
                href="#inicio"
                className="block px-6 py-3 hover:text-[#023047] transition"
                onClick={() => setIsMenuOpen(false)}
              >
                Inicio
              </a>
            </li>
            <li>
              <a
                href="#que-es"
                className="block px-6 py-3 hover:text-[#023047] transition"
                onClick={() => setIsMenuOpen(false)}
              >
                ¿Qué es?
              </a>
            </li>
            <li>
              <a
                href="#como-funciona"
                className="block px-6 py-3 hover:text-[#023047] transition"
                onClick={() => setIsMenuOpen(false)}
              >
                Cómo Funciona
              </a>
            </li>
            <li>
              <a
                href="#crear-solicitud"
                className="block px-6 py-3 hover:text-[#023047] transition"
                onClick={() => {
                  handleOpenModal();
                  setIsMenuOpen(false);
                }}
              >
                Crear Solicitud
              </a>
            </li>
            <li>
              <a
                href="#contacto"
                className="block px-6 py-3 hover:text-[#023047] transition"
                onClick={() => setIsMenuOpen(false)}
              >
                Contacto
              </a>
            </li>
            <li className="mt-2 md:mt-0">
              <button
                className="bg-[#023047] text-white px-5 py-2 rounded-lg hover:bg-[#023055] transition font-semibold"
                onClick={() => {
                  router.push("/Auth/login");
                  setIsMenuOpen(false);
                }}
              >
                Iniciar Sesión
              </button>
            </li>
          </ul>
        </nav>
      </div>

      {/* Modal para Crear Solicitud */}
      <Modal isOpen={isModalOpen} onClose={handleCloseModal} />
    </header>
  );
}
