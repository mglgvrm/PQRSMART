// Header.jsx
import React, { useEffect, useState } from 'react';
import './Header.css';
import { useNavigate } from 'react-router-dom';
import { Menu, X } from 'lucide-react';
import Modal from './Modal.jsx';
import { LuMenu } from 'react-icons/lu';
import { UserinfoAmin, UserinfoSecre, UserinfoUser } from '../Userinfo.jsx';

export function Header() {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const navigate = useNavigate();

    const handleOpenModal = () => setIsModalOpen(true);
    const handleCloseModal = () => setIsModalOpen(false);
    const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

    return (
        <header className="header">
            <div className="logo">
                <img src="/images/PQRSmart-Logo.png" alt="PQRSmart Logo" />
            </div>

            <button
                className="mobile-menu-btn"
                onClick={toggleMenu}
                aria-label="Toggle menu"
            >
                {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
            </button>

            <div className={`nav-container ${isMenuOpen ? 'open' : ''}`}>
                <nav className="nav">
                    <a href="#inicio" className="nav-link" onClick={() => setIsMenuOpen(false)}>Inicio</a>
                    <a href="#que-es" className="nav-link" onClick={() => setIsMenuOpen(false)}>¿Que es?</a>
                    <a href="#como-funciona" className="nav-link" onClick={() => setIsMenuOpen(false)}>Cómo Funciona</a>
                    <a href="#crear-solicitud" className="nav-link" onClick={() => {
                        handleOpenModal();
                        setIsMenuOpen(false);
                    }}>Crear Solicitud</a>
                    <a href="#contacto" className="nav-link" onClick={() => setIsMenuOpen(false)}>Contacto</a>
                    <button className="header-login-btn" onClick={() => {
                        navigate('/Login');
                        setIsMenuOpen(false);
                    }}>Iniciar Sesión</button>
                </nav>
            </div>
            <Modal isOpen={isModalOpen} onClose={handleCloseModal} />
        </header>
    );
}


export function HeaderUser() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);
    const navigate = useNavigate();

    const handleLogout = () => {
        localStorage.setItem('loggetPQRSMART', 'false');
        localStorage.setItem('tokenPQRSMART', '');
        localStorage.setItem('userPQRSMART', JSON.stringify(''));
        navigate('/');
    };

    const toggleSidebar = () => {
        setIsSidebarOpen(!isSidebarOpen);
    };

    return (
        <div className="HeaderUser">
            <header className='headerUser'>
                <div className="left">
                    <div className="Menu-container" onClick={toggleSidebar}>
                        <div className="Menus">
                            <LuMenu />
                        </div>
                    </div>
                    <div className="logomenu">
                        <img src="/images/PQRSmart-Logo.png" alt="PQRSmart Logo" className='logo-menu' />
                    </div>
                </div>
                <div className="right">
                    <UserinfoUser />
                </div>
            </header>
            <div className={`sideBar ${isSidebarOpen ? 'open' : ''}`}>
                <nav>
                    <ul className="list">
                        <li className="list__item" onClick={toggleSidebar}>
                            <img src="assets/dashboard.svg" className="list__img" onClick={() => navigate('/HomePage')} />
                            <a href="/HomePage" className="nav__link">Inicio</a>
                        </li>
                        <li className="list__item" onClick={toggleSidebar}>
                            <img src="assets/pencil.svg" className="list__img" onClick={() => navigate('/Crear')} />
                            <a href="/Crear" className="nav__link">Crear PQRS</a>
                        </li>
                        <li className="list__item" onClick={toggleSidebar}>
                            <img src="assets/lupa.svg" className="list__img" onClick={() => navigate('/Consultar')} />
                            <a href="/Consultar" className="nav__link">Consultar PQRS</a>
                        </li>
                        <li className="list__item" onClick={toggleSidebar}>
                            <img src="assets/salir.svg" className="list__img" onClick={handleLogout} />
                            <a href="/" className="nav__link" onClick={handleLogout}>Salir</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>
    );
}

