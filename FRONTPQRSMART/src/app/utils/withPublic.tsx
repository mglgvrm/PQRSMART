"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function withPublic(Component: React.ComponentType) {
  return function PublicPage(props: any) {
    const router = useRouter();

    useEffect(() => {
      const token = localStorage.getItem("token");
      const role = localStorage.getItem("role");
      if (token) {
        if (role === "ROLE_ADMIN") {
          router.push("/admin/home");
          return;
        }
        if (role === "ROLE_USER") {
          router.push("/user/dashboard");
          return;
        }
        if (role === "ROLE_SECRE") {
          router.push("/secretariat/dashboard");
          return;
        }
        // Si ya hay token, redirige al dashboard
        router.push("/dashboard");
      }
    }, [router]);

    return <Component {...props} />;
  };
}
