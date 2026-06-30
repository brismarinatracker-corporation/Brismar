import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
// Asume que la entidad y el modelo existen de manera similar a la app móvil.
// Importar los modelos correctos según la arquitectura web (esto es un ejemplo funcional):
// import '../datos/modelos/cuadre_modelo.dart';

class ServicioExportacion {
  /// Exporta un listado de Cuadres a un archivo Excel (.xlsx) estructurado
  /// de forma profesional para que Contabilidad pueda analizarlo.
  static Future<void> exportarCuadresAExcel(List<dynamic> cuadres) async {
    // Inicializar el documento Excel
    var excel = Excel.createExcel();
    
    // Configurar la Hoja principal (Resumen de Lotes)
    Sheet sheetObject = excel['Cuadres Operativos'];
    excel.setDefaultSheet('Cuadres Operativos');
    excel.delete('Sheet1'); // Eliminar la hoja por defecto

    // Crear la cabecera (Fila 1) con estilo
    final headers = [
      'ID Cuadre', 'Fecha Zarpe', 'Placa Cámara', 'Embarcación', 'Especie', 
      'Kilos', 'Precio Unitario', 'Poder de Compra (Bruto)', 'Adelanto', 
      'Gastos Operativos (Prorrateo)', 'Utilidad Bahía (50%)', 'Estado'
    ];
    
    sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Iterar sobre todos los cuadres y sus compras
    for (var cuadre in cuadres) {
      final fechaStr = cuadre.fechaZarpe ?? 'Sin Fecha';
      final placa = cuadre.placa;
      
      // Calculamos gastos totales para prorratear si es necesario
      double gastosTotales = 0.0;
      for (var g in cuadre.gastos) {
        gastosTotales += (g.total ?? 0.0);
      }
      
      final compras = cuadre.compras as List;
      double kilosTotales = compras.fold(0.0, (sum, c) => sum + (c.kilos ?? 0.0));

      for (var compra in compras) {
        // Lógica de Negocio: Prorratear los gastos según el % de kilos de esta embarcación
        double porcentajeKilos = kilosTotales > 0 ? (compra.kilos / kilosTotales) : 0;
        double gastoAsignado = gastosTotales * porcentajeKilos;
        
        // Utilidad Neta del Lote = Total Compra - Gastos - Adelantos
        double utilidadLote = compra.total - gastoAsignado - (compra.adelanto ?? 0.0);
        double utilidadBahia = utilidadLote / 2; // 50/50

        sheetObject.appendRow([
          TextCellValue(cuadre.id.toString().substring(0,8)),
          TextCellValue(fechaStr),
          TextCellValue(placa),
          TextCellValue(compra.embarcacion),
          TextCellValue(compra.producto),
          DoubleCellValue(compra.kilos.toDouble()),
          DoubleCellValue(compra.precioUnitario.toDouble()),
          DoubleCellValue(compra.total.toDouble()),
          DoubleCellValue((compra.adelanto ?? 0.0).toDouble()),
          DoubleCellValue(gastoAsignado),
          DoubleCellValue(utilidadBahia),
          TextCellValue(cuadre.estado),
        ]);
      }
    }

    // Guardar el archivo localmente (Funciona en Web y Desktop gracias a file_saver)
    final dateFormat = DateFormat('yyyyMMdd_HHmm');
    final fileName = 'Reporte_Cuadres_Brismar_${dateFormat.format(DateTime.now())}';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(fileBytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }
  }
}
