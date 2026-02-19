// Banner.jsx
import React, { useState } from 'react';
import './Banner.css';
import Modal from './Modal';

function Banner() {
    const [isModalOpen, setIsModalOpen] = useState(false);

    const handleOpenModal = () => setIsModalOpen(true);
    const handleCloseModal = () => setIsModalOpen(false);

    return (
        <section className="banner" id='inicio'>
            <h1 className="banner-title">Bienvenido al Sistema PQRSmart</h1>
            <p className="banner-description">Tu Gestion Nuestra Prioridad.</p>
            <p className="banner-description">Crea Tu Solicitud AQUI.</p>
            <button className="primary-btn" onClick={handleOpenModal}>Crear Solicitud</button>
            <Modal isOpen={isModalOpen} onClose={handleCloseModal} />
        </section>
    );
}

export default Banner;
