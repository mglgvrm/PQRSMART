"use client";

import { set, useForm } from "react-hook-form";
import api from "@/app/api/api";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import withPublic from "@/app/utils/withPublic";
import HeaderLogin from "@/app/components/headerLogin";
import { useTranslation } from "react-i18next";

function Page() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();
  const [serverError, setServerError] = useState<string | null>(null);
  const router = useRouter();
  const { t } = useTranslation("common");
  const [message, setMessage] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = handleSubmit(async (data) => {
    setLoading(true);
    setServerError(null);

    setMessage(null);

    try {
      let email = { email: data.email };
      console.log(email);
      const response = await api.post(`/auth/forgot-password`, email);
      if (response.status === 201) {
        setMessage("📩 Se ha enviado un enlace de recuperación a tu correo.");
      } else {
        setMessage("❌ No se pudo enviar el correo. Intenta nuevamente.");
      }
    } catch (error) {
      console.error("Error al enviar correo de recuperación:", error);
      setMessage("❌ Ocurrió un error. Intenta más tarde.");
    } finally {
      setLoading(false);
    }
  });

  return (
    <div className="overflow-hidden h-screen flex flex-col bg-[#023047]">
      {/* Header superior */}
      <HeaderLogin />

      <div className="flex flex-col items-center min-h-screen bg-gradient-to-b text-white">
        <div className="flex flex-col items-center mt-8">
          <h1 className="text-3xl font-bold mb-6"> Forgot Password</h1>
        </div>

        <form
          onSubmit={onSubmit}
          className="bg-[#023053] text-gray-900 p-6 rounded-xl shadow-2xl w-full max-w-md"
        >
          {/* Email */}
          <label className="mb-1 font-semibold block text-white">
            {t("login.email_label")}
          </label>
          <input
            type="email"
            {...register("email", { required: true, pattern: /^\S+@\S+$/i })}
            placeholder={t("login.email_placeholder") || "email@example.com"}
            className="mb-6 bg-white w-full border border-gray-300 rounded-lg px-3 py-2 mt-1 focus:ring-2 focus:ring-blue-500 outline-none"
          />
          {errors.email && (
            <span className="text-red-500 text-sm">
              {t("login.email_error")}
            </span>
          )}

          <button
            type="submit"
            className="w-full bg-blue-700 hover:bg-blue-800 text-white font-semibold py-2 rounded-lg transition-colors mt-2"
          >
            {loading ? "Sending..." : "Send Reset Link"}
          </button>
          {message && (
            <p className="text-center mt-6 text-sm text-white bg-[#035273] p-3 rounded-lg shadow-md w-full max-w-md">
              {message}
            </p>
          )}
          <div className="">
            <p className="text-center text-white mt-4">
              {t("register.already_account")}{" "}
              <a
                href="/Auth/login"
                className="text-blue-600 font-medium hover:underline"
              >
                {t("register.login_link")}
              </a>
            </p>
          </div>
        </form>
      </div>
    </div>
  );
}

export default withPublic(Page);
