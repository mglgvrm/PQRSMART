import React, { useEffect, useState } from 'react';
import '../Secretario/GestionarPQRS.css'
import axios from 'axios';
import Popup from '../../componentes/Popup'
import Responder from './Responder';
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { HeaderAdmin, HeaderSecre } from '../../componentes/Inicio/Header';



const GestionarPQRS = () => {
    const [currentPage, setCurrentPage] = useState(0);
    const usuariosPorPagina = 3;
    const [data, setData] = useState([]);
    const [selectedRow, setSelectedRow] = useState(null); // Cambiado para que sea null en lugar de un array
    const [filterText, setFilterText] = useState(''); // Estado para el texto de búsqueda
    const [showPopup, setShowPopup] = useState(false);
    const [error, setError] = useState('');
    const [estado, setEstado] = useState(false)

    const fetchData = async () => {
        try {
            const response = await axios.get('/api/request/get');
            console.log(response);

            const token = localStorage.getItem('token');
            const response1 = await axios.get('/api/auth/editar', {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });
            const usuario = response1.data.dependence.idDependence;
            console.log(usuario);

            if (usuario) {
                const filteredData = response.data.filter(item => item.dependence && item.dependence.idDependence === usuario);

                const alertas20Dias = [];
                const alertas30Dias = [];

                filteredData.forEach(item => {
                    const fechaCreacion = new Date(item.date);
                    const fechaActual = new Date();
                    const diferenciaTiempo = fechaActual - fechaCreacion;
                    const diasTranscurridos = Math.floor(diferenciaTiempo / (1000 * 60 * 60 * 24));

                    item.diasTranscurridos = diasTranscurridos;

                    const noRespondida = !item.answer || item.answer.trim() === '';

                    if (noRespondida) {
                        if (diasTranscurridos >= 15) {
                            alertas30Dias.push(item.idRequest);
                        } else if (diasTranscurridos >= 10) {
                            alertas20Dias.push(item.idRequest);
                        }
                    }

                    item.date = fechaCreacion.toDateString();
                });

                // Mostrar notificaciones con react-toastify
                if (alertas30Dias.length > 0) {
                    toast.error(`Peticiones vencidas (30 días): Su id ${alertas30Dias.join(', ')}`);
                }
                else if (alertas20Dias.length > 0) {
                    toast.warn(`Peticiones sin responder (20 días): Su id ${alertas20Dias.join(', ')}`);
                }

                setData(filteredData);
            } else {
                setData([]);
            }
        } catch (error) {
            console.error('Error en la data: ', error);
        }
    };

    useEffect(() => {
        document.title = "Gestion PQRS";
        fetchData();

        const intervalo = setInterval(() => {
            fetchData();
        }, 10800000); // Actualiza cada hora (3600000 ms)

        return () => clearInterval(intervalo); // Limpia el intervalo al desmontar el componente
    }, []);


    const handleRow = (pqrs) => {
        setSelectedRow(pqrs);
    };

    const handleResponderClick = async (e) => {
        e.preventDefault();
        console.log(selectedRow)
        if (selectedRow) {

            // Actualizar la solicitud de PQRS seleccionada
            const response = await axios.get('/api/request/get', selectedRow)

            setEstado(true)

        } else {
            setError('Por favor seleccione una fila')
            setShowPopup(true); // Mostrar popup
            return;
        }

    };

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

    // Filtrar datos cuando cambie el texto de búsqueda
    const filtered = data.filter(item =>
        String(item.radicado).toLowerCase().includes(filterText.toLowerCase()) ||
        String(item.category.nameCategory).toLowerCase().includes(filterText.toLowerCase()) ||
        String(item.description).toLowerCase().includes(filterText.toLowerCase()) ||
        String(item.date).toLowerCase().includes(filterText.toLowerCase()) ||
        String(item.requestType.nameRequestType).toLowerCase().includes(filterText.toLowerCase()) ||  // Convertir a string
        String(item.mediumAnswer).toLowerCase().includes(filterText.toLowerCase()) ||
        String(item.requestState.nameRequestState).toLowerCase().includes(filterText.toLowerCase())
    );
    const paginacion = filtered.slice(currentPage * usuariosPorPagina, (currentPage + 1) * usuariosPorPagina);

    const totalPaginas = Math.ceil(filtered.length / usuariosPorPagina);


    const closePopup = () => {
        setShowPopup(false);
    };
    //Responder
    const handleSavePqrs = async (updatedPqrs) => {
        console.log('envio: ', updatedPqrs);
        const formDataToSend = new FormData();
        const archivo = updatedPqrs.archivoAnswer
        if (archivo !== null) {
            formDataToSend.append('archivo', archivo);
            console.log(archivo)
        }
        formDataToSend.append('request', new Blob([JSON.stringify({
            answer: updatedPqrs.answer,
            requestState: updatedPqrs.requestState,
        })], {
            type: 'application/json'
        }));
        setError('Espere.....')
        setShowPopup(true); // Mostrar popup
        try {
            const response = await axios.put(`/api/request/update/${updatedPqrs.idRequest}`,
                formDataToSend, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });
            console.log('Response:', response.data);
            setEstado(false)
            setError('Envio Exitoso')
            setShowPopup(true); // Mostrar popup
            fetchData(); // Actualiza la tabla con los datos modificados
            return;
        } catch (error) {
            console.error('Error al actualizar el estado: ', error);
        }

    };

    const handleRechazar = async (idRequest) => {
        try {
            await axios.put(`/api/request/rechazar/${idRequest}`);
            // Actualizar la tabla después de cancelar la solicitud
            setEstado(false)
            setError('Envio Exitoso')
            setShowPopup(true); // Mostrar popup
            fetchData();
        } catch (error) {
            console.error('Error al cancelar la solicitud: ', error);
        }
    };

    return (
        <div className='GestionarPQRS'>
             <HeaderSecre/>
            <div className="cuerposgestionarpqrs">

                <div className="tabla-gestion-PQRS">
                    <h1 className="titleConsultar">GESTIONAR PQRS</h1>
                    <div className="busqueda">
                        <input type="text"
                            value={filterText}
                            onChange={(e) => setFilterText(e.target.value)} // Actualiza el estado del texto de búsqueda
                        />
                        <img src="/images/search.svg" alt="Buscar" className="icono-busqueda" />
                    </div>
                    <label className='nota' >Nota: Con La X Puede Cancelar Su Solicitud</label>
                    <table className="tabla-minimalista-usuario">
                        <thead>
                            <tr>
                                <th>Categoria</th>
                                <th>Descripcion</th>
                                <th>Fecha</th>
                                <th>Tipo de Solicitud</th>
                                <th>Medio de Respuesta</th>
                                <th>Evidencia</th>
                                <th>Estado</th>
                                <th>Respuesta</th>
                                <th>Evidencia Respuesta</th>
                            </tr>
                        </thead>
                        <tbody>
                            {paginacion.length > 0 ? (
                                paginacion.map((pqrs, index) => (
                                    <tr key={index} onClick={() => handleRow(pqrs)} className={pqrs === selectedRow ? 'fila-seleccionada' : ''}>
                                        <td>{pqrs.category.nameCategory}</td>
                                        <td>
                                            <div style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: '150px' }}>
                                                {pqrs.description.length > 50 ? `${pqrs.description.slice(0, 50)}...` : pqrs.description}
                                            </div>
                                        </td>
                                        <td>{pqrs.date}</td>
                                        <td>{pqrs.requestType.nameRequestType}</td>
                                        <td>{pqrs.mediumAnswer}</td>
                                        <td>
                                            <span>
                                                {pqrs.archivo ? (
                                                    <a href={`https://pqrsmartback-production-86b1.up.railway.app/api/request/download/${encodeURIComponent(pqrs.archivo.split('\\').pop().split('/').pop())}`} download target="_blank" rel="noopener noreferrer">
                                                        <button className='btn-descargar'>Descargar</button>
                                                    </a>
                                                ) : (
                                                    <div>
                                                        <span>No disponible</span>
                                                    </div>
                                                )
                                                }
                                            </span>

                                        </td>
                                        <td>
                                            <span className={`estado ${pqrs.requestState?.nameRequestState?.toLowerCase()}`}>
                                                {pqrs.requestState?.nameRequestState === 'Finalizado' ? '✔️' : pqrs.requestState?.nameRequestState === 'Pendiente' ? '🔎' : '❌'}

                                            </span>
                                            {pqrs.requestState?.nameRequestState}
                                        </td>
                                        <td>
                                            {/*<div style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', maxWidth: '150px' }}>
                                                {pqrs.answer && pqrs.answer.length > 50
                                                    ? `${pqrs.answer.slice(0, 50)}...`
                                                    : pqrs.answer || ''}  {/* Si row.answer es null o undefined, mostramos 'No disponible' */}
                                            {/*</div>*/}

                                            <span>
                                                {pqrs.archivoAnswer ? (
                                                    <a href={`https://pqrsmartback-production-86b1.up.railway.app/api/request/download/${encodeURIComponent(pqrs.archivoAnswer.split('\\').pop().split('/').pop())}`} download target="_blank" rel="noopener noreferrer">
                                                        <button className='btn-descargar'>Descargar</button>
                                                    </a>
                                                ) : (
                                                    <div>
                                                        <span>No disponible</span>
                                                    </div>
                                                )
                                                }
                                            </span>
                                        </td>
                                        <td>
                                            <span>
                                                {pqrs.evidenceAnswer ? (
                                                    <a href={`https://pqrsmartback-production-86b1.up.railway.app/api/request/download/${encodeURIComponent(pqrs.evidenceAnswer.split('\\').pop().split('/').pop())}`} download target="_blank" rel="noopener noreferrer">
                                                        <button className='btn-descargar'>Descargar</button>
                                                    </a>
                                                ) : (
                                                    <div>
                                                        <span>No disponible</span>
                                                    </div>
                                                )
                                                }
                                            </span>

                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan="6" style={{ textAlign: 'center' }}>No hay datos disponibles</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                    <div className="paginacion">
                        <button onClick={() => setCurrentPage(prev => Math.max(prev - 1, 0))} disabled={currentPage === 0}>
                            Anterior
                        </button>
                        <span>{currentPage + 1} de {totalPaginas}</span>
                        <button onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPaginas - 1))} disabled={currentPage >= totalPaginas - 1}>
                            Siguiente
                        </button>
                    </div>
                    <div className="Btngestionarpqrs" >
                        <button disabled={selectedRow == null} onClick={handleResponderClick}>Responder</button>
                    </div>
                </div>
                {estado && (
                    <Responder
                        pqrs={selectedRow}
                        onSave={handleSavePqrs}
                        isOpen={estado}
                        onClose={() => setEstado(false) + setSelectedRow('')}
                        onRechazar={handleRechazar}


                    />
                )}
            </div>
            {showPopup && <Popup message={error} onClose={closePopup} />}
            <ToastContainer

            />
        </div>
    );
}

export default GestionarPQRS;
