import React, { useEffect, useState } from 'react';
import Popup from '../Popup'
import axios from 'axios';
import './EditarPerfil.css'
import CambiarCorreo from '../../Menus/TablasCuadroVerModi/CambiarCorreo';
import { HeaderAdmin, HeaderSecre, HeaderUser } from '../Inicio/Header';

export const EditarPerfil = () => {
    const [show, setShow] = useState(false);
    const [showPopup, setShowPopup] = useState(false);
    const [selectedUser, setSelectedUser] = useState(null); // Estado para el usuario seleccionado
    const [error, setError] = useState('');
    const [user, setUser] = useState({
        id: '',
        user: '',
        name: '',
        lastName: '',
        email: '',
        identificationType: { idIdentificationType: '', nameIdentificationType: '' },
        identificationNumber: '',
        personType: { idPersonType: '', namePersonType: '' },
        dependence: { idDependence: '', nameDependence: '' }
    });

    const fetchUserAndOptions = async () => {
        try {
            const token = localStorage.getItem('tokenPQRSMART');
            const headers = { 'Authorization': `Bearer ${token}` };

            // Fetch user data
            const userResponse = await axios.get('/api/auth/editar', { headers });
            setUser(userResponse.data);
            console.log(user)

        } catch (error) {
            console.error('Error fetching user data or options', error);
        }
    };
    useEffect(() => {


        fetchUserAndOptions();
    }, []);


    const handleChange = (e) => {
        const { name, value } = e.target;
        setUser(prevState => ({
            ...prevState,
            [name]: value
        }));
    };
    const handleSaveUser = async (updatedUser) => {
        // Aquí puedes hacer la lógica para guardar el usuario

        const update = updatedUser;
        const id = update.id;
        const email = update.email

        try {
            await axios.put('/api/Usuario/Update-correo', { email, id });
            fetchUserAndOptions();
            setShowPopup(false)
            console.log('Usuario guardado:', id, email);
            setError('Usuario guardado, para que el cambio quede efectuado debe verificar el correo.');
            setShow(true);
            fetchUserAndOptions(); // Actualiza la tabla con los datos modificados
        } catch (error) {
            if (error.status === 409) {
                console.error('El correo electrónico ya está en uso. ', error);
                setError('El correo electrónico ya está en uso.');
                setShow(true);
            }
            else {
                console.error('Error al guardar el usuario: ', error);
                setError('Error al guardar el usuario');
                setShow(true);
            }

        }


    };
    const renderHeader = () => {
        if (user.role === 'ADMIN') {
            return <HeaderAdmin />;
        } else if (user.role === 'SECRE') {
            return <HeaderSecre />;
        } else {
           return <HeaderUser />
            
        }
    };


    const handleEditUser = (user) => {
        setSelectedUser(user); // Establece el usuario seleccionado
        console.log(user)
        setShowPopup(true);    // Abre el popup
    };
    const closePopup = () => {
        setShow(false);
    };
    return (
        <div className='EditarPerfil'>

            {renderHeader()}

            <div className="cuerpo-editar">
                <div className="form-editar">
                    <form className="solicitud-form-editar" >
                        <h1 className="title-editar">PERFIL</h1>
                        <div className="input-box-editar">
                            <label>Usuario:</label>
                            <input type="text" name="user" value={user.user} onChange={handleChange} disabled />
                        </div>
                        <div className="input-box-editar">
                            <label>Nombre:</label>
                            <input type="text" disabled name="name" value={user.name} onChange={handleChange} />
                        </div>
                        <div className="input-box-editar">
                            <label>Apellido:</label>
                            <input type="text" disabled name="lastName" value={user.lastName} onChange={handleChange} />
                        </div>
                        <div className="input-box-editar">
                            <label>Correo:</label>
                            <div className="input-box-editar-A">
                                <input type="email" disabled name="email" value={user.email} onChange={handleChange} />
                                <a onClick={() => handleEditUser(user)}>Editar</a>
                            </div>

                        </div>
                        <div className="input-box-editar">
                            <label>Tipo de Persona:</label>
                            <input type="text" disabled name="personType" value={user.personType?.namePersonType} onChange={handleChange} />
                        </div>
                        <div className="input-box-editar">
                            <label>Tipo de Identificacion:</label>
                            <input type="text" disabled name="identificationType" value={user.identificationType?.nameIdentificationType} onChange={handleChange} />
                        </div>
                        <div className="input-box-editar">
                            <label>Numero de Identificacion:</label>
                            <input type="text" disabled name="identificationNumber" value={user.identificationNumber} onChange={handleChange} />
                        </div>

                    </form>
                </div>
            </div>
            {showPopup && (
                <CambiarCorreo
                    isOpen={showPopup}
                    onClose={() => setShowPopup(false)}
                    usuario={selectedUser}
                    onSave={handleSaveUser}
                />
            )}
            {show && <Popup message={error} onClose={closePopup} />}

        </div>
    );
}


