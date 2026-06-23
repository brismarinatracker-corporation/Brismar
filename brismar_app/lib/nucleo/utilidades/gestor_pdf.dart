import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../modulos/registro/dominio/entidades/registro_entidad.dart';

/// Clase de utilidad para compilar reportes PDF locales en Dart.
/// Sigue el principio de Responsabilidad Única (SRP).
class GestorPdf {
  /// Genera un archivo PDF con el desglose de pesca y gastos del muelle.
  static Future<File> generarReportePesca(
    RegistroEntidad reg,
    String nombreUsuario,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(nombreUsuario),
                pw.SizedBox(height: 10),
                _buildTituloReporte(reg),
                pw.SizedBox(height: 15),
                _buildDetallePesca(reg),
                pw.SizedBox(height: 20),
                _buildTablaGastos(reg),
                pw.SizedBox(height: 20),
                _buildResumenFinanciero(reg),
              ],
            ),
          );
        },
      ),
    );

    return await _savePdfFile(pdf, reg.id);
  }

  static pw.Widget _buildHeader(String nombreUsuario) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'NEGOCIOS BRISMAR S.R.L.',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('RUC: 20608554124', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Bahía Responsable: $nombreUsuario',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Generado por: BRISMAR APP',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTituloReporte(RegistroEntidad reg) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'REPORTE DETALLADO DE OPERACIONES',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Fecha: ${reg.fecha} - Hora: ${reg.hora}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetallePesca(RegistroEntidad reg) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '1. DATOS DE LA EMBARCACIÓN Y MATERIA PRIMA',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '- Nombre de la Nave: ${reg.nombreEmbarcacion.toUpperCase()}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '- Especie (Producto): ${reg.producto}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '- Placa de Cámara: ${reg.placaCarro ?? 'N/A'}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '- Total de Cajas: ${reg.cajas}',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '- Muelle de Partida: ${reg.muelleInicio}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  static pw.Widget _buildTablaGastos(RegistroEntidad reg) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '2. DESGLOSE DE GASTOS DEL MUELLE',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        _buildFilaGasto('Gasto de Hielo', reg.gastoHielo),
        _buildFilaGasto(
          'Gasto de Personal (Estibas/Cargadores)',
          reg.gastoPersonal,
        ),
        _buildFilaGasto('Gasto de Pesador', reg.gastoPesador),
        _buildFilaGasto('Gasto de Flete (Transporte)', reg.gastoFlete),
        _buildFilaGasto(
          'Gasto de Agua y Clorox',
          reg.gastoAgua + reg.gastoClorox,
        ),
        _buildFilaGasto('Gasto de Facturación', reg.gastoFacturacion),
        _buildFilaGasto('Gasto de Apoyo Operativo', reg.gastoApoyo),
        _buildFilaGasto('Otros Gastos', reg.gastoOtros),
      ],
    );
  }

  static pw.Widget _buildFilaGasto(String concepto, double valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('- $concepto:', style: const pw.TextStyle(fontSize: 10)),
          pw.Text(
            'S/ ${valor.toStringAsFixed(2)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildResumenFinanciero(RegistroEntidad reg) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          _buildFilaResumen(
            'INGRESO BRUTO (Venta: ${reg.kilos} kg x S/ ${reg.precioPorKilo.toStringAsFixed(2)}):',
            reg.ingresoBruto,
          ),
          _buildFilaResumen(
            '(-) TOTAL GASTOS DE OPERACIÓN:',
            reg.totalGastos,
            esGasto: true,
          ),
          pw.Divider(),
          _buildFilaResumen(
            '(=) UTILIDAD NETA (Ganancia Real):',
            reg.utilidadNeta,
            esNegrita: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFilaResumen(
    String text,
    double value, {
    bool esGasto = false,
    bool esNegrita = false,
  }) {
    final style = pw.TextStyle(
      fontSize: 10,
      fontWeight: esNegrita ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: esNegrita ? PdfColors.green800 : PdfColors.black,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(text, style: style),
        pw.Text(
          '${esGasto ? "- " : ""}S/ ${value.toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }

  static Future<File> _savePdfFile(pw.Document pdf, String id) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/reporte_$id.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
