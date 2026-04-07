import { number } from "framer-motion";
import { jwtDecode } from "jwt-decode";

export const checkTokenExpiration = () => {
  const token = localStorage.getItem("token");

  if (!token) {
    logout();
    return;
  }

  try {
    const decoded = jwtDecode(token);

    const currentTime = Date.now() / 1000;

    if (decoded.exp && decoded.exp < currentTime) {
      logout();
    }
    return;
  } catch (error) {
    logout();
  }
};

const logout = () => {
  const publicRoutes = [
    "/",
    "/Auth/login",
    "/Auth/register",
    "/Auth/forgot-password",
    "/Auth/reset-password/{token}",
    "/Auth/verify-email/{token}",
  ];

  const currentPath = window.location.pathname;

  // Si es /Auth/reset-password/ALGO
  if (currentPath.startsWith("/Auth/reset-password/")) return;

  if (currentPath.startsWith("/Auth/verify-email/")) return;

  if (publicRoutes.includes(currentPath)) return;

  localStorage.removeItem("token");
  localStorage.removeItem("role");
  window.location.href = "/Auth/login";
};
