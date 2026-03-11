"use client";

import { useEffect, useState } from "react";
import withAuth from "@/app/utils/withAuth";
import api from "@/app/api/api";
import NavbarUser from "../components/navbar_user";
import Navbar from "../components/navbar";
import NavbarSecretariat from "../components/navbar_secretariat";
import { useTranslation } from "react-i18next";

interface User {
  id: number;
  name: string;
  lastName: string;
  email: string;
  user: string;
  identificationNumber: string;
  stateUser: string;
  role: string;
  number: string;
  profileImage?: string;
}

const Profile = () => {
  const [user, setUser] = useState<User | null>(null);
  const { t } = useTranslation("common");

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const token = localStorage.getItem("token"); // JWT
        const response = await api.get("/Usuario/profile", {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        setUser(response.data);
        console.log(response.data);
      } catch (error) {
        console.error("Error al obtener usuario", error);
      }
    };

    fetchUser();
  }, []);
  const handleFileChange = async (
    e: React.ChangeEvent<HTMLInputElement>,
    user: any,
  ) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const formData = new FormData();
    formData.append("profileImage", file);

    try {
      const token = localStorage.getItem("token");
      const response = await api.patch(
        `/users/photo/upload/${user.id}`,
        formData,
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "multipart/form-data",
          },
        },
      );

      setUser({
        ...user,
        profileImage: response.data.profileImage,
      });
      console.log(response);
    } catch (error) {
      console.error("Error subiendo la foto:", error);
    }
  };

  if (!user) return <p className="text-center mt-10">{t("profile.loading")}</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col items-center font-sans">
      {/* Header */}
      <header className="w-full bg-green-600 text-white shadow-md">
        {user.role === "admin" ? (
          <Navbar />
        ) : user.role === "USER" ? (
          <NavbarUser />
        ) : (
          <NavbarSecretariat />
        )}
      </header>

      <h1 className="text-4xl font-bold mt-6 mb-4">{t("profile.title")}</h1>

      <div className="bg-white shadow-lg rounded-xl p-6 w-96">
        <div className="flex flex-col items-center">
          {/*<div className="flex items-center space-x-4 mt-4">
             Imagen de perfil 
            {user.profileImage ? (
              <img
                src={user.profileImage}
                alt="Profile"
                width={96}
                height={96}
                className="w-24 h-24 rounded-full object-cover"
              />
            ) : (
              <div className="w-24 h-24 rounded-full bg-gray-300 flex items-center justify-center text-gray-500">
                {localStorage.getItem("initial")}
              </div>
            )}

            {/* Botón de subir foto 
            <div>
              <label
                htmlFor="profileUpload"
                className="cursor-pointer bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md text-sm font-medium"
              >
                {t("profile.upload_photo")}
              </label>
              <input
                type="file"
                id="profileUpload"
                className="hidden"
                accept="image/*"
                onChange={(e) => handleFileChange(e, user)}
              />
            </div>
          </div>*/}

          <div className="w-full mt-4">
            <div className="grid grid-cols-1 gap-4">
              <div>
                <div className="text-gray-400 text-sm uppercase">
                  {t("profile.name")}
                </div>
                <div className="text-gray-800 font-medium text-lg">
                  {user.name}
                </div>
              </div>

              <div>
                <div className="text-gray-400 text-sm uppercase">
                  {t("profile.lastname")}
                </div>
                <div className="text-gray-800 font-medium text-lg">
                  {user.lastName}
                </div>
              </div>

              <div>
                <div className="text-gray-400 text-sm uppercase">
                  {t("profile.identification")}
                </div>
                <div className="text-gray-800 font-medium text-lg">
                  {user.identificationNumber}
                </div>
              </div>

              <div>
                <div className="text-gray-400 text-sm uppercase">
                  {t("profile.email")}
                </div>
                <div className="text-gray-800 font-medium text-lg">
                  {user.email}
                </div>
              </div>

              <div>
                <div className="text-gray-400 text-sm uppercase">
                  {t("profile.role")}
                </div>
                <div className="text-gray-800 font-medium text-lg">
                  {user.role}
                </div>
              </div>

              <div>
                <div className="text-gray-400 text-sm uppercase">
                  {t("profile.number")}
                </div>
                <div className="text-gray-800 font-medium text-lg">
                  {user.number}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

// Protección del componente según roles
export default withAuth(Profile, ["ROLE_USER", "admin", "secretariat"]);
