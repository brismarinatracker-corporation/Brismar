const express = require('express');
const cors = require('cors');
const rutasUsuario = require('./src/modulos/usuarios/rutas_usuario');
const rutasEmbarcaciones = require('./src/modulos/embarcaciones/rutas_embarcaciones');

const app = express();

// Middlewares globales
app.use(cors());
app.use(express.json());

// Registro de rutas
app.use('/api/usuarios', rutasUsuario);
app.use('/api/embarcaciones', rutasEmbarcaciones);

// Middleware global de manejo de errores
app.use((err, req, res, next) => {
  console.error('Error no controlado:', err.stack);
  res.status(500).json({
    exito: false,
    mensaje: 'Ha ocurrido un error interno en el servidor.',
    error: err.message
  });
});

module.exports = app;
