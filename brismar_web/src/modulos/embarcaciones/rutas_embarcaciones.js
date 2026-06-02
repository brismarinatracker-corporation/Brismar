const express = require('express');
const router = express.Router();
const controladorEmbarcaciones = require('./controlador_embarcaciones');

// Registro de operaciones
router.post('/registrar', controladorEmbarcaciones.registrar);
router.post('/nuevo-registro', controladorEmbarcaciones.registrar); // Fallback compatibilidad

// Consultas e informes
router.get('/historial', controladorEmbarcaciones.historial);
router.get('/estadisticas-rango', controladorEmbarcaciones.estadisticasRango);
router.get('/reporte-pdf', controladorEmbarcaciones.reportePdf);

module.exports = router;
