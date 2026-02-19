import React, { useEffect, useState } from "react";
import './Recovery.css';
import axios from "axios";
import Popup from '../componentes/Popup';

export const Recovery = () => {
    const [email, setEmail] = useState('');
    const [isLogged, setIsLogged] = useState('');
    const [showPopup, setShowPopup] = useState(false);
    const [error, setError] = useState('');

    const checkLoginStatus = () => {
        const logged = localStorage.getItem('loggetPQRSMART') === 'true';
        setIsLogged(logged);
        console.log('loggetPQRSMART: ', logged);
        if (logged) {
            const userData = JSON.parse(localStorage.getItem('userPQRSMART'));
            if (userData) {
                const { role } = userData;
                if (role === 'ADMIN') {
                    navigate('/HomePagesAdmin');
                } else if (role === 'USER') {
                    navigate('/HomePage');
                } else if (role === 'SECRE') {
                    navigate('/HomePagesSecre');
                }
            }
        }
    };

    useEffect(() => {
        checkLoginStatus();
        const script = document.createElement('script');
        script.src = '/Gradient.js'; // Ruta directa al archivo en public
        script.async = true;
        document.body.appendChild(script);

        script.onload = () => {
            const gradient = new Gradient();
            gradient.initGradient('#gradient-canvas');
        };

        return () => {
            document.body.removeChild(script);
        };
    }, []); // Solo se ejecuta una vez al montar el componente

    const handleResetRequest = async () => {
        try {
            console.log(email);
            const response = await axios.post('/forgot-password/email', { email });
            setError("Éxito");
            setEmail('')
            setShowPopup(true); // Mostrar popup
            return;
        } catch (error) {
            console.error('Error al solicitar restablecimiento de contraseña:', error);
        }
    };

    if (isLogged) {
        return null; // o un spinner si quieres mostrar algo mientras se redirige
    }

    const closePopup = () => {
        setShowPopup(false);
    };

    return (
        <div className="recovery">
            <canvas id="gradient-canvas"
                    style={{width: '100vw', height: '100vh', position: 'absolute', zIndex: -1}}></canvas>
            <div className="reco">
                <h2>¿Olvidaste tu contraseña?</h2>
                <label>Para recuperar tu contraseña, ingresa tu Email o Número:</label>
                <br/>
                <div className="input-box2">
                    <label htmlFor="email">Email:</label>
                    <input
                        type="text"
                        id="email"
                        name="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                </div>
                <div className="btnSolicitar">
                    <button onClick={handleResetRequest}>Solicitar</button>
                </div>
                <div className="PAndA">
                    <p>¿Ya tienes cuenta? <a href="/Login">Inicia Sesión</a></p>
                </div>
            </div>
            {showPopup && <Popup message={error} onClose={closePopup}/>}
        </div>
    );
}

