import React, { useEffect, useRef, useState } from 'react';
import '../Secretario/Responder.css'

const Responder = ({ pqrs, onRechazar, onSave, onClose, isOpen }) => {

    const [formData, setFormData] = useState({
        answer: pqrs.answer,
        file: null, // Nuevo estado para el archivo
    });

    const handleSave = () => {
        const updatedPqrs = {
            ...pqrs,
            answer: formData.answer,
            requestState: { idRequestState: 2 },
            idRequest: pqrs.idRequest,
            archivoAnswer: formData.file, // Incluir archivo en el guardado
        };
        onSave(updatedPqrs);
    };

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };
    const handleFileChange = (e) => {
        setFormData({
            ...formData,
            file: e.target.files[0]
        })
    }
    useEffect(() => {
        document.title = "Responder PQRS"

    }, []);

    if (!isOpen) return null;

    return (
        <div className="modalResponder">
            <div className="modal-content-Responder">
                <label className="titleResponder">Respueta:</label>
                <div className="input-box-Responder">
                    <textarea
                        name="answer"
                        id="answer"
                        rows="4"
                        cols="50"
                        value={formData.answer || ''}
                        onChange={handleChange}
                        required
                    ></textarea>

                    <label>Adjuntar Evidencia (opcional)</label>
                    <input type="file" className="file-input-Responder" id='file'
                        onChange={handleFileChange} // Manejar el archivo name='archivo'


                    />


                    <div className="enviar">
                        <button onClick={handleSave}>Enviar</button>
                        <button onClick={() => onRechazar(pqrs.idRequest)}>Rechazar</button>
                        <button onClick={onClose}>Cancelar</button>
                    </div>

                </div>
            </div>

        </div>
    );
}

export default Responder;
