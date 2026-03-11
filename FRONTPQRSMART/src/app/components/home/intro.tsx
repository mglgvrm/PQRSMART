"use client";
export default function Intro() {
  return (
    <section
      id="que-es"
      className="w-full py-20 px-6 bg-gray-50 flex flex-col items-center text-center"
    >
      <h2 className="text-3xl md:text-4xl font-extrabold text-green-600 mb-4">
        ¿Qué es el Sistema PQRS?
      </h2>

      <p className="text-lg md:text-xl text-gray-700 max-w-2xl leading-relaxed">
        El sistema PQRSmart permite a los usuarios enviar{" "}
        <span className="font-semibold text-green-600">
          preguntas, quejas, reclamos y sugerencias
        </span>{" "}
        de manera rápida y organizada para mejorar los servicios y la
        comunicación.
      </p>
    </section>
  );
}
