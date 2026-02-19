import React from 'react';
import './Popup.css'; // Asegúrate de tener tus estilos aquí

const Popup = ({ message, onClose }) => {
    return (
        <div className="popup-overlay">
            <div className="popup-content">
                <p>{message}</p>
                <button onClick={onClose} className="popup-button">Cerrar</button>
            </div>
        </div>
    );
};

export default Popup;
