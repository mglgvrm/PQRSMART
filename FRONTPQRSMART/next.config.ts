import type { NextConfig } from "next";
const { i18n } = require("./next-i18next.config");

const nextConfig: NextConfig = {
  /* config options here */
  images: {
    domains: ["jxtyorqotieaseoelgfs.supabase.co"], // agrega tu dominio de Supabase
  },
  reactStrictMode: true,
};

export default nextConfig;
