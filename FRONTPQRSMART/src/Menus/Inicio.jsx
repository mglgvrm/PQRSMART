import React, { useEffect } from 'react';
import './Inicio.css'
import { useNavigate } from 'react-router-dom';
import {Header} from '../componentes/Inicio/Header';
import Intro from '../componentes/Inicio/Intro';
import Steps from '../componentes/Inicio/Steps';
import Footer from '../componentes/Inicio/Footer';
import Banner from '../componentes/Inicio/Banner';

const Inicio = () => {
    const navigate = useNavigate();
    useEffect(() => {
        document.title = "Inicio"
        checkLoginStatus();
    }, []);
    const checkLoginStatus = () => {
        const logged = localStorage.getItem('loggetPQRSMART') === 'true';
        
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
    return (
        <div className='inicio'>
            <Header />
            <Banner />
            <Intro />
            <Steps />
            <Footer />
        </div>
    );
}

export default Inicio;
