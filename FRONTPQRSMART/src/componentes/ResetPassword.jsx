import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate, useParams } from 'react-router-dom';
import './ResetPassword.css'
import Popup from '../componentes/Popup'
import { FaEye, FaEyeSlash } from 'react-icons/fa';

export const ResetPassword = () => {
    const { token } = useParams(); // obtener el token de la URL
    const navigate = useNavigate();
    const [newPassword, setNewPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [isLogged, setIsLogged] = useState('');
    const [showPopup, setShowPopup] = useState(false);
    const [error, setError] = useState('');
    const [passwordVisible, setPasswordVisible] = useState(false);
    const [confirmPasswordVisible, setConfirmPasswordVisible] = useState(false);


    // Cargar el archivo Gradient.js
    useEffect(() => {
        checkLoginStatus();
        const script = document.createElement('script');
        script.src = '/Gradient.js'; // Ruta directa al archivo en public
        script.async = true;
        document.body.appendChild(script);

        script.onload = () => {
            // Inicializar el gradiente una vez que el script haya cargado
            const gradient = new Gradient();
            gradient.initGradient('#gradient-canvas');
        };

        return () => {
            document.body.removeChild(script);
        };
    }, []); // Solo se ejecuta una vez al montar el componente

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
    const validatePassword = (password) => {
        const minLength = password.length >= 8;
        const hasUpperCase = /[A-Z]/.test(password);
        const hasLowerrCase = /[a-z]/.test(password);
        const hasNumber = /\d/.test(password);
        const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>/?]/.test(password);

        return minLength && hasUpperCase && hasNumber && hasSpecialChar && hasLowerrCase;
    };

    const handleResetPassword = async (e) => {
        e.preventDefault();
        const isValidPassword = validatePassword(newPassword);
        if (!isValidPassword) {
            setError('La contraseña debe tener mínimo 8 caracteres, al menos un número, un signo y una letra mayúscula.');
            setShowPopup(true); // Mostrar popup
            return;
        } else {
            setError('Contraseña valida.');
            setShowPopup(true); // Mostrar popup

        }

        if (newPassword !== confirmPassword) {
            setError('Las contraseñas no coinciden.');
            setShowPopup(true); // Mostrar popup
            return;
        }
        else {
            setError('Contraseña valida.');
            setShowPopup(true); // Mostrar popup

        }

        try {
            axios.post(`/forgot-password/reset/${token}`, { newPassword });
            setError('Contraseña actualizada.');
            setShowPopup(true); // Mostrar popup
            if (showPopup === false) {
                navigate('/login')
            }

        } catch (error) {
            setError('Error al restablecer contraseña:');
            setShowPopup(true); // Mostrar popup('Error al restablecer contraseña.');
            return;
        }
        return;
    };
    if (isLogged) {
        return null; // o un spinner si quieres mostrar algo mientras se redirige
    }

    const closePopup = () => {
        setShowPopup(false);
    };
    const togglePasswordVisibility = () => {
        setPasswordVisible(!passwordVisible);
    };
    const confirmTogglePasswordVisibility = () => {
        setConfirmPasswordVisible(!confirmPasswordVisible);
    };

    return (
        <div className='ResetPassword'>
            <canvas id="gradient-canvas" style={{ width: '100vw', height: '100vh', position: 'absolute', zIndex: -1 }}></canvas>
            <div className="reset">
                <form onSubmit={handleResetPassword}>
                    <h2>Restablecer Contraseña</h2>
                    <div className="passwordReset">
                        <label htmlFor="">Contraseña: </label>
                        <div className="passwordRegistro">
                            <input
                                type={passwordVisible ? 'text' : 'password'}
                                placeholder="Ingrese la nueva contraseña"
                                value={newPassword}
                                onChange={(e) => setNewPassword(e.target.value)}
                            />
                            <span
                                onClick={togglePasswordVisibility}
                            >
                                {passwordVisible ? <FaEye /> : <FaEyeSlash />}
                            </span>
                        </div>
                    </div>

                    <div className="passwordReset">
                        <label htmlFor="">Confirmar Contraseña: </label>
                        <div className="passwordRegistro">
                            <input
                                type={confirmPasswordVisible ? 'text' : 'password'}

                                placeholder="Confirme la nueva contraseña"
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                            />
                            <span
                                onClick={confirmTogglePasswordVisibility}
                            >
                                {confirmPasswordVisible ? <FaEye /> : <FaEyeSlash />}
                            </span>
                        </div>
                    </div>
                    <div className="btnConfirPassw">
                        <button type='submit'>Restablecer contraseña</button>
                    </div>

                </form>
            </div>
            {showPopup && <Popup message={error} onClose={closePopup} />}
        </div>
    );
};

