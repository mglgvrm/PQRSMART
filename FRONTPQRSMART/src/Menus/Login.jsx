import React, { useEffect, useState } from 'react';
import './Login.css'
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import Popup from '../componentes/Popup'
import { FaEye, FaEyeSlash } from 'react-icons/fa';

function Login() {
    const navigate = useNavigate();
    const [user, setUser] = useState('');
    const [password, setPassword] = useState('');
    const [isLogged, setIsLogged] = useState('');
    const [rememberMe, setRememberMe] = useState(false);
    const [passwordVisible, setPasswordVisible] = useState(false);
    const [showPopup, setShowPopup] = useState(false);
    const [error, setError] = useState('');

    // Cargar el archivo Gradient.js
    useEffect(() => {
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
    useEffect(() => {
        document.title = "Login"
        const storedUsername = localStorage.getItem('username');


        if (storedUsername) {
            setUser(storedUsername);
            setRememberMe(true);
        }
        checkLoginStatus();
    }, []);
    const togglePasswordVisibility = () => {
        setPasswordVisible(!passwordVisible);
    };
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

    const onLogin = async (e) => {
        e.preventDefault();

        try {
            const response = await axios.post('/api/auth/authenticate', {
                user,
                password,
            });
            console.log(response)

            if (response.status === 200) {
                const responseData = response.data;
                console.log(responseData)

                const { token, authorities } = response.data;
                localStorage.setItem('tokenPQRSMART', token);
                localStorage.setItem('userPQRSMART', JSON.stringify({ user, role: authorities[0] })); // Assuming single role
                const response1 = await axios.get('/api/auth/editar', {
                    headers: {
                        'Authorization': `Bearer ${token}`
                    }
                });
                localStorage.removeItem('username');
                const users = (response1.data.user)
                console.log(users)
                localStorage.setItem('users', users);
                if (authorities.includes('ADMIN')) {
                    window.location.href = '/HomePagesAdmin';
                    localStorage.setItem('loggetPQRSMART', true);
                } else if (authorities.includes('USER')) {
                    window.location.href = '/HomePage';
                    localStorage.setItem('loggetPQRSMART', true);
                } else if (authorities.includes('SECRE')) {
                    window.location.href = '/HomePagesSecre';
                    localStorage.setItem('loggetPQRSMART', true);
                } else {

                    window.location.href = '/';

                }

            }
        } catch (error) {
            const status = error.response && error.response.status;
            // Manejo de errores
            if (status === 401) {
                setError('Usuario y/o Contraseña incorrecta');
            } else if (status === 403) {
                setError("La cuenta está inactiva. Por favor verifique su correo para activar.");
            } else if (status === 423) {
                setError("La cuenta está bloqueada.");
            } else if (status === 500) {
                setError("Error en el servidor. Intente nuevamente más tarde.");
            }
            else {
                setError("Error en el servidor. Intente nuevamente más tarde.");
            }
            setShowPopup(true); // Mostrar popup
            return;
        }
        if (rememberMe) {
            localStorage.removeItem('username')
            localStorage.setItem('username', user);
        }
    }

    if (isLogged) {
        return null; // o un spinner si quieres mostrar algo mientras se redirige
    }

    const closePopup = () => {
        setShowPopup(false);
    };
    return (
        <div className="login-container">
            <canvas id="gradient-canvas" style={{ width: '100vw', height: '100vh', position: 'absolute', zIndex: -1 }}></canvas>
            <div className="login-box">
                <div className="logo-section">
                    <h1 className='PQRSmart'>PQRSmart</h1>
                    <div className="vertical-line"></div> {/* Línea vertical */}
                </div>
                <div className="form-section">
                    <div className="titulologin">
                        <h1>Iniciar sesión</h1>
                    </div>
                    <form onSubmit={onLogin}>
                        <div className="user-box">
                            <input
                                type="text"
                                required
                                id="user" value={user} onChange={e => setUser(e.target.value.toLowerCase())}
                            />

                            <label>Usuario</label>
                        </div>
                        <div className="user-box">
                            <div className="password-wrapper">
                                <input
                                    type={passwordVisible ? 'text' : 'password'}
                                    required
                                    id="password"
                                    value={password}
                                    onChange={e => setPassword(e.target.value)}
                                    
                                />
                                <label>Contraseña</label>
                                <span
                                    onClick={togglePasswordVisibility}>
                                    {passwordVisible ? <FaEye /> : <FaEyeSlash />}
                                </span>
                            </div>

                        </div>

                        <div className="btn-container">
                            <button type="submit" className="btn fifth">Iniciar sesión</button>
                        </div>
                        <div className="Checkbox">
                            <div className="CheckboxYRegistro">
                                <a href="/Registro">Registrar</a>
                                <label>
                                    <input type="checkbox" checked={rememberMe}
                                        onChange={(e) => setRememberMe(e.target.checked)} />
                                    Recordar
                                </label>
                            </div>
                        </div>
                        <div className="OlvidasteContra">
                            <a href="/Recuperacion">¿Olvidaste tu contraseña?</a>
                        </div>
                    </form>
                </div>
                {showPopup && <Popup message={error} onClose={closePopup} />}
            </div>
        </div>
    );
}

export default Login;


