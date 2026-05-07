const express = require('express');
const router = express.Router();
const RegistroEmbarcacion = require('../models/RegistroEmbarcaciones');

// Ruta para guardar un nuevo registro desde el móvil
router.post('/registrar', async (req, res) => {
    try {
        const nuevoRegistro = await RegistroEmbarcacion.create(req.body);
        
        res.status(201).json({
            success: true,
            message: "Registro guardado exitosamente en BRISMAR",
            data: {
                id: nuevoRegistro.id,
                utilidad: nuevoRegistro.utilidadNeta // Aquí le devolvemos el cálculo al móvil
            }
        });
    } catch (error) {
        console.error("Error al registrar:", error);
        res.status(400).json({
            success: false,
            message: "No se pudo guardar el registro",
            error: error.message
        });
    }
});

module.exports = router;

// Ruta para obtener todos los registros (Historial)
router.get('/historial', async (req, res) => {
    try {
        const registros = await RegistroEmbarcacion.findAll({
            order: [['createdAt', 'DESC']] // Los más recientes primero
        });
        
        res.json({
            success: true,
            data: registros
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error al obtener el historial",
            error: error.message
        });
    }
});


//---RANGO DE GASTOS DE SEMANA----//

router.get('/estadisticas-rango', async (req, res) => {
    // Si no vienen fechas, usamos la última semana por defecto
    const fechaInicio = req.query.fechaInicio || '2026-04-28'; 
    const fechaFin = req.query.fechaFin || '2026-05-05';

    try {
        const [totales] = await sequelize.query(`
            SELECT 
                SUM(gastoFacturacion) as totalFacturacion,
                SUM(gastoPersonal) as totalPersonal,
                SUM(gastoApoyo) as totalApoyo,
                SUM(gastoAgua) as totalAgua,
                SUM(gastoClorox) as totalClorox,
                SUM(gastoFlete) as totalFlete,
                SUM(gastoHielo) as totalHielo,
                SUM(gastoOtros) as totalOtros,
                SUM(kilos * precioPorKilo) as ingresoBruto
            FROM registro_embarcaciones
            WHERE fecha BETWEEN ? AND ?
        `, { replacements: [fechaInicio, fechaFin] });

        res.json({
            success: true,
            periodo: { desde: fechaInicio, hasta: fechaFin },
            data: totales[0]
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});


//---INFORMACION DEL PDF---//
// Ruta actualizada para el PDF
router.get('/reporte-pdf', async (req, res) => {
    const { fechaInicio, fechaFin, nombreBahia } = req.query; // Daniel pasa su nombre

    try {
        const doc = new PDFDocument();
        // ... (Configuración de respuesta)

        // 1. Identidad de la Empresa
        // doc.image('ruta/al/logo_brismar.png', 50, 45, { width: 100 }); // Si tienes el archivo del logo
        doc.fontSize(20).text('NEGOCIOS BRISMAR S.R.L.', { align: 'right' });
        doc.fontSize(10).text(`Bahía Responsable: ${nombreBahia}`, { align: 'right' });
        doc.moveDown();

        // 2. Título del Reporte
        doc.fontSize(16).text('REPORTE DETALLADO DE OPERACIONES', { align: 'center', underline: true });
        doc.moveDown();

        // 3. Desglose de Gastos (Lo que viste en Figma image_f20680.png)
        doc.fontSize(12).text('--- DESGLOSE DE GASTOS DEL MUELLE ---');
        doc.text(`- Hielo: S/ ${gastoHielo}`);
        doc.text(`- Personal: S/ ${gastoPersonal}`);
        doc.text(`- Flete: S/ ${gastoFlete}`);
        doc.text(`- Agua/Clorox: S/ ${gastoAgua}`);
        doc.text(`- Otros: S/ ${gastoOtros}`);
        doc.text('-------------------------------------');
        doc.fontSize(13).text(`TOTAL GASTOS: S/ ${totalGastos}`, { bold: true });
        
        doc.moveDown();

        // 4. Resumen Financiero
        doc.fontSize(12).text(`INGRESO BRUTO (Venta): S/ ${ingresoBruto}`);
        doc.fillColor('green').text(`UTILIDAD NETA (Ganancia Real): S/ ${utilidadNeta}`);

        doc.end();
        doc.pipe(res);
    } catch (error) { /* error */ }

    module.exports = router;
});