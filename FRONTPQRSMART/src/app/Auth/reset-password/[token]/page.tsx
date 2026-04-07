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

function Page() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();
  const [serverError, setServerError] = useState<string | null>(null);

  const [passwordVisible, setPasswordVisible] = useState(false);
  const [confirmPasswordVisible, setConfirmPasswordVisible] = useState(false);
  const router = useRouter();
  const { t } = useTranslation("common");
  const { token } = useParams();
  // 👈 obtiene el token
  useEffect(() => {
    if (token) {
      console.log("Token:", token);
      // Aquí puedes verificar el token o enviarlo al backend
    }
  }, [token]);
  // Cargar el archivo Gradient.js
  useEffect(() => {
    document.title = "Login";
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

  const onSubmit = handleSubmit(async (data) => {
    setServerError(null);
    try {
      console.log(data);
      if (data.password !== data.confirmPassword) {
        setServerError("Passwords do not match");
        return;
      }
      let formData: any = {
        newPassword: data.password,
        token: token,
      };
      console.log("FormData to send:", formData);

      const response = await api.post(`/auth/forgot-password/reset`, formData);
      console.log("Response from reset-password:", response);
      if (response.status !== 200) {
        throw new Error("Failed to reset password");
      } else {
        alert(
          "Password reset successfully. Please log in with your new password.",
        );
        router.push("/Auth/login");
      }
    } catch (err: any) {
      const msg = err.response?.data?.message ?? err.message;
      setServerError(String(msg));
    }
  });
  const togglePasswordVisibility = () => {
    setPasswordVisible(!passwordVisible);
  };
  const confirmTogglePasswordVisibility = () => {
    setConfirmPasswordVisible(!confirmPasswordVisible);
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
          <h1 className="text-3xl font-bold mb-6"> Forgot Password</h1>
        </div>

        <form
          onSubmit={onSubmit}
          className="bg-[#0000ff12] text-gray-900 p-6 rounded-xl shadow-2xl w-full max-w-md"
        >
          {/* Password */}
          <div className="mb-6">
            <label className="mb-1 font-semibold block text-white">
              {t("register.password_label")}
            </label>

            <div className="relative">
              <input
                className="bg-white w-full border border-gray-300 rounded-lg px-3 py-2 pr-10 mt-1 focus:ring-2 focus:ring-blue-500 outline-none"
                type={passwordVisible ? "text" : "password"}
                {...register("password", { required: true, minLength: 8 })}
                placeholder={t("register.password_placeholder")}
              />

              <span
                className="absolute right-3 top-1/2 -translate-y-1/2 cursor-pointer text-gray-600"
                onClick={togglePasswordVisibility}
              >
                {passwordVisible ? <FaEye /> : <FaEyeSlash />}
              </span>
            </div>

            {errors.password && (
              <span className="text-red-500 text-sm">
                {t("register.password_error")}
              </span>
            )}
          </div>

          {/* Confirm Password */}
          <div className="mb-6">
            <label className="mb-1 font-semibold block text-white">
              {t("register.confirm_label")}
            </label>

            <div className="relative">
              <input
                className="bg-white w-full border border-gray-300 rounded-lg px-3 py-2 pr-10 mt-1 focus:ring-2 focus:ring-blue-500 outline-none"
                type={confirmPasswordVisible ? "text" : "password"}
                {...register("confirmPassword", {
                  required: true,
                  minLength: 8,
                })}
                placeholder={t("register.confirm_placeholder")}
              />

              <span
                className="absolute right-3 top-1/2 -translate-y-1/2 cursor-pointer text-gray-600"
                onClick={confirmTogglePasswordVisibility}
              >
                {confirmPasswordVisible ? <FaEye /> : <FaEyeSlash />}
              </span>
            </div>

            {errors.confirmPassword && (
              <span className="text-red-500 text-sm">
                {t("register.confirm_error")}
              </span>
            )}
          </div>

          <button
            type="submit"
            className="w-full bg-blue-700 hover:bg-blue-800 text-white font-semibold py-2 rounded-lg transition-colors mt-2"
          >
            Reset Password
          </button>
        </form>
      </div>
    </div>
  );
}

export default withPublic(Page);
