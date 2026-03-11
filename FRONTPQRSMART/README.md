---
## 🔵 **README para el Frontend (Next.js)**

# 🔵 PQRSmart Frontend (Next.js)

Aplicación web construida con **Next.js 14** para gestionar el sistema de **PQRS**.
Consume la API REST del backend desarrollado en **NestJS**, usando **Axios** para peticiones HTTP y **React Hook Form** para validaciones de formularios.
Implementa autenticación con **JWT**, protección de rutas privadas (**Dashboard**) y control de acceso según el rol del usuario.
---

## ✨ Características principales

- ⚡ Interfaz moderna con **Next.js 14** y soporte SSR/CSR.
- 📝 Formularios validados con **React Hook Form**.
- 🌐 Consumo de API backend con **Axios**.
- 🔐 Protección de rutas privadas con **Higher-Order Components** (`withAuth`, `withPublic`).
- 🔑 Manejo de sesión con **localStorage** y redirección dinámica según rol (`user`, `doctor`, `secretaria`).
- 📱 Diseño responsivo y adaptable a múltiples dispositivos.

---

## 🚀 Instalación y uso

### 📦 Requisitos previos

- Node.js 18+
- npm o yarn
- Backend (NestJS) en ejecución

### ⚙️ Pasos de instalación

```bash
# Clonar repositorio
git clone <URL_DEL_REPO_FRONTEND>
cd pqrsmart-frontend

# Instalar dependencias
npm install

# Ejecutar en desarrollo
npm run dev
```

El frontend estará disponible en: **http://localhost:3000**
