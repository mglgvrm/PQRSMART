"use client";

import { set, useForm } from "react-hook-form";
import api from "@/app/api/api";
import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
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
  const searchParams = useSearchParams();
  const token = searchParams.get("token"); // 👈 obtiene el token
  useEffect(() => {
    if (token) {
      console.log("Token:", token);
      // Aquí puedes verificar el token o enviarlo al backend
    }
  }, [token]);
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

      const response = await api.post("/auth/reset-password", formData);
      console.log("Response from reset-password:", response);
      if (response.status !== 201) {
        throw new Error("Failed to reset password");
      } else {
        alert(
          "Password reset successfully. Please log in with your new password."
        );
        router.push("/Auth/login");
      }
    } catch (err: any) {
      const msg = err.response?.data?.message ?? err.message;
      setServerError(String(msg));
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
          {/* Password */}
          <label className="mb-1 font-semibold block text-white">
            {t("register.password_label")}
          </label>
          <input
            className="mb-6 bg-white w-full border border-gray-300 rounded-lg px-3 py-2 mt-1 focus:ring-2 focus:ring-blue-500 outline-none"
            type="password"
            {...register("password", { required: true, minLength: 8 })}
            placeholder={t("register.password_placeholder")}
          />
          {errors.password && (
            <span className="text-red-500 text-sm">
              {t("register.password_error")}
            </span>
          )}

          {/* Confirm Password */}
          <label className="mb-1 font-semibold block text-white">
            {t("register.confirm_label")}
          </label>
          <input
            className="mb-6 bg-white w-full border border-gray-300 rounded-lg px-3 py-2 mt-1 focus:ring-2 focus:ring-blue-500 outline-none"
            type="password"
            {...register("confirmPassword", { required: true, minLength: 8 })}
            placeholder={t("register.confirm_placeholder")}
          />
          {errors.confirmPassword && (
            <span className="text-red-500 text-sm">
              {t("register.confirm_error")}
            </span>
          )}

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
