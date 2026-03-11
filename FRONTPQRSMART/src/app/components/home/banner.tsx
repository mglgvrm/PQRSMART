"use client";
import { useState } from "react";
import Modal from "./modal";

export default function Banner() {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleOpenModal = () => setIsModalOpen(true);
  const handleCloseModal = () => setIsModalOpen(false);

  return (
    <section
      id="inicio"
      className="w-full h-[90vh] flex flex-col justify-center items-center text-center px-6 
                 bg-gradient-to-b from-[#023047] to-white text-white relative overflow-hidden"
    >
      <h1 className="text-4xl md:text-6xl font-extrabold mb-4 drop-shadow-md">
        Bienvenido al Sistema PQRSmart
      </h1>

      <p className="text-lg md:text-2xl mb-2 font-medium text-white/90">
        Tu Gestión, Nuestra Prioridad.
      </p>

      <p className="text-base md:text-xl mb-6 text-white/80">
        Crea tu solicitud aquí.
      </p>

      <button
        onClick={handleOpenModal}
        className="bg-white text-[#023047] font-semibold px-6 py-3 rounded-xl shadow-md 
                   hover:bg-green-100 hover:scale-105 transition-all duration-300"
      >
        Crear Solicitud
      </button>

      <Modal isOpen={isModalOpen} onClose={handleCloseModal} />
    </section>
  );
}
