"use client";

import { set, useForm } from "react-hook-form";
import api from "@/app/api/api";
import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import withPublic from "@/app/utils/withPublic";
import HeaderLogin from "@/app/components/headerLogin";
import { useTranslation } from "react-i18next";
import "./Login.css";
import Popup from "@/app/components/modals/Popup";

declare var Gradient: any;
function Page() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();
  const [serverError, setServerError] = useState<string>("");
  const [showPopup, setShowPopup] = useState(false);
  const router = useRouter();
  const { t } = useTranslation("common");
  const [rememberedEmail, setRememberedEmail] = useState<string>("");
  useEffect(() => {
    const remenber = async () => {
      const rememberedEmail = localStorage.getItem("rememberedEmail");
      if (rememberedEmail) {
        setRememberedEmail(rememberedEmail);
      }
    };

    remenber();
  }, []);

  const onSubmit = handleSubmit(async (data) => {
    setServerError("");
    try {
      console.log(data);
      let formData: any = {
        user: data.user,
        password: data.password,
      };
      if (data.remember === true) {
        localStorage.setItem("rememberedEmail", data.email);
      }

      const res = await api.post("/auth/authenticate", formData);
      console.log(res.data);
      localStorage.setItem("token", res.data.token);
      console.log(res.data.token);

      /* if (res.data.token) {
        const login = await api.get("/auth/profile", {
          headers: { Authorization: `Bearer ${res.data.token}` },
        });

        localStorage.setItem("userId", JSON.stringify(login.data.id));*/
      localStorage.setItem("role", res.data.authorities[0]);
      console.log(res.data.authorities[0]);
      /*localStorage.setItem(
          "initial",
          login.data.name.charAt(0).toUpperCase(),
        );*/

      if (res.data.authorities[0] === "ROLE_ADMIN") router.push("/admin/home");
      if (res.data.authorities[0] === "ROLE_USER") router.push("/user/home");
      if (res.data.authorities[0] === "ROLE_SECRETARIAT") {
        localStorage.setItem("type", res.data.pqrsType.id);
        router.push("/secretariat/dashboard");
      }
    } catch (err: any) {
      const status = err.status ?? err.response.status;
      setServerError(String(status));
      if (status === 401) {
        setServerError("Usuario y/o Contraseña incorrecta");
      } else if (status === 403) {
        setServerError(
          "La cuenta está inactiva. Por favor verifique su correo para activar.",
        );
      } else if (status === 423) {
        setServerError("La cuenta está bloqueada.");
      } else {
        setServerError("Error en el servidor. Intente nuevamente más tarde.");
      }
      setShowPopup(true); // Mostrar popup
      return;
    }
  });
  const closePopup = () => {
    setShowPopup(false);
  };

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
  return (
    <div className="login-container">
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
      <div className="login-box">
        <div className="logo-section">
          <h1 className="PQRSmart">PQRSmart</h1>
          <div className="vertical-line"></div> {/* Línea vertical */}
        </div>
        <div className="form-section">
          <div className="titulologin">
            <h1>{t("login.login_title")}</h1>
          </div>
          <form onSubmit={onSubmit}>
            <div className="user-box">
              <input
                type="text"
                required
                id="user"
                {...register("user", {
                  required: true,
                })}
              />

              <label>{t("login.user_label")}</label>
            </div>
            <div className="user-box">
              <div className="password-wrapper">
                <input
                  type={"password"}
                  required
                  id="password"
                  {...register("password", { required: true, minLength: 8 })}
                />
                <label>{t("login.password_label")}</label>
                <span>{}</span>
              </div>
            </div>

            <div className="btn-container">
              <button type="submit" className="btn fifth">
                {t("login.submit_button")}
              </button>
            </div>
            <div className="Checkbox">
              <div className="CheckboxYRegistro">
                <a href="/Auth/register">{t("login.no_account")}</a>
                <label>
                  <input type="checkbox" {...register("remember")} />
                  {t("login.remember_me")}
                </label>
              </div>
            </div>
            <div className="OlvidasteContra">
              <a href="/Auth/forgot-password">{t("login.forgot_password")}</a>
            </div>
          </form>
        </div>
        {showPopup && <Popup message={serverError} onClose={closePopup} />}
      </div>
    </div>
  );

  {
    /*
   <div className="overflow-hidden h-screen flex flex-col bg-[#023047]">
      {/* Header superior 
      <HeaderLogin />

      <div className="flex flex-col items-center min-h-screen bg-gradient-to-b text-white">
        <div className="flex flex-col items-center mt-8">
          <h1 className="text-3xl font-bold mb-6">{t("login.login_title")}</h1>
        </div>

        <form
          onSubmit={onSubmit}
          className="bg-[#023053] text-gray-900 p-6 rounded-xl shadow-2xl w-full max-w-md"
        >
          {/* Email 
          <label className="mb-1 font-semibold block text-white">
            {t("login.user_label")}
          </label>
          <input
            type="text"
            {...register("user", {
              /* required: true, pattern: /^\S+@\S+$/i
            })}
            placeholder={t("login.user_placeholder") || ""}
            className="mb-6 bg-white w-full border border-gray-300 rounded-lg px-3 py-2 mt-1 focus:ring-2 focus:ring-blue-500 outline-none"
          />
          {errors.user && (
            <span className="text-red-500 text-sm">
              {t("login.user_error")}
            </span>
          )}

          {/* Password 
          <label className="mb-1 font-semibold block text-white">
            {t("login.password_label")}
          </label>
          <input
            type="password"
            {...register("password", { required: true, minLength: 8 })}
            placeholder={t("login.password_placeholder") || "Password123"}
            className="mb-6 bg-white w-full border border-gray-300 rounded-lg px-3 py-2 mt-1 focus:ring-2 focus:ring-blue-500 outline-none"
          />
          {errors.password && (
            <span className="text-red-500 text-sm">
              {t("login.password_error")}
            </span>
          )}

          {/* Remember me & Forgot password 
          <div className="flex items-center justify-between mt-3 mb-4 text-sm">
            <label className="text-blue-600 flex items-center gap-2 hover:underline font-medium">
              <input
                type="checkbox"
                className="accent-blue-600 w-4 h-4"
                {...register("remember")}
              />
              <span>{t("login.remember_me")}</span>
            </label>
            <a
              href="/Auth/forgot-password"
              className="text-blue-600 font-medium"
            >
              {t("login.forgot_password")}
            </a>
          </div>

          {serverError && (
            <span className="text-red-500 text-sm">
              {t("login.server_error")}
            </span>
          )}

          <button
            type="submit"
            className="w-full bg-blue-700 hover:bg-blue-800 text-white font-semibold py-2 rounded-lg transition-colors mt-2"
          >
            {t("login.submit_button")}
          </button>
          <div className="">
            <p className="text-center text-white mt-4">
              {t("login.no_account")}{" "}
              <a
                href="/Auth/register"
                className="text-blue-600 font-medium hover:underline"
              >
                {t("login.sign_up")}
              </a>
            </p>
          </div>
        </form>
      </div>
    </div>*/
  }
}

export default withPublic(Page);
