import React, { useEffect, useState } from 'react';
import '../Menus/Registro.css'
import axios from 'axios';
import Popup from '../componentes/Popup'
import { useNavigate } from 'react-router-dom';
import { FaEye, FaEyeSlash } from 'react-icons/fa';

const Registro = () => {
    const [passwordError, setPasswordError] = useState('');
    const [confirmPasswordError, setConfirmPasswordError] = useState('');
    const [identificationTypes, setIdentificationTypes] = useState([]);
    const [personTypes, setPersonTypes] = useState([]);
    const [showPopup, setShowPopup] = useState(false);
    const [passwordVisible, setPasswordVisible] = useState(false);
    const [confirmPasswordVisible, setConfirmPasswordVisible] = useState(false);
    const [error, setError] = useState('');
    const [isLogged, setIsLogged] = useState('');
    const navigate = useNavigate();
    const [formData, setFormData] = useState({
        nombre: '',
        apellido: '',
        correo: '',
        numero: '',
        usuario: '',
        contraseña: '',
        confirmarContraseña: '',
        tipoIdentificacion: '',
        identificacion: '',
        tipoPersona: '',
        dependencia: 7,
    });
    const togglePasswordVisibility = () => {
        setPasswordVisible(!passwordVisible);
    };
    const confirmTogglePasswordVisibility = () => {
        setConfirmPasswordVisible(!confirmPasswordVisible);
    };
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
        document.title = "Registro"
        checkLoginStatus();
        const fetchIdentificationTypes = async () => {
            try {
                const response = await axios.get('/api/identification_type/get');
                console.log('Tipos de identificación obtenidos:', response.data);
                setIdentificationTypes(response.data);
            } catch (error) {
                console.error('Error al obtener tipos de identificación de la base de datos', error);
            }
        };

        const fetchPersonTypes = async () => {
            try {
                const response = await axios.get('/api/person_type/get');
                console.log('Tipos de persona obtenidos:', response.data);
                setPersonTypes(response.data);
            } catch (error) {
                console.error('Error al obtener tipos de persona de la base de datos', error);
            }
        };

        fetchIdentificationTypes();
        fetchPersonTypes();
    }, []);

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

    const validatePassword = (password) => {
        const minLength = password.length >= 8;
        const hasUpperCase = /[A-Z]/.test(password);
        const hasLowerrCase = /[a-z]/.test(password);
        const hasNumber = /\d/.test(password);
        const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>/?]/.test(password);

        return minLength && hasUpperCase && hasNumber && hasSpecialChar && hasLowerrCase;
    };

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    const handleReset = () => {
        setFormData({
            nombre: '',
            apellido: '',
            correo: '',
            numero: '',
            usuario: '',
            contraseña: '',
            confirmarContraseña: '',
            tipoIdentificacion: '',
            identificacion: '',
            tipoPersona: '',
        });
    }

    const handleSubmit = async (e) => {
        e.preventDefault();

        setConfirmPasswordError('')
        setPasswordError('')
        const isValidPassword = validatePassword(formData.contraseña);
        if (!isValidPassword) {
            setPasswordError('La contraseña debe tener mínimo 8 caracteres, al menos un número, un signo y una letra mayúscula.');
            return;
        } else {
            setPasswordError('Contraseña valida');
        }

        if (formData.contraseña !== formData.confirmarContraseña) {
            setConfirmPasswordError('Las contraseñas no coinciden');
            return;
        } else {
            setConfirmPasswordError('Contraseña valida');
        }


        try {
            console.log('Datos del formulario a enviar:', formData);

            const selectedIdentificationType = identificationTypes.find(type => type.idIdentificationType === parseInt(formData.tipoIdentificacion));
            const selectedPersonType = personTypes.find(type => type.idPersonType === parseInt(formData.tipoPersona));
            if (formData.contraseña === formData.confirmarContraseña) {
                setError('Espere.......')
                setShowPopup(true); // Mostrar popup
                const userResponse = await axios.post('/api/auth/registerUser', {
                    personType: { idPersonType: selectedPersonType.idPersonType },
                    name: formData.nombre,
                    lastName: formData.apellido,
                    email: formData.correo,
                    identificationType: { idIdentificationType: selectedIdentificationType.idIdentificationType }, // Enviar el objeto completo
                    identificationNumber: parseInt(formData.identificacion),
                    user: formData.usuario,
                    password: formData.contraseña,
                    dependence: { idDependence: formData.dependencia },
                    number: parseInt(formData.numero)
                });

                console.log('Respuesta al guardar usuario:', userResponse.data);
                console.log('Usuario registrado correctamente');
                setConfirmPasswordError('')
                setPasswordError('')
                handleReset();
                setError('Se ha enviado un mensaje de verificacion a su correo, si no le aparece verifique la carpeta de spam.')
                setShowPopup(true); // Mostrar popup
                return;

            }

        } catch (error) {
            const status = error.response.data;
            console.log(status)
            // Manejo de errores
            if (status === 'El correo electrónico ya está en uso.') {
                setError('El correo electrónico ya está en uso.');
            } else if (status === 'El usuario ya existe.') {
                setError("El usuario ya existe.");
            } else if (status === 'El número de identificación ya está registrado.') {
                setError("El número de identificación ya está registrado.");
            } else if (status === 'El número ya está registrado.') {
                setError("El número ya está registrado.");
            }
            else {
                setError("Error en el servidor. Intente nuevamente más tarde.");
            }
            setShowPopup(true); // Mostrar popup
            return;
        }

    };
    const closePopup = () => {
        setShowPopup(false);
    };
    if (isLogged) {
        return null; // o un spinner si quieres mostrar algo mientras se redirige
    }
    return (
        <div className='RegistroUser'>
            <canvas id="gradient-canvas" style={{ width: '100vw', height: '100vh', position: 'absolute', zIndex: -1 }}></canvas>
            <div className="FormularioRegistro">
                <form className='forms' onSubmit={handleSubmit}>
                    <div className="tituloRegistro">
                        <h1>Registrate</h1>
                    </div>
                    <div className="Campos">
                        <div className="labelsAndInputs">
                            <label >Tipo De Persona</label>
                            <select className='Selects'
                                id="tipoPersona"
                                name="tipoPersona"
                                value={formData.tipoPersona}
                                onChange={handleChange} required
                            >
                                <option key="" value="">Seleccione el tipo</option>
                                {personTypes.map((type) => (
                                    <option key={type.idPersonType} value={type.idPersonType}>
                                        {type.namePersonType}
                                    </option>
                                ))}
                            </select>
                        </div>
                        <div className="labelsAndInputs">
                            <label >Tipo De Identificacion</label>
                            <select className='Selects'
                                id="tipoIdentificacion"
                                name="tipoIdentificacion"
                                value={formData.tipoIdentificacion}
                                onChange={handleChange} required
                            >
                                <option key="" value="">Seleccione Tipo de Identificación</option>
                                {identificationTypes.map((type) => (
                                    <option key={type.idIdentificationType} value={type.idIdentificationType}>
                                        {type.nameIdentificationType}
                                    </option>
                                ))}
                            </select>
                        </div>
                        <div className="labelsAndInputs">
                            <label >Numero De Identificacion</label>
                            <input className='inputs'
                                type="text"
                                id="identificacion"
                                name="identificacion"
                                value={formData.identificacion}
                                pattern="\d*"  // Acepta solo números
                                maxLength={10}  // Limita a 10 dígitos
                                onChange={(e) => {
                                    if (/^\d*$/.test(e.target.value)) { // Solo permite números
                                        setFormData({ ...formData, identificacion: e.target.value });
                                    }
                                }} required />
                        </div>
                        <div className="labelsAndInputs">
                            <label >Nombres Completos</label>
                            <input className='inputs'
                                type="text"
                                id="nombre"
                                name="nombre"
                                value={formData.nombre}
                                onChange={handleChange} required />
                        </div>
                        <div className="labelsAndInputs">
                            <label >Apellidos Completos</label>
                            <input className='inputs'
                                type="text"
                                id="apellido"
                                name="apellido"
                                value={formData.apellido}
                                onChange={handleChange} required />
                        </div>
                        <div className="labelsAndInputs">
                            <label >Correo Electronico</label>
                            <input className='inputs'
                                type="email"
                                id="correo"
                                name="correo"
                                value={formData.correo}
                                onChange={handleChange} required />
                        </div>
                        <div className="labelsAndInputs">
                            <label >Telefono</label>
                            <input className='inputs'
                                type="text"
                                id="numero"
                                name="numero"
                                value={formData.numero}
                                pattern="\d*"  // Acepta solo números
                                maxLength={10}  // Limita a 10 dígitos
                                onChange={(e) => {
                                    if (/^\d*$/.test(e.target.value)) {
                                        setFormData({ ...formData, numero: e.target.value });
                                    }
                                }} required />
                        </div>
                        <div className="labelsAndInputs">
                            <label >Usuario</label>
                            <input className='inputs'
                                type="text"
                                id="usuario"
                                name="usuario"
                                value={formData.usuario}
                                onChange={handleChange} required />
                        </div>
                        <div className="labelsAndInputs">
                            <label >Contraseña</label>
                            <div className="passwordRegistro">
                                <input className='inputs'
                                    type={passwordVisible ? 'text' : 'password'}
                                    id="contraseña"
                                    name="contraseña"
                                    value={formData.contraseña}
                                    onChange={handleChange} required
                                />
                                <span
                                    onClick={togglePasswordVisibility}
                                >
                                    {passwordVisible ? <FaEye /> : <FaEyeSlash />}
                                </span>
                            </div>
                            {passwordError && <div className='errore'> {passwordError}</div>}
                        </div>
                        <div className="labelsAndInputs">
                            <label >Confirmar Contraseña</label>
                            <div className="passwordRegistro">
                                <input className='inputs'
                                    type={confirmPasswordVisible ? 'text' : 'password'}
                                    id="confirmarContraseña"
                                    name="confirmarContraseña"
                                    value={formData.confirmarContraseña}
                                    onChange={handleChange} required
                                />
                                <span
                                    onClick={confirmTogglePasswordVisibility}
                                >
                                    {confirmPasswordVisible ? <FaEye /> : <FaEyeSlash />}
                                </span>
                            </div>
                            {confirmPasswordError && <div className='errores'> {confirmPasswordError}</div>}
                        </div>
                        <div className="ButonR">
                            <button type="submit">Registrate</button>
                        </div>
                        <div className="labelAndA">
                            <label >Ya Tienes Cuenta?</label>
                            <a className='A' href="/Login">Iniciar Sesion</a>
                        </div>
                    </div>

                </form>

            </div>
            {showPopup && <Popup message={error} onClose={closePopup} />}
        </div>
    );
}

export default Registro;
