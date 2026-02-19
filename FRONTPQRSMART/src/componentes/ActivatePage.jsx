import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate, useParams } from 'react-router-dom';
import Popup from './Popup'


export const ActivatePage = () => {
    const { token } = useParams();
    const [showPopup, setShowPopup] = useState(false);
    const [error, setError] = useState('');
    const navigate = useNavigate();
    const [isLogged, setIsLogged] = useState('');

    const checkLoginStatus = () => {
        const logged = localStorage.getItem('loggetPQRSMART') === 'true';
        setIsLogged(logged);

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
        const verifyEmail = async () => {
            try {
                const response = await axios.get('/api/auth/verify-email', {
                    params: { token }
                });
                if (response.status === 200) {
                    setError('Correo electrónico verificado correctamente.');
                    setShowPopup(true); // Mostrar popup

                } else {
                    setError(`Error al verificar correo electrónico: ${response.data} .`);
                    setShowPopup(true); // Mostrar popup
                    return;
                }
                setTimeout(() => {
                    navigate('/')
                    
                  }, "5000");
                  
                return;

            } catch (error) {
                console.error('Error verifying email:', error);
                setError('Error al verificar correo electrónico');
                setShowPopup(true); // Mostrar popup
                return;

            }
        };

        verifyEmail();
    }, [token]);
    if (isLogged) {
        return null; //o un spinner si quieres mostrar algo mientras se redirige
    }

    const closePopup = () => {
        setShowPopup(false);
    };

    return (
        <div>
            <canvas id="gradient-canvas" style={{ width: '100vw', height: '100vh', position: 'absolute', zIndex: -1 }}></canvas>
            <div className="activate">
                <p style={{ color: 'white' }}>Verificando correo electrónico...</p>
            </div>
            {showPopup && <Popup message={error} onClose={closePopup} />}
        </div>
    );
};
export const Activate = () => {
    const { token } = useParams();
    const [showPopup, setShowPopup] = useState(false);
    const [error, setError] = useState('');
    const navigate = useNavigate();
    const [isLogged, setIsLogged] = useState('');

    const checkLoginStatus = () => {
        const logged = localStorage.getItem('loggetPQRSMART') === 'true';
        setIsLogged(logged);

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
        const verifyEmail = async () => {
            console.log(token)
            try {
                const response = await axios.put(`/api/auth/activate-email?token=${token}`);

                if (response.status === 200) {
                    setError('Correo electrónico verificado correctamente.');
                    setShowPopup(true); // Mostrar popup

                } else {
                    setError(`Error al verificar correo electrónico: ${response.data} .`);
                    setShowPopup(true); // Mostrar popup
                    return;
                }
                setTimeout(() => {
                    navigate('/')
                    
                  }, "5000");
                  
                return;

            } catch (error) {
                console.error('Error verifying email:', error);
                setError('Error al verificar correo electrónico');
                setShowPopup(true); // Mostrar popup
                return;

            }
        };

        verifyEmail();
    }, [token]);
    if (isLogged) {
        return null; //o un spinner si quieres mostrar algo mientras se redirige
    }

    const closePopup = () => {
        setShowPopup(false);
    };

    return (
        <div>
            <canvas id="gradient-canvas" style={{ width: '100vw', height: '100vh', position: 'absolute', zIndex: -1 }}></canvas>
            <div className="activate">
                <p style={{ color: 'white' }}>Verificando correo electrónico...</p>
            </div>
            {showPopup && <Popup message={error} onClose={closePopup} />}
        </div>
    );
};
