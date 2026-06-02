const express = require('express');
const router = express.Router();
const controladorUsuario = require('./controlador_usuario');

// Endpoint para el inicio de sesión
router.post('/login', controladorUsuario.iniciarSesion);

module.exports = router;
