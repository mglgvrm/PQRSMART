// GradientBackground.jsx
import React, { useEffect } from 'react';
import $ from 'jquery'; // Asegúrate de importar jQuery
import './GradientBackground.css'; // Importa el CSS específico para el fondo

const GradientBackground = () => {
    useEffect(() => {
        const colors = [
            [3, 7, 43],
            [5, 10, 49],
            [0, 199, 255],
            [0, 120, 215],
            [243, 246, 250],
            [51, 51, 51]
        ];
        let step = 0;
        const colorIndices = [0, 1, 2, 3];
        const gradientSpeed = 0.002;

        const updateGradient = () => {
            if (typeof $ === 'undefined') {
                console.error('jQuery no está disponible');
                return; // Sale de la función si jQuery no está definido
            }

            const c0_0 = colors[colorIndices[0]];
            const c0_1 = colors[colorIndices[1]];
            const c1_0 = colors[colorIndices[2]];
            const c1_1 = colors[colorIndices[3]];

            const istep = 1 - step;
            const r1 = Math.round(istep * c0_0[0] + step * c0_1[0]);
            const g1 = Math.round(istep * c0_0[1] + step * c0_1[1]);
            const b1 = Math.round(istep * c0_0[2] + step * c0_1[2]);
            const color1 = `rgb(${r1},${g1},${b1})`;

            const r2 = Math.round(istep * c1_0[0] + step * c1_1[0]);
            const g2 = Math.round(istep * c1_0[1] + step * c1_1[1]);
            const b2 = Math.round(istep * c1_0[2] + step * c1_1[2]);
            const color2 = `rgb(${r2},${g2},${b2})`;

            $('#gradient').css({
                background: `-webkit-gradient(linear, left top, right top, from(${color1}), to(${color2}))`
            }).css({
                background: `-moz-linear-gradient(left, ${color1} 0%, ${color2} 100%)`
            });

            step += gradientSpeed;
            if (step >= 1) {
                step %= 1;
                colorIndices[0] = colorIndices[1];
                colorIndices[2] = colorIndices[3];

                colorIndices[1] = (colorIndices[1] + Math.floor(1 + Math.random() * (colors.length - 1))) % colors.length;
                colorIndices[3] = (colorIndices[3] + Math.floor(1 + Math.random() * (colors.length - 1))) % colors.length;
            }
        };

        const interval = setInterval(updateGradient, 10);

        return () => clearInterval(interval); // Limpiar el intervalo al desmontar el componente
    }, []);

    return <div id="gradient" />;
};

export default GradientBackground;
