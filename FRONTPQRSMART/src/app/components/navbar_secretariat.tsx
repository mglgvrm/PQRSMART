"use client";
import {
  Disclosure,
  DisclosureButton,
  DisclosurePanel,
  Menu,
  MenuButton,
  MenuItem,
  MenuItems,
} from "@headlessui/react";
import { Bars3Icon, BellIcon, XMarkIcon } from "@heroicons/react/24/outline";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import api from "../api/api";
import { useTranslation } from "react-i18next";
import { motion } from "framer-motion";
import { Globe } from "lucide-react";

function classNames(...classes: (string | undefined | false | null)[]): string {
  return classes.filter(Boolean).join(" ");
}

function NavbarSecretariat() {
  const { i18n } = useTranslation();
  const currentLang = i18n.language;
  const { t } = useTranslation("common");
  const changeLanguage = (lang: "es" | "en") => {
    i18n.changeLanguage(lang);
  };
  const pathname = usePathname();
  // TODO: Set currentUser based on actual authentication logic or route, if needed.
  const navigation = [
    {
      name: t("header.home_link"),
      href: "/secretariat/dashboard",
      current: pathname === "/secretariat/dashboard",
    },
    {
      name: t("header.pqrs_link"),
      href: "/secretariat/pqrs",
      current: pathname === "/secretariat/pqrs",
    },
  ];
  const router = useRouter();
  const handleLogout = () => {
    const confirmLogout = window.confirm(t("header.logout_confirmation"));
    if (confirmLogout) {
      localStorage.removeItem("token");
      localStorage.removeItem("role");
      router.push("/Auth/login");
    }
  };
  const [initial, setInitial] = useState("");
  const [image, setImage] = useState({ profileImage: "" });
  useEffect(() => {
    // This effect runs once on mount to update the current navigation item
    navigation.forEach((item) => {
      item.current = pathname === item.href;
    });
    const fetchProfileImage = async () => {
      const token = localStorage.getItem("token"); // JWT
      const response = await api.get("/users/profileImage", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      setImage(response.data);
    };
    // Esto solo se ejecuta en el cliente
    const storedInitial = localStorage.getItem("initial");
    if (storedInitial) {
      setInitial(storedInitial);
    }
    fetchProfileImage();
  }, []);
  useEffect(() => {
    if (image?.profileImage) {
      console.log("Imagen cargada:", image.profileImage);
    }
  }, [image]);
  return (
    <Disclosure
      as="nav"
      className="relative bg-[#023047] after:pointer-events-none after:absolute after:inset-x-0 after:bottom-0 after:h-px after:bg-white/10"
    >
      <div className="mx-auto max-w-7xl px-2 sm:px-6 lg:px-8">
        <div className="relative flex h-16 items-center justify-between">
          <div className="absolute inset-y-0 left-0 flex items-center sm:hidden">
            {/* Mobile menu button*/}
            <DisclosureButton className="group relative inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-white/5 hover:text-white focus:outline-2 focus:-outline-offset-1 focus:outline-indigo-500">
              <span className="absolute -inset-0.5" />
              <span className="sr-only">Open main menu</span>
              <Bars3Icon
                aria-hidden="true"
                className="block size-6 group-data-open:hidden"
              />
              <XMarkIcon
                aria-hidden="true"
                className="hidden size-6 group-data-open:block"
              />
            </DisclosureButton>
          </div>
          <div className="flex flex-1 items-center justify-center sm:items-stretch sm:justify-start">
            <div className="flex shrink-0 items-center">
              <h1 className="text-2xl font-bold">{t("header.title")}</h1>
            </div>
            <div className="hidden sm:ml-6 sm:block">
              <div className="flex space-x-4">
                {navigation.map((item) => (
                  <a
                    key={item.name}
                    href={item.href}
                    aria-current={item.current ? "page" : undefined}
                    className={classNames(
                      item.current
                        ? "bg-gray-950/50 text-white"
                        : "text-gray-300 hover:bg-white/5 hover:text-white",
                      "rounded-md px-3 py-2 text-sm font-medium"
                    )}
                  >
                    {item.name}
                  </a>
                ))}
              </div>
            </div>
          </div>
          <div className="absolute inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0">
            <button
              type="button"
              className="relative rounded-full p-1 text-gray-400 hover:text-white focus:outline-2 focus:outline-offset-2 focus:outline-indigo-500"
            >
              <span className="absolute -inset-1.5" />
              <span className="sr-only">{t("header.view_notifications")}</span>
              <BellIcon aria-hidden="true" className="size-6" />
            </button>

            {/* Profile dropdown */}
            <Menu as="div" className="relative ml-3 ">
              <MenuButton className="relative cursor-pointer flex rounded-full focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-500">
                <span className="absolute -inset-1.5" />
                <span className="sr-only">Open user menu</span>
                {image.profileImage ? (
                  <img
                    alt="Foto de perfil"
                    src={image.profileImage}
                    className="size-8 rounded-full bg-gray-800 outline -outline-offset-1 outline-white/10 object-cover"
                  />
                ) : (
                  <div className="size-8 rounded-full bg-[#fafafa] text-[#023047] text-xl font-bold flex items-center justify-center outline -outline-offset-1 outline-white/10">
                    {initial?.charAt(0).toUpperCase() || "?"}
                  </div>
                )}
              </MenuButton>

              <MenuItems
                transition
                className="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-gray-800 py-1 outline -outline-offset-1 outline-white/10 transition data-closed:scale-95 data-closed:transform data-closed:opacity-0 data-enter:duration-100 data-enter:ease-out data-leave:duration-75 data-leave:ease-in"
              >
                <MenuItem>
                  <a
                    href="/profile"
                    className="block px-4 py-2 text-sm text-gray-300 data-focus:bg-white/5 data-focus:outline-hidden"
                  >
                    {t("header.your_profile")}
                  </a>
                </MenuItem>

                <MenuItem>
                  <a
                    onClick={handleLogout}
                    className="block px-4 py-2 text-sm text-gray-300 data-focus:bg-white/5 data-focus:outline-hidden"
                  >
                    {t("header.logout_button")}
                  </a>
                </MenuItem>
              </MenuItems>
            </Menu>

            {/* 🔹 Idioma */}
            <div className="flex items-center space-x-2  ml-3  cursor-pointer">
              <motion.button
                whileTap={{ scale: 0.9 }}
                onClick={() =>
                  changeLanguage(currentLang === "es" ? "en" : "es")
                }
                className="flex items-center gap-2 px-3 py-2 rounded-xl bg-gradient-to-r from-blue-500 to-indigo-600 text-white text-sm font-semibold shadow-md hover:shadow-lg hover:from-indigo-600 hover:to-blue-500 transition-all duration-300"
                title={`Cambiar a ${
                  currentLang === "es" ? "Inglés" : "Español"
                }`}
              >
                <Globe className="w-4 h-4" />
                <motion.span
                  key={currentLang}
                  initial={{ opacity: 0, y: -5 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3 }}
                >
                  {currentLang === "es" ? "ES 🇪🇸" : "EN 🇺🇸"}
                </motion.span>
              </motion.button>
            </div>
          </div>
        </div>
      </div>

      <DisclosurePanel className="sm:hidden">
        <div className="space-y-1 px-2 pt-2 pb-3">
          {navigation.map((item) => (
            <DisclosureButton
              key={item.name}
              as="a"
              href={item.href}
              aria-current={item.current ? "page" : undefined}
              className={classNames(
                item.current
                  ? "bg-gray-950/50 text-white"
                  : "text-gray-300 hover:bg-white/5 hover:text-white",
                "block rounded-md px-3 py-2 text-base font-medium"
              )}
            >
              {item.name}
            </DisclosureButton>
          ))}
        </div>
      </DisclosurePanel>
    </Disclosure>
  );
}

export default NavbarSecretariat;
