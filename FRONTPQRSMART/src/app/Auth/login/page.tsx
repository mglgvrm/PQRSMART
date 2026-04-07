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
import { FaEye, FaEyeSlash } from "react-icons/fa";

declare var Gradient: any;
function Page() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();
  const [serverError, setServerError] = useState<string>("");
  const [showPopup, setShowPopup] = useState(false);
  const [passwordVisible, setPasswordVisible] = useState(false);
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

      if (res.data.token) {
        const initial = await api.get("/Usuario/initial", {
          headers: { Authorization: `Bearer ${res.data.token}` },
        });
        console.log(initial.data);
        localStorage.setItem("initial", initial.data);
      }
      localStorage.setItem("role", res.data.authorities[0]);
      console.log(res.data.authorities[0]);
      /*localStorage.setItem(
          "initial",
          login.data.name.charAt(0).toUpperCase(),
        );*/

      if (res.data.authorities[0] === "ROLE_ADMIN") router.push("/admin/home");
      if (res.data.authorities[0] === "ROLE_USER") router.push("/user/home");
      if (res.data.authorities[0] === "ROLE_SECRE") {
        //localStorage.setItem("type", res.data.pqrsType.id);
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
      console.error(err);
      return;
    }
  });
  const closePopup = () => {
    setShowPopup(false);
  };
  const togglePasswordVisibility = () => {
    setPasswordVisible(!passwordVisible);
  };

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
                  type={passwordVisible ? "text" : "password"}
                  required
                  id="password"
                  {...register("password", { required: true, minLength: 8 })}
                />
                <label>{t("login.password_label")}</label>
                <span
                  className="absolute right-3 top-1/2 -translate-y-1/2 cursor-pointer text-gray-600"
                  onClick={togglePasswordVisibility}
                >
                  {passwordVisible ? <FaEye /> : <FaEyeSlash />}
                </span>
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
}

export default withPublic(Page);
