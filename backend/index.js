require('dotenv').config();
const express = require('express');
const cors = require('cors'); // 1. IMPORTAMOS CORS

// VERIFICA ESTAS DOS RUTAS:
const sequelize = require('./src/config/database'); 
const Registro = require('./src/models/RegistroEmbarcaciones'); 
const embarcacionesRoutes = require('./src/routes/embarcaciones'); 
const Usuario = require('./src/models/Usuario');

const app = express();

// 2. ACTIVAMOS CORS PARA QUE FLUTTER (CHROME) PUEDA ENTRAR
app.use(cors());
app.use(express.json());

// --- RUTAS ---

// Rutas externas (PDF, historial, estadísticas)
app.use('/api/embarcaciones', embarcacionesRoutes);

// Ruta para guardar registros 
app.post('/api/nuevo-registro', async (req, res) => {
    try {
        const nuevo = await Registro.create(req.body);
        res.status(201).json({ mensaje: "Registro guardado en BRISMAR", data: nuevo });
    } catch (error) {
        res.status(400).json({ error: "Error al registrar embarcación" });
    }
});

// 3. ¡LA RUTA DEL LOGIN!
app.post('/api/usuarios/login', async (req, res) => {
    const { usuario, password } = req.body;
    
    // Cambiamos 'admin' por 'usuario'
    if (usuario === 'usuario' && password === '1234') {
        res.status(200).json({
            ok: true,
            datos: { nombre: 'Daniel' } // <-- El nombre que saldrá como Usuario Activo
        });
    } else {
        res.status(401).json({
            ok: false,
            mensaje: 'Usuario o contraseña incorrectos'
        });
    }
});

// --- CONEXIÓN A BASE DE DATOS Y ARRANQUE ---
const PORT = process.env.PORT || 8080;

sequelize.authenticate()
    .then(() => {
        console.log('Conexión exitosa a la base de datos de BRISMAR');
        app.listen(PORT, () => {
            console.log(`Servidor de BRISMAR corriendo en http://localhost:${PORT}`);
        });
    })
    .catch(err => {
        console.error('Error al conectar a la base de datos:', err);
    });