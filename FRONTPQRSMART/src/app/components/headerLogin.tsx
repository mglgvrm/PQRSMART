"use client";

import { useTranslation } from "react-i18next";
import { motion } from "framer-motion";
import { Globe } from "lucide-react";

export default function HeaderLogin() {
  const { i18n } = useTranslation();
  const currentLang = i18n.language;

  const changeLanguage = (lang: "es" | "en") => {
    i18n.changeLanguage(lang);
  };
  return (
    <div className="absolute top-4 right-4">
      <motion.button
        whileTap={{ scale: 0.9 }}
        onClick={() => changeLanguage(currentLang === "es" ? "en" : "es")}
        className="flex items-center gap-2 px-4 py-3 rounded-xl bg-gradient-to-r from-blue-500 to-indigo-600 text-white text-sm font-semibold shadow-md hover:shadow-lg hover:from-indigo-600 hover:to-blue-500 transition-all duration-300"
        title={`Cambiar a ${currentLang === "es" ? "Inglés" : "Español"}`}
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
  );
}
