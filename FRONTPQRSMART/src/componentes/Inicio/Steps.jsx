// Steps.jsx
import React from 'react';
import './Steps.css';

function Steps() {
    return (
        <section id="como-funciona" className="steps">
            <h2>¿Cómo Funciona?</h2>
            <div className="step-cards">
                <div className="step-card">
                    <h3>Paso 1</h3>
                    <p>Iniciar Sesión o Registrarse</p>
                </div>
                <div className="step-card">
                    <h3>Paso 2</h3>
                    <p>Crear una Solicitud</p>
                </div>
                <div className="step-card">
                    <h3>Paso 3</h3>
                    <p>Recibir Respuesta</p>
                </div>
            </div>
        </section>
    );
}

export default Steps;
