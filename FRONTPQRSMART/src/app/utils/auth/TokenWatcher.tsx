"use client";

import { useEffect } from "react";
import { checkTokenExpiration } from "./checkTokenExpiration";

export default function TokenWatcher() {
  useEffect(() => {
    checkTokenExpiration();
  }, []);

  return null;
}
