import React, { useEffect, useState } from 'react';
import '../Admin/Dashboard.css';
import axios from 'axios';
import { Bar, Line } from 'react-chartjs-2';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    BarElement,
    LineElement,
    PointElement,
    Title,
    Tooltip,
    Legend,
    Filler,
} from 'chart.js';
import { HeaderAdmin } from '../../componentes/Inicio/Header';

// Registrar las escalas y componentes necesarios para los gráficos
ChartJS.register(CategoryScale, LinearScale, BarElement, LineElement, Title, Tooltip, Legend, Filler, PointElement);

const Dashboard = () => {
    const [pqrsData, setPqrsData] = useState([]);
    const [totalPQRS, setTotalPQRS] = useState(0);
    const [totalPQRSPorDependencia, setTotalPQRSPorDependencia] = useState({});
    const [totalPQRSmes, setTotalPQRSmes] = useState({});
    const [totalPQRSDepMes, setTotalPQRSDepMes] = useState({});

    useEffect(() => {
        const fetchData = async () => {
            try {
                const response = await axios.get('/api/request/get');
                const data = response.data;
                setPqrsData(data);
                calcularTotales(data);
            } catch (error) {
                console.error('Error fetching PQRS data:', error);
            }
        };

        fetchData();
    }, []);

    const calcularTotales = (data) => {
        setTotalPQRS(data.length);

        // Total PQRS por Dependencia
        const dependenciaCount = data.reduce((acc, pqrs) => {
            const dependencia = pqrs.dependence?.nameDependence || 'Sin Dependencia';
            acc[dependencia] = (acc[dependencia] || 0) + 1;
            return acc;
        }, {});
        setTotalPQRSPorDependencia(dependenciaCount);

        // Total PQRS por Mes
        const pqrsPorMes = data.reduce((acc, pqrs) => {
            const mes = new Date(pqrs.date).toLocaleString('default', { month: 'long', year: 'numeric' });
            acc[mes] = (acc[mes] || 0) + 1;
            return acc;
        }, {});
        setTotalPQRSmes(pqrsPorMes);

        // Total PQRS por Dependencia al Mes
        const pqrsPorDepMes = data.reduce((acc, pqrs) => {
            const mes = new Date(pqrs.date).toLocaleString('default', { month: 'long', year: 'numeric' });
            const dependencia = pqrs.dependence?.nameDependence || 'Sin Dependencia';
            const key = `${dependencia} - ${mes}`;
            acc[key] = (acc[key] || 0) + 1;
            return acc;
        }, {});
        setTotalPQRSDepMes(pqrsPorDepMes);
    };

    const dataChart = {
        labels: Object.keys(totalPQRSmes),
        datasets: [
            {
                label: 'Total PQRS por Mes',
                data: Object.values(totalPQRSmes),
                backgroundColor: 'rgba(75, 192, 192, 0.6)',
                borderColor: 'rgba(75, 192, 192, 1)',
                borderWidth: 1,
            },
        ],
    };

    const dataChartDependencia = {
        labels: Object.keys(totalPQRSPorDependencia),
        datasets: [
            {
                label: 'Total PQRS por Dependencia',
                data: Object.values(totalPQRSPorDependencia),
                backgroundColor: 'rgba(153, 102, 255, 0.6)',
                borderColor: 'rgba(153, 102, 255, 1)',
                borderWidth: 1,
            },
        ],
    };

    // Datos para el gráfico de tendencia
    const lineChartData = {
        labels: Object.keys(totalPQRSmes),
        datasets: [
            {
                label: 'Tendencia de PQRS',
                data: Object.values(totalPQRSmes),
                fill: true,
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                borderColor: 'rgba(75, 192, 192, 1)',
                tension: 0.1,
            },
        ],
    };

    return (
        <div className='Dashboard'>
            <HeaderAdmin />
            <div className="cuerpos-Dashboard">
                <div className="dashform">
                    <h1 className="titledash">DASHBOARD</h1>
                    <div className="total">
                        <div className="formdash">
                            <div className="totalprs card">
                                <h2><i className="fas fa-tasks"></i> Total PQRS</h2>
                                {totalPQRS && <div className='pqrstotal'><p>{totalPQRS}</p></div>}
                            </div>
                            {Object.keys(totalPQRSPorDependencia).length > 0 && (
                                <div className="totalpqrsdepe card">
                                    <h2><i className="fas fa-building"></i> Total PQRS por Dependencia:</h2>
                                    <Bar data={dataChartDependencia} options={{ responsive: true }} />
                                </div>
                            )}
                            {Object.keys(totalPQRSmes).length > 0 && (
                                <div className="totalpqrsmes card">
                                    <h2><i className="fas fa-calendar-alt"></i> PQRS Por Mes:</h2>
                                    <Bar data={dataChart} options={{ responsive: true }} />
                                </div>
                            )}
                            {Object.keys(totalPQRSDepMes).length > 0 && (
                                <div className="totalpqrsdepemes card">
                                    <h2><i className="fas fa-chart-bar"></i> PQRS Por Dependencia al Mes:</h2>
                                    {Object.entries(totalPQRSDepMes).map(([key, count]) => (
                                        <div className='pqrstotalpqrsdepemes' key={key}>
                                            <p>{key}: {count}</p>
                                        </div>
                                    ))}
                                </div>
                            )}
                            {/* Agregar el gráfico de tendencia aquí */}
                            {Object.keys(totalPQRSmes).length > 0 && (
                                <div className="tendenciaPQRS card">
                                    <h2><i className="fas fa-trending-up"></i> Tendencia de PQRS:</h2>
                                    <Line data={lineChartData} options={{ responsive: true }} />
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
