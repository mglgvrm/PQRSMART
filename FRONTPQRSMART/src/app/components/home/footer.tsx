"use client";

export default function Footer() {
  return (
    <footer
      id="contacto"
      className="w-full bg-green-600 text-white py-6 mt-20 text-center"
    >
      <p className="text-sm md:text-base font-medium">
        Contacto:{" "}
        <a
          href="mailto:pqrsmart@gmail.com"
          className="underline hover:text-gray-200 transition-colors"
        >
          pqrsmart@gmail.com
        </a>{" "}
        | Teléfono:{" "}
        <a
          href="tel:+573170260183"
          className="underline hover:text-gray-200 transition-colors"
        >
          +57 317 026 0183
        </a>
      </p>
      <p className="text-xs text-gray-100 mt-2">
        © {new Date().getFullYear()} PQRSmart — Todos los derechos reservados.
      </p>
    </footer>
  );
}
