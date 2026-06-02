const RegistroEmbarcacion = require('./modelo_embarcacion');
const sequelize = require('../../config/database');
const servicioPdf = require('./servicio_pdf');

/**
 * Registra una nueva operación de embarcación.
 * 
 * @param {object} req - Solicitud Express.
 * @param {object} res - Respuesta Express.
 * @returns {Promise<object>} JSON con el id y la utilidad calculada.
 */
async function registrar(req, res) {
  try {
    const nuevo = await RegistroEmbarcacion.create(req.body);
    return res.status(201).json({
      exito: true,
      mensaje: "Registro guardado exitosamente en BRISMAR",
      data: { id: nuevo.id, utilidad: nuevo.utilidadNeta }
    });
  } catch (error) {
    return res.status(400).json({ exito: false, mensaje: "No se pudo guardar el registro", error: error.message });
  }
}

/**
 * Obtiene el historial completo de registros de embarcaciones.
 * 
 * @param {object} req - Solicitud Express.
 * @param {object} res - Respuesta Express.
 * @returns {Promise<object>} JSON con la lista de registros.
 */
async function historial(req, res) {
  try {
    const registros = await RegistroEmbarcacion.findAll({ order: [['createdAt', 'DESC']] });
    return res.json({ exito: true, data: registros });
  } catch (error) {
    return res.status(500).json({ exito: false, mensaje: "Error al obtener el historial", error: error.message });
  }
}

/**
 * Obtiene las estadísticas acumuladas en un rango de fechas.
 * 
 * @param {object} req - Solicitud Express.
 * @param {object} res - Respuesta Express.
 * @returns {Promise<object>} JSON con los totales financieros.
 */
async function estadisticasRango(req, res) {
  const { fechaInicio = '2026-04-28', fechaFin = '2026-05-05' } = req.query;
  try {
    const query = `
      SELECT SUM(gastoFacturacion) as totalFacturacion, SUM(gastoPersonal) as totalPersonal,
             SUM(gastoApoyo) as totalApoyo, SUM(gastoAgua) as totalAgua,
             SUM(gastoClorox) as totalClorox, SUM(gastoFlete) as totalFlete,
             SUM(gastoHielo) as totalHielo, SUM(gastoOtros) as totalOtros,
             SUM(kilos * precioPorKilo) as ingresoBruto
      FROM registro_embarcaciones WHERE fecha BETWEEN ? AND ?
    `;
    const [totales] = await sequelize.query(query, { replacements: [fechaInicio, fechaFin] });
    return res.json({ exito: true, periodo: { desde: fechaInicio, hasta: fechaFin }, data: totales[0] });
  } catch (error) {
    return res.status(500).json({ exito: false, error: error.message });
  }
}

/**
 * Genera y transmite el reporte detallado en formato PDF.
 * 
 * @param {object} req - Solicitud Express.
 * @param {object} res - Respuesta Express.
 */
async function reportePdf(req, res) {
  const { fechaInicio = '2026-04-28', fechaFin = '2026-05-05', nombreBahia = 'Bahía' } = req.query;
  try {
    const query = `
      SELECT SUM(gastoFacturacion) as gastoFacturacion, SUM(gastoPersonal) as gastoPersonal,
             SUM(gastoApoyo) as gastoApoyo, SUM(gastoAgua) as gastoAgua,
             SUM(gastoClorox) as gastoClorox, SUM(gastoFlete) as gastoFlete,
             SUM(gastoHielo) as gastoHielo, SUM(gastoOtros) as gastoOtros,
             SUM(kilos * precioPorKilo) as ingresoBruto
      FROM registro_embarcaciones WHERE fecha BETWEEN ? AND ?
    `;
    const [resultados] = await sequelize.query(query, { replacements: [fechaInicio, fechaFin] });
    servicioPdf.generarReporte(res, resultados[0], nombreBahia);
  } catch (error) {
    res.status(500).json({ exito: false, mensaje: "Error al generar PDF", error: error.message });
  }
}

module.exports = {
  registrar,
  historial,
  estadisticasRango,
  reportePdf
};
