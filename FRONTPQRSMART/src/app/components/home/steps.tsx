"use client";

export default function Steps() {
  return (
    <section
      id="como-funciona"
      className="w-full py-20 px-6 bg-white flex flex-col items-center text-center"
    >
      <h2 className="text-3xl md:text-4xl font-extrabold text-green-600 mb-12">
        ¿Cómo Funciona?
      </h2>

      <div className="grid grid-cols-1 sm:grid-cols-3 gap-8 max-w-5xl w-full">
        <div className="bg-gray-50 border border-gray-200 rounded-2xl p-8 shadow-md hover:shadow-lg transition duration-300">
          <h3 className="text-2xl font-semibold text-green-600 mb-2">Paso 1</h3>
          <p className="text-gray-700">Iniciar Sesión o Registrarse</p>
        </div>

        <div className="bg-gray-50 border border-gray-200 rounded-2xl p-8 shadow-md hover:shadow-lg transition duration-300">
          <h3 className="text-2xl font-semibold text-green-600 mb-2">Paso 2</h3>
          <p className="text-gray-700">Crear una Solicitud</p>
        </div>

        <div className="bg-gray-50 border border-gray-200 rounded-2xl p-8 shadow-md hover:shadow-lg transition duration-300">
          <h3 className="text-2xl font-semibold text-green-600 mb-2">Paso 3</h3>
          <p className="text-gray-700">Recibir Respuesta</p>
        </div>
      </div>
    </section>
  );
}
