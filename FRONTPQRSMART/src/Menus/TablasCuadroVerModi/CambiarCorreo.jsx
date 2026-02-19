import React, { useState } from 'react';
import Popup from '../../componentes/Popup';
import './CambiarCorreo.css'

const CambiarCorreo = ({ isOpen, onClose, usuario, onSave }) => {
    const [show, setShow] = useState(false);
    const [error, setError] = useState('');
    const [correo, setCorreo] = useState('');
    const [confirmarCorreo, setConfirmarCorreo] = useState('');
    const handleSave = () => {
        if (correo===confirmarCorreo){
        const updatedUser = {
            ...usuario,
            email: correo,
            id: usuario.id,
        };
        onSave(updatedUser);
    }else{
        setError('Correos no Coinciden.');
        setShow(true);
        return
    }
    };
    const closePopup = () => {
        setShow(false);
    };
    if (!isOpen) return null;

    return (
        <div className="modal-overlay">
            <div className="modal-content">
                <h3>Modificar Usuario</h3>
                <div className="modal-form">
                <label>Correo Electrónico</label>
                    <input
                        type="email"
                        onChange={(e) => setCorreo(e.target.value)}
                    />

                <label>Confirmar Correo Electrónico</label>
                    <input
                        type="email"
                        onChange={(e) => setConfirmarCorreo(e.target.value)}
                    />
                    

                    <div className="modal-buttons">
                        <button onClick={handleSave}>Guardar</button>
                        <button onClick={onClose}>Cancelar</button>
                    </div>
                </div>
            </div>
            {show && <Popup message={error} onClose={closePopup} />}
        </div>
    );
}

export default CambiarCorreo;
