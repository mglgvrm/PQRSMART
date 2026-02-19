import React from 'react';
import { Routes, Route } from 'react-router-dom';
import { ProtectedRoute } from '../router/ProtectedRoute';
import  Login  from '../src/Menus/Login';
import { Navbar } from '../Navbar';
import  {HomePage, HomePageAdmin, HomePageSecre } from '../src/componentes/Menu/HomePage';
import Crear from '../src/Menus/User/Crear';
import Registro from '../src/Menus/Registro';
import Consultar from '../src/Menus/User/Consultar';
import GestionUsuario from '../src/Menus/Admin/GestionUsuario';
import GestionCategoria from '../src/Menus/Admin/GestionCategoria';
import GestionDependencia from '../src/Menus/Admin/GestionDependencia';
import Dashboard from '../src/Menus/Admin/Dashboard';
import CrearCategoria from '../src/Menus/Admin/CrearCategoria';
import CrearDependencias from '../src/Menus/Admin/CrearDependencias';
import CrearUsuario from '../src/Menus/Admin/CrearUsuario';
import GestionarPQRS from '../src/Menus/Secretario/GestionarPQRS';
import Responder from '../src/Menus/Secretario/Responder';
import { Activate, ActivatePage } from '../src/componentes/ActivatePage';
import { Recovery } from '../src/componentes/Recovery';
import { ResetPassword } from '../src/componentes/ResetPassword';
import { EditarPerfil } from '../src/componentes/Menu/EditarPerfil';
import TablaUsuarios from '../src/Menus/TablasCuadroVerModi/TablaUsuarios';
import Inicio from '../src/Menus/Inicio';


export const AppRouter = () => {
  return (
    <Routes>
      <Route path="/" element={<Navbar />}>
        <Route index element={<Inicio />} />
        <Route path="/inicio" element={<Inicio />} />
        <Route path="/Login" element={<Login />} />
        <Route path="/Recuperacion" element={<Recovery/>} />
        <Route path="/Registro" element={<Registro/>} />
        <Route path="/activate/:token" element={<ActivatePage/>} />
        <Route path="/activate-email/:token" element={<Activate/>} />
        <Route path="/reset-password/:token" element={<ResetPassword/>} />
        <Route path="/tabla" element={<TablaUsuarios/>} />

        <Route path="*" element={<Inicio />} />

        {/* Rutas protegidas */}

        {/* Rutas Admin */}
        <Route path="/HomePagesAdmin" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<HomePageAdmin />} />
        } />
        <Route path="/Dashboard" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<Dashboard />} />
        } />
        <Route path="/VerUsuario" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<GestionUsuario />} />
        } />
        <Route path="/VerCategoria" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<GestionCategoria />} />
        } />
        <Route path="/VerDependencia" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<GestionDependencia />} />
        } />
        <Route path="/CrearUsuario" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<CrearUsuario />} />
        } />
        <Route path="/CrearCategoria" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<CrearCategoria />} />
        } />
        <Route path="/CrearDependencias" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<CrearDependencias />} />
        } />
        <Route path="/perfil-admin" element={
          <ProtectedRoute allowedRoles={['ADMIN']} element={<EditarPerfil/>} />
        } />



        {/* Rutas Usuario */}
        <Route path="/HomePage" element={
          <ProtectedRoute allowedRoles={['USER']} element={<HomePage />} />
        } />
        <Route path="/Crear" element={
          <ProtectedRoute allowedRoles={['USER']} element={<Crear/>} />
        } />
        <Route path="/Consultar" element={
          <ProtectedRoute allowedRoles={['USER']} element={<Consultar/>} />
        } />
        <Route path="/perfil-user" element={
          <ProtectedRoute allowedRoles={['USER']} element={<EditarPerfil/>} />
        } />



        {/* Rutas Secretario */}
        <Route path="/HomePagesSecre" element={
          <ProtectedRoute allowedRoles={['SECRE']} element={<HomePageSecre />} />
        } />
        <Route path="/GestionarPQRS" element={
          <ProtectedRoute allowedRoles={['SECRE']} element={<GestionarPQRS />} />
        } />
        <Route path="/Responder" element={
          <ProtectedRoute allowedRoles={['SECRE']} element={<Responder />} />
        } />
        <Route path="/perfil-secre" element={
          <ProtectedRoute allowedRoles={['SECRE']} element={<EditarPerfil/>} />
        } />

      </Route>
    </Routes>
  );
};
