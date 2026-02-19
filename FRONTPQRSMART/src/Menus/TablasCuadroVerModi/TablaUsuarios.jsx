import React, { useEffect, useState } from 'react';
import './TablaUsuarios.css';
import axios from 'axios';

const TablaUsuarios = () => {
    const [data, setData] = useState([]);
    const token = localStorage.getItem('token');
    useEffect(() => {
        document.title = "Gestionar Usuarios";
        fetchData();
    }, []);
    const fetchData = async () => {
        try {
            const response = await axios.get('/api/Usuario/get', {
                'Authorization': `Bearer ${token}`
            });
            setData(response.data);
            console.log(response.data)
        } catch (error) {
            console.error('Error en la data: ', error);
        }
    };
    const handleCancel = async (id) => {
        try {
            await axios.patch(`/api/Usuario/cancel/${id}`);
            fetchData();
            
        } catch (error) {
            console.error('Error al desactivar el usuario: ', error);
            
        }
    };
    const handleActivate = async (id) => {
        try {
            await axios.patch(`/api/Usuario/activate/${id}`);
            fetchData();
            
        } catch (error) {
            console.error('Error al desactivar el usuario: ', error);
            
        }
    };


    const [searchTerm, setSearchTerm] = useState('');
    const [currentPage, setCurrentPage] = useState(0);
    const usuariosPorPagina = 6; // Cambia esto para ajustar cuántos usuarios mostrar por página

    // Filtra los usuarios de acuerdo al término de búsqueda
    const usuariosFiltrados = data.filter(user =>
        Object.values(user).some(val =>
            val && val.toString().toLowerCase().includes(searchTerm.toLowerCase()) // Comprobación de que 'val' no sea null o undefined
        )
    );


    const paginacion = usuariosFiltrados.slice(currentPage * usuariosPorPagina, (currentPage + 1) * usuariosPorPagina);

    const totalPaginas = Math.ceil(usuariosFiltrados.length / usuariosPorPagina);

    return (
        <div className="tabla-container">
            <h2>Lista de Usuarios</h2>

            <div className="buscador-container">
                <input
                    type="text"
                    placeholder="Buscar en la tabla..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="buscador"
                />
                <img src="src/images/search.svg" alt="Buscar" className="icono-busqueda" />
            </div>

            <table className="tabla-minimalista">
                <thead>
                    <tr>
                        <th onClick={() => ordenarPor('usuario')}>Usuario</th>
                        <th onClick={() => ordenarPor('nombre')}>Nombre</th>
                        <th onClick={() => ordenarPor('apellido')}>Apellido</th>
                        <th onClick={() => ordenarPor('identificacion')}>Identificación</th>
                        <th onClick={() => ordenarPor('rol')}>Rol</th>
                        <th onClick={() => ordenarPor('estado.state')}>Estado</th>
                        <th onClick={() => ordenarPor('accion')}>Accion</th>
                    </tr>
                </thead>
                <tbody>
                    {paginacion.length > 0 ? (
                        paginacion.map((user, index) => (
                            <tr key={index}>
                                <td>{user.user}</td>
                                <td>{user.name}</td>
                                <td>{user.lastName}</td>
                                <td>{user.identificationNumber}</td>
                                <td>{user.role}</td>
                                <td>
                                    <span className={`estado ${user.stateUser?.state?.toLowerCase()}`}>
                                        {user.stateUser?.state === 'ACTIVO' ? '✔️' : '❌'}
                                    </span>
                                    {user.stateUser?.state}
                                </td>
                                <td>
                                    <span className='activar' onClick={() => handleActivate(user.id)}>
                                        {'✔️'}
                                    </span>
                                    <span onClick={() => handleCancel(user.id)}>
                                        {'❌'}
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
        </div>
    );
};

const ordenarPor = (campo) => {
    // Lógica de ordenamiento (puedes implementarlo según tus necesidades)
};

export default TablaUsuarios;