export function HeaderAdmin() {
    const [sidebarWidth, setSidebarWidth] = useState('0rem');
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);
    const [expandedSections, setExpandedSections] = useState({});
    const navigate = useNavigate();
    const handleLogout = () => {
        localStorage.setItem('loggetPQRSMART', 'false');
        localStorage.setItem('tokenPQRSMART', '');
        localStorage.setItem('userPQRSMART', JSON.stringify(''));
        navigate('/');
    };

    const toggleSidebar = () => {
        setIsSidebarOpen(!isSidebarOpen);
    };

    const toggleSection = (section) => {
        setExpandedSections(prevState => ({
            ...prevState,
            [section]: !prevState[section]
        }));
    };


    return (
        <div className="HeaderUser">
            <header className='headerUser'>
                <div className="left">
                    <div className="Menu-container" onClick={toggleSidebar}>
                        <div className="Menus">
                            <LuMenu />

                        </div>
                    </div>
                    <div className="logomenu">
                        <img src="/images/PQRSmart-Logo.png" alt="PQRSmart Logo" />
                    </div>

                </div>
                <div className="right">
                    <UserinfoAmin />
                </div>
            </header>
            <div className={`sideBar ${isSidebarOpen ? 'open' : ''}`}>
                <nav>
                    <ul className="list">

                    <li className="">
                            <img src="assets/dashboard.svg" className="list__img" onClick={() => navigate('/HomePagesAdmin')}/>
                            <a href="/HomePagesAdmin" className="nav__link">Inicio</a>

                        </li>

                        <li className="">
                            <img src="assets/stats.svg" className="list__img" onClick={() => navigate('/Dashboard')}/>
                            <a href="/Dashboard" className="nav__link">Estadisticas</a>

                        </li>

                        {/* Gestion Usuario */}
                        <li className="list__item" onClick={() => toggleSection('userManagement')}>

                            <img src="assets/contacto.svg" className="list__img"  />
                            <span className="item">Gestión Usuario</span>
                            <img src="assets/arrow.svg" className="list__arrow" />

                        </li>
                        {expandedSections.userManagement && (
                            <>
                                <li className="list__inside">
                                    <a href="/VerUsuario" className="nav__link nav__link--inside">Ver Usuario</a>
                                </li>
                                <li className="list__inside">
                                    <a href="/CrearUsuario" className="nav__link nav__link--inside">Crear Usuario</a>
                                </li>
                            </>
                        )}

                        {/* Gestion Categorias */}
                        <li className="list__item" >

                            <img src="assets/dasboard.svg" className="list__img" />
                            <span className="item" onClick={() => toggleSection('categoryManagement')}>Gestión Categorías</span>
                            <img src="assets/arrow.svg" className="list__arrow" onClick={() => toggleSection('categoryManagement')} />

                        </li>
                        {expandedSections.categoryManagement && (
                            <>
                                <li className="list__inside">
                                    <a href="/VerCategoria" className="nav__link nav__link--inside">Ver Categorías</a>
                                </li>
                                <li className="list__inside">
                                    <a href="/CrearCategoria" className="nav__link nav__link--inside">Crear Categorías</a>
                                </li>
                            </>
                        )}

                        {/* Gestion Dependencias */}
                        <li className="list__item" >
                            <img src="assets/engranaje.svg" className="list__img" />
                            <span className="item" onClick={() => toggleSection('dependencyManagement')}>Gestión Dependencias</span>
                            <img src="assets/arrow.svg" className="list__arrow" onClick={() => toggleSection('dependencyManagement')} />


                        </li>
                        {expandedSections.dependencyManagement && (
                            <>
                                <li className="list__inside">
                                    <a href="/VerDependencia" className="nav__link nav__link--inside">Ver Dependencias</a>
                                </li>
                                <li className="list__inside">
                                    <a href="/CrearDependencias" className="nav__link nav__link--inside">Crear Dependencias</a>
                                </li>
                            </>
                        )}


                        <li className="list__item">
                            <img src="assets/salir.svg" className="list__img" onClick={handleLogout} />
                            <a href="/" className="nav__link" onClick={handleLogout}>Salir</a>
                        </li>

                    </ul>

                </nav>
            </div>
        </div>
    )
}


export function HeaderSecre() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(false);
    const navigate = useNavigate();
    const handleLogout = () => {
        localStorage.setItem('loggetPQRSMART', 'false');
        localStorage.setItem('tokenPQRSMART', '');
        localStorage.setItem('userPQRSMART', JSON.stringify(''));
        navigate('/');
    };

    const toggleSidebar = () => {
        setIsSidebarOpen(!isSidebarOpen);
    };

    return (
        <div className="HeaderUser">
            <header className='headerUser'>
                <div className="left">
                    <div className="Menu-container" onClick={toggleSidebar}>
                        <div className="Menus">
                            <LuMenu />

                        </div>
                    </div>
                    <div className="logomenu">
                        <img src="/images/PQRSmart-Logo.png" alt="PQRSmart Logo" />
                    </div>

                </div>
                <div className="right">
                    <UserinfoSecre />
                </div>
            </header>
            <div className={`sideBar ${isSidebarOpen ? 'open' : ''}`}>
                <nav>
                    <ul className="list">

                        <li className="list__item" onClick={toggleSidebar}>
                            <img src="assets/dashboard.svg" className="list__img" onClick={() => navigate('/HomePageSecre')} />
                            <a href="/HomePageSecre" className="nav__link">Inicio</a>

                        </li>

                        <li className="list__item" onClick={toggleSidebar}>
                            <img src="assets/pencil.svg" className="list__img" onClick={() => navigate('/GestionarPQRS')} />
                            <a href="/GestionarPQRS" className="nav__link">Gestionar PQRS</a>

                        </li>

                        <li className="list__item" onClick={toggleSidebar}>
                            <img src="assets/salir.svg" className="list__img" onClick={handleLogout} />
                            <a href="/" className="nav__link" onClick={handleLogout}>Salir</a>
                        </li>

                    </ul>

                </nav>
            </div>
        </div>
    )
}
