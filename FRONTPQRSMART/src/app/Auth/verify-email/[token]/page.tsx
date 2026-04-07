"use client";

import { set, useForm } from "react-hook-form";
import api from "@/app/api/api";
import { useEffect, useState } from "react";
import { useParams, useRouter, useSearchParams } from "next/navigation";
import withPublic from "@/app/utils/withPublic";
import HeaderLogin from "@/app/components/headerLogin";
import { useTranslation } from "react-i18next";
import { FaEye, FaEyeSlash } from "react-icons/fa";
declare var Gradient: any;

function verifyEmailPage() {
  const [serverError, setServerError] = useState<string | null>(null);

  const router = useRouter();
  const { t } = useTranslation("common");
  const { token } = useParams();
  const [loading, setLoading] = useState(false);
  // 👈 obtiene el token
  useEffect(() => {
    if (token) {
      console.log("Tokens:", token);
      // Aquí puedes verificar el token o enviarlo al backend
    }
  }, [token]);
  // Cargar el archivo Gradient.js
  useEffect(() => {
    document.title = "Activate Account";
    const script = document.createElement("script");
    script.src = "/Gradient.js"; // Ruta directa al archivo en public
    script.async = true;
    document.body.appendChild(script);

    script.onload = () => {
      // Inicializar el gradiente una vez que el script haya cargado
      const gradient = new Gradient();
      gradient.initGradient("#gradient-canvas");
    };

    return () => {
      document.body.removeChild(script);
    };
  }, []);

  const onSubmit = async (data: any) => {
    try {
      setLoading(true);
      setServerError(null);

      const response = await api.post("/auth/verify-email", {
        token: token,
      });

      console.log("Response:", response);

      if (response.status === 200) {
        alert(
          "✅ Tu correo ha sido verificado exitosamente. ¡Bienvenido a PQR Smart!",
        );
        router.push("/Auth/login");
      }
    } catch (error: any) {
      if (
        error.response &&
        error.response.data &&
        error.response.data.message
      ) {
        setServerError(error.response.data.message);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="recovery">
      <canvas
        id="gradient-canvas"
        style={{
          width: "100vw",
          height: "100vh",
          position: "absolute",
          zIndex: -1,
        }}
      ></canvas>

      {/* Header superior */}
      <HeaderLogin />

      <div className="flex flex-col items-center min-h-screen bg-gradient-to-b text-white">
        <div className="flex flex-col items-center mt-8">
          <h1 className="text-3xl font-bold mb-6">Verify Email</h1>
        </div>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            onSubmit(e);
          }}
          className="bg-[#0000ff12] text-gray-900 p-6 rounded-xl shadow-2xl w-full max-w-md"
        >
          <p className="text-center text-white mb-6">
            Para continuar con el proceso, por favor confirma tu correo
            electrónico haciendo clic en el botón inferior. Esto activará tu
            cuenta correctamente.
          </p>
          <button
            type="submit"
            className="w-full bg-blue-700 hover:bg-blue-800 text-white font-semibold py-2 rounded-lg transition-colors mt-2"
          >
            {loading ? "Verifying..." : "Verify Email"}
          </button>

          {serverError && (
            <p className="text-red-500 text-sm mt-4">{serverError}</p>
          )}
        </form>
      </div>
    </div>
  );
}

export default withPublic(verifyEmailPage);
