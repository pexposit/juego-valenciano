/** @type {import('tailwindcss').Config} */
// Paleta de l'avatar robot (veure assets-src/robot-avatar): Plastic_Blanc, Pantalla,
// Ull_Brillant, Galta, Groc/Roig/Blau_Senyera, Metall, Llum_Antena.
export default { content: ['./index.html','./src/**/*.{ts,tsx}'], theme: { extend: { colors: { cream:'#F5F2EA', ink:'#1A2140', orange:'#FF3B3B', coral:'#FF7FA8', teal:'#0F47AF', mustard:'#FCDD09', navy:'#1A2140', cyan:'#4FE3FF', metal:'#9AA3B5', senyeraRed:'#DA121A' }, fontFamily:{sans:['Nunito','ui-sans-serif','system-ui']} } }, plugins: [] };
