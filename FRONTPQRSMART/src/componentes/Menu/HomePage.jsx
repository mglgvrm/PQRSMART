import React, { useEffect } from 'react';
import './HomePage.css';
import { HeaderAdmin, HeaderSecre, HeaderUser } from '../Inicio/Header.jsx';

export const HomePage = () => {
    const name = localStorage.getItem('users');

    return (
        <div className="HomePage">

            <HeaderUser />

            <div className="cuerpos">
                <div className="headers">
                    <title className='titulo'>Bienvenido {name}</title>

                </div>
                <div className="mision">
                    <p className='p1'>Mision: </p>
                    <p className='p2'>Brindar soluciones efectivas a través de una atención ágil, transparente y empática, gestionando cada petición, queja reclamo y sugerencia con el compromiso de mejorar continuamente la experiencia de nuestros usuarios.</p>
                </div>
            </div>
        </div>

    );
};

export const HomePageAdmin = () => {

    const name = localStorage.getItem('users');
    return (
        <div className="HomePage">

            <HeaderAdmin />

            <div className="cuerpos">
                <div className="headers">
                    <title className='titulo'>Bienvenido {name}</title>

                </div>

                <div className="mision">
                    <p className='p1'>Mision: </p>
                    <p className='p2'>Brindar soluciones efectivas a través de una atención ágil, transparente y empática, gestionando cada petición, queja reclamo y sugerencia con el compromiso de mejorar continuamente la experiencia de nuestros usuarios.</p>
                </div>

            </div>
        </div>

    );
};


export const HomePageSecre = () => {

    const name = localStorage.getItem('users');
    return (
        <div className="HomePage">
              <HeaderSecre />
            <div className="cuerpos">
                <div className="headers">
                    <title className='titulo'>Bienvenido {name}</title>

                </div>

                <div className="mision">
                    <p className='p1'>Mision: </p>
                    <p className='p2'>Brindar soluciones efectivas a través de una atención ágil, transparente y empática, gestionando cada petición, queja reclamo y sugerencia con el compromiso de mejorar continuamente la experiencia de nuestros usuarios.</p>
                </div>

            </div>
        </div>

    );
};