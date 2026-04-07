"use client";

import { useForm } from "react-hook-form";
import withPublic from "@/app/utils/withPublic";
import HeaderLogin from "@/app/components/headerLogin";
import api from "@/app/api/api";
import { useTranslation } from "react-i18next";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { FaEye, FaEyeSlash } from "react-icons/fa";
import "./Registro.css";

declare var Gradient: any;
function RegisterPage() {
  const { t } = useTranslation("common");
  const [passwordVisible, setPasswordVisible] = useState(false);
  const [confirmPasswordVisible, setConfirmPasswordVisible] = useState(false);
  const [identificationTypes, setIdentificationTypes] = useState([]);
  const [personTypes, setPersonTypes] = useState([]);
  const router = useRouter();
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();
  useEffect(() => {
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
  useEffect(() => {
    document.title = "Registro";
    const fetchIdentificationTypes = async () => {
      try {
        const response = await api.get("/identification_type/get");
        console.log("Tipos de identificación obtenidos:", response.data);
        setIdentificationTypes(response.data);
      } catch (error) {
        console.error(
          "Error al obtener tipos de identificación de la base de datos",
          error,
        );
      }
    };

    const fetchPersonTypes = async () => {
      try {
        const response = await api.get("/person_type/get");
        console.log("Tipos de persona obtenidos:", response.data);
        setPersonTypes(response.data);
      } catch (error) {
        console.error(
          "Error al obtener tipos de persona de la base de datos",
          error,
        );
      }
    };

    fetchIdentificationTypes();
    fetchPersonTypes();
  }, []);
  const togglePasswordVisibility = () => {
    setPasswordVisible(!passwordVisible);
  };
  const confirmTogglePasswordVisibility = () => {
    setConfirmPasswordVisible(!confirmPasswordVisible);
  };
  const validatePassword = (data: any) => {
    const minLength = data.password.length >= 8;
    const hasUpperCase = /[A-Z]/.test(data.password);
    const hasLowerrCase = /[a-z]/.test(data.password);
    const hasNumber = /\d/.test(data.password);
    const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>/?]/.test(
      data.password,
    );

    return (
      minLength && hasUpperCase && hasNumber && hasSpecialChar && hasLowerrCase
    );
  };
  const onSubmit = handleSubmit(async (data) => {
    console.log(data);
    try {
      let formData: any = {
        name: data.name,
        lastName: data.lastName,
        user: data.username,
        email: data.email,
        password: data.password,
        number: data.number,
        personType: { idPersonType: data.idPersonType },
        identificationType: { idIdentificationType: data.idIdentificationType }, // Enviar el objeto completo
        dependence: { idDependence: 7 },
        identificationNumber: parseInt(data.identificationNumber),
      };
      console.log("Datos a enviar al backend:", formData);
      const response = await api.post(`/auth/registerUser`, formData);
      console.log("Respuesta de la actualización:", response);

      if (response.status === 200) {
        console.log("Usuario registrado exitosamente");
        alert(t("register.success_alert"));
        router.push("/Auth/login");
      }
    } catch (error: any) {
      const status = error.response.data;
      console.log(status);
      // Manejo de errores
      if (status === "El correo electrónico ya está en uso.") {
        console.error("El correo electrónico ya está en uso.");
      } else if (status === "El usuario ya existe.") {
        console.error("El usuario ya existe.");
      } else if (status === "El número de identificación ya está registrado.") {
        console.error("El número de identificación ya está registrado.");
      } else if (status === "El número ya está registrado.") {
        console.error("El número ya está registrado.");
      } else {
        console.error("Error en el servidor. Intente nuevamente más tarde.");
      }
      return;
    }
  });

  return (
    <div className="RegistroUser">
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
      <div className="FormularioRegistro">
        <form className="forms" onSubmit={onSubmit}>
          <div className="tituloRegistro">
            <h1> {t("register.register_title")}</h1>
          </div>
          <div className="Campos">
            <div className="labelsAndInputs">
              <label>{t("register.typePerson_label")}</label>
              <select
                className="Selects"
                id="tipoPersona"
                {...register("idPersonType", { required: true })}
                required
              >
                <option key="" value="">
                  {t("register.typePerson_placeholder")}
                </option>
                {personTypes.map((type: any) => (
                  <option key={type.idPersonType} value={type.idPersonType}>
                    {type.namePersonType}
                  </option>
                ))}
              </select>
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.typeIdentification_label")}</label>
              <select
                className="Selects"
                id="tipoIdentificacion"
                {...register("idIdentificationType", { required: true })}
                required
              >
                <option key="" value="">
                  {t("register.typeIdentification_placeholder")}
                </option>
                {identificationTypes.map((type: any) => (
                  <option
                    key={type.idIdentificationType}
                    value={type.idIdentificationType}
                  >
                    {type.nameIdentificationType}
                  </option>
                ))}
              </select>
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.identificationNumber_label")}</label>
              <input
                className="inputs"
                type="text"
                id="identificacion"
                placeholder={t("register.identificationNumber_placeholder")}
                pattern="\d*" // Acepta solo números
                maxLength={10} // Limita a 10 dígitos
                {...register("identificationNumber", {
                  required: true,
                  minLength: 10,
                })}
                required
              />
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.name_label")}</label>
              <input
                className="inputs"
                placeholder={t("register.name_placeholder")}
                type="text"
                id="nombre"
                {...register("name", { required: true })}
                required
              />
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.lastname_label")}</label>
              <input
                className="inputs"
                placeholder={t("lastname_placeholder")}
                type="text"
                id="apellido"
                {...register("lastName", { required: true })}
                required
              />
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.email_label")}</label>
              <input
                className="inputs"
                type="email"
                id="correo"
                placeholder={t("register.email_placeholder")}
                {...register("email", {
                  required: true,
                  pattern: /^\S+@\S+$/i,
                })}
                required
              />
            </div>

            <div className="labelsAndInputs">
              <label>{t("register.phone_label")}</label>
              <input
                className="inputs"
                type="text"
                id="numero"
                placeholder={t("register.phone_placeholder")}
                pattern="\d*" // Acepta solo números
                maxLength={10} // Limita a 10 dígitos
                {...register("number", { required: true, minLength: 10 })}
                required
              />
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.username_label")}</label>
              <input
                className="inputs"
                type="text"
                id="usuario"
                placeholder={t("register.username_placeholder")}
                {...register("username", { required: true })}
                required
              />
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.password_label")}</label>
              <div className="passwordRegistro">
                <input
                  className="inputs"
                  type={passwordVisible ? "text" : "password"}
                  id="contraseña"
                  placeholder={t("register.password_placeholder")}
                  {...register("password", { required: true, minLength: 8 })}
                  required
                />
                <span onClick={togglePasswordVisibility}>
                  {passwordVisible ? <FaEye /> : <FaEyeSlash />}
                </span>
              </div>
            </div>
            <div className="labelsAndInputs">
              <label>{t("register.confirm_label")}</label>
              <div className="passwordRegistro">
                <input
                  className="inputs"
                  type={confirmPasswordVisible ? "text" : "password"}
                  id="confirmarContraseña"
                  {...register("confirmPassword", {
                    required: true,
                    minLength: 8,
                  })}
                  placeholder={t("register.confirm_placeholder")}
                  required
                />
                <span onClick={confirmTogglePasswordVisibility}>
                  {confirmPasswordVisible ? <FaEye /> : <FaEyeSlash />}
                </span>
              </div>
            </div>

            <div className="ButonR">
              <button type="submit">{t("register.submit_button")}</button>
            </div>

            <div className="labelAndA">
              <label>{t("register.already_account")} </label>
              <a className="A" href="/Auth/login">
                {t("register.login_link")}
              </a>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}

export default withPublic(RegisterPage);
