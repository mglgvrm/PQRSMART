"use client";
import { useEffect } from "react";

function Modal({ isOpen, onClose }: { onClose: () => void; isOpen: boolean }) {
  // Bloquear scroll del fondo cuando el modal está abierto
  useEffect(() => {
    if (isOpen) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "auto";

    return () => {
      document.body.style.overflow = "auto";
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed top-0 left-0 w-screen h-screen bg-gray-900/60 backdrop-blur-sm flex items-center justify-center z-50 animate-fade-in px-4"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-2xl shadow-2xl w-11/12 max-w-md p-6 relative transition-all duration-300 transform scale-100 hover:scale-[1.02]"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 className="text-2xl font-bold text-green-700 mb-4 text-center">
          Acción requerida
        </h2>

        <p className="text-gray-700 text-center mb-6 leading-relaxed">
          Para crear una solicitud debes{" "}
          <a
            href="/Auth/login"
            className="text-green-600 font-semibold hover:underline"
          >
            iniciar sesión
          </a>
          . Si no tienes cuenta,{" "}
          <a
            href="/Auth/register"
            className="text-green-600 font-semibold hover:underline"
          >
            regístrate
          </a>
          .
        </p>

        <button
          onClick={onClose}
          className="w-full py-2 rounded-lg bg-green-600 text-white font-semibold hover:bg-green-700 transition-colors"
        >
          Cerrar
        </button>
      </div>
    </div>
  );
}

export default Modal;
