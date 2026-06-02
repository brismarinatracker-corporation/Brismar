const PDFDocument = require('pdfkit');

/**
 * Calcula la suma de todos los gastos de muelle a partir de los datos provistos.
 * 
 * @param {object} d - Datos del registro de embarcaciones.
 * @returns {number} Suma acumulada de gastos.
 */
function calcularTotal(d) {
  const llaves = ['gastoHielo', 'gastoPersonal', 'gastoFlete', 'gastoAgua', 'gastoOtros', 'gastoFacturacion', 'gastoApoyo', 'gastoClorox'];
  return llaves.reduce((acc, k) => acc + (parseFloat(d[k]) || 0), 0);
}

/**
 * Dibuja la sección de cabecera e identificación en el PDF.
 * 
 * @param {object} doc - Documento PDFKit.
 * @param {string} nombreBahia - Nombre del Bahía responsable.
 */
function dibujarCabecera(doc, nombreBahia) {
  doc.fontSize(20).text('NEGOCIOS BRISMAR S.R.L.', { align: 'right' });
  doc.fontSize(10).text(`Bahía Responsable: ${nombreBahia}`, { align: 'right' });
  doc.moveDown(2);
  doc.fontSize(16).text('REPORTE DETALLADO DE OPERACIONES', { align: 'center', underline: true });
  doc.moveDown(2);
}

/**
 * Dibuja el desglose de los gastos en el muelle en el PDF.
 * 
 * @param {object} doc - Documento PDFKit.
 * @param {object} datos - Objeto de datos con los gastos.
 */
function dibujarDesgloseGastos(doc, datos) {
  const total = calcularTotal(datos);
  doc.fontSize(12).text('--- DESGLOSE DE GASTOS DEL MUELLE ---');
  doc.text(`- Hielo: S/ ${(parseFloat(datos.gastoHielo) || 0).toFixed(2)}`);
  doc.text(`- Personal: S/ ${(parseFloat(datos.gastoPersonal) || 0).toFixed(2)}`);
  doc.text(`- Flete: S/ ${(parseFloat(datos.gastoFlete) || 0).toFixed(2)}`);
  doc.text(`- Agua/Clorox: S/ ${(parseFloat(datos.gastoAgua) || 0).toFixed(2)}`);
  doc.text(`- Otros: S/ ${(parseFloat(datos.gastoOtros) || 0).toFixed(2)}`);
  doc.text('-------------------------------------');
  doc.fontSize(13).text(`TOTAL GASTOS: S/ ${total.toFixed(2)}`, { bold: true });
  doc.moveDown(2);
}

/**
 * Dibuja el resumen financiero en el PDF (Ingreso Bruto y Utilidad Neta).
 * 
 * @param {object} doc - Documento PDFKit.
 * @param {object} datos - Objeto de datos con los ingresos y gastos.
 */
function dibujarResumenFinanciero(doc, datos) {
  const total = calcularTotal(datos);
  const ingresoBruto = parseFloat(datos.ingresoBruto) || 0;
  const utilidadNeta = ingresoBruto - total;
  doc.fontSize(12).text(`INGRESO BRUTO (Venta): S/ ${ingresoBruto.toFixed(2)}`);
  doc.fillColor('green').text(`UTILIDAD NETA (Ganancia Real): S/ ${utilidadNeta.toFixed(2)}`);
}

/**
 * Genera el documento PDF y lo transmite como respuesta HTTP.
 * 
 * @param {object} res - Respuesta de Express.
 * @param {object} datos - Objeto con los datos acumulados.
 * @param {string} nombreBahia - Nombre del Bahía responsable.
 */
function generarReporte(res, datos, nombreBahia) {
  const doc = new PDFDocument();
  doc.pipe(res);
  dibujarCabecera(doc, nombreBahia);
  dibujarDesgloseGastos(doc, datos);
  dibujarResumenFinanciero(doc, datos);
  doc.end();
}

module.exports = {
  generarReporte
};
