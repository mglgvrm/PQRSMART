// Modal.jsx
import React from 'react';
import './Modal.css';

function Modal({ isOpen, onClose }) {
    if (!isOpen) return null;

    return (
        <div className="modal-overlays" onClick={onClose}>
            <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                <h2>Acción requerida</h2>
                <p>Para crear una solicitud debes <a className="modal-content-a" href="/Login" >iniciar sesión.</a> Si no tienes cuenta, <a className="modal-content-a" href="/Registro">regístrate</a>.</p>
                <button className="modal-close-btn" onClick={onClose}>Cerrar</button>
            </div>
        </div>
    );
}

export default Modal;
