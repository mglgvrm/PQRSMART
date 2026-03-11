"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function withAuth(
  Component: React.ComponentType,
  allowedRoles: string[] = []
) {
  return function ProtectedPage(props: any) {
    const router = useRouter();

    useEffect(() => {
      const token = localStorage.getItem("token");
      const role = localStorage.getItem("role");

      // Si no hay token, redirige a login
      if (!token) {
        router.push("/Auth/login");
        return;
      }

      // Si hay roles permitidos, validarlos
      if (allowedRoles.length > 0 && !allowedRoles.includes(role || "")) {
        alert("No tienes permiso para acceder a esta página");
        router.push("/Auth/login");
      }
    }, [router]);

    return <Component {...props} />;
  };
}
