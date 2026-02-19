import React, { useState, useEffect } from 'react';
import './VerPqrs.css';

const VerPqrs = ({ isOpen, onClose, pqrs }) => {

    if (!isOpen) return null;
    return (
        <div className='VerPqrs'>
            <div className="modal-content">
                <h3>Detalles de la Solicitud PQRS</h3>
                <div className="modal-form">
                    <label>Tipo de Solicitud</label>
                    <input
                        type="text"
                        value={pqrs.requestType.nameRequestType || ''}
                        disabled
                    />

                    <label>Fecha</label>
                    <input
                        type="text"
                        value={pqrs.date || ''}
                        disabled
                    />

                    <label>Descripción</label>
                    <textarea
                        type="text"
                        rows="4"
                        value={pqrs.description || ''}
                        disabled
                    />

                    <label>Estado</label>
                    <input
                        type="text"
                        value={pqrs.requestState.nameRequestState || ''}
                        disabled
                    />

                    <label>Respuesta</label>
                    <textarea
                        rows="4"
                        type="text"
                        value={pqrs.answer || ''}
                        disabled
                    />

                    <div className="modal-buttons-pqrs">
                        <button onClick={onClose}>Cerrar</button>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default VerPqrs;
