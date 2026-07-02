import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import '../dominio/modelos/cuadre_web_modelo.dart';

/// Servicio dedicado a la generación y descarga de reportes Excel (.xlsx).
/// Cumple con el principio de Responsabilidad Única (SRP).
class ServicioExportacion {
  
  /// Exporta un listado completo de Cuadres a un archivo Excel (.xlsx) estructurado
  /// de forma profesional para que Contabilidad pueda analizarlo con prorrateo de gastos.
  static Future<void> exportarCuadresAExcel(List<CuadreWebModelo> cuadres) async {
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Cuadres Operativos'];
    excel.setDefaultSheet('Cuadres Operativos');
    excel.delete('Sheet1'); 

    final headers = [
      'ID Cuadre', 'Fecha Zarpe', 'Placa Cámara', 'Embarcación', 'Especie', 
      'Kilos', 'Precio Unitario', 'Poder de Compra (Bruto)', 'Adelanto', 
      'Gastos Operativos (Prorrateo)', 'Utilidad Bahía (50%)', 'Estado'
    ];
    
    sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (var cuadre in cuadres) {
      final fechaStr = cuadre.fechaZarpe ?? 'Sin Fecha';
      final placa = cuadre.placa;
      
      double gastosTotales = cuadre.gastos.fold(0.0, (sum, g) => sum + g.total);
      double kilosTotales = cuadre.compras.fold(0.0, (sum, c) => sum + c.kilos);

      for (var compra in cuadre.compras) {
        double porcentajeKilos = kilosTotales > 0 ? (compra.kilos / kilosTotales) : 0;
        double gastoAsignado = gastosTotales * porcentajeKilos;
        double utilidadLote = compra.total - gastoAsignado - (compra.adelanto ?? 0.0);
        double utilidadBahia = utilidadLote / 2;

        sheetObject.appendRow([
          TextCellValue(cuadre.id.substring(0, 8)),
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

    final dateFormat = DateFormat('yyyyMMdd_HHmm');
    final fileName = 'Reporte_Cuadres_Brismar_${dateFormat.format(DateTime.now())}';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      await FileSaver.instance.saveFile(
        name: '$fileName.xlsx',
        bytes: Uint8List.fromList(fileBytes),
        mimeType: MimeType.microsoftExcel,
      );
    }
  }

  /// Genera y descarga un Excel detallado con pestañas separadas
  /// para un único cuadre seleccionado.
  static Future<void> exportarCuadreUnicoAExcel(CuadreWebModelo cuadre) async {
    final fmt = NumberFormat('#,##0.00', 'es_PE');
    final excel = Excel.createExcel();
    
    _agregarHojaCabecera(excel, cuadre, fmt);
    _agregarHojaCompras(excel, cuadre, fmt);
    _agregarHojaGastos(excel, cuadre, fmt);
    _agregarHojaVentas(excel, cuadre, fmt);

    final nombreArchivo = 'Cuadre_${cuadre.placa}_${DateTime.now().millisecondsSinceEpoch}';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      await FileSaver.instance.saveFile(
        name: '$nombreArchivo.xlsx',
        bytes: Uint8List.fromList(fileBytes),
        mimeType: MimeType.microsoftExcel,
      );
    }
  }

  static void _agregarHojaCabecera(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Resumen'];
    excel.setDefaultSheet('Resumen');
    excel.delete('Sheet1');
    _fila(hoja, ['CUADRE BRISMAR - RESUMEN']);
    _fila(hoja, ['Placa:', c.placa]);
    _fila(hoja, ['Fecha Zarpe:', c.fechaZarpe ?? '-']);
    _fila(hoja, ['Estado:', c.estado.toUpperCase()]);
    _fila(hoja, ['Planta Destino:', c.plantaDestino ?? '-']);
    _fila(hoja, ['Peso Total (kg):', c.pesoTotal?.toString() ?? '-']);
    _fila(hoja, ['']);
    _fila(hoja, ['TOTALES']);
    _fila(hoja, ['Total Compras:', 'S/ ${fmt.format(c.totalCompras)}']);
    _fila(hoja, ['Total Gastos:', 'S/ ${fmt.format(c.totalGastos)}']);
    _fila(hoja, ['Total Ventas:', 'S/ ${fmt.format(c.totalVentas)}']);
    _fila(hoja, ['Utilidad Neta:', 'S/ ${fmt.format(c.utilidadNeta)}']);
  }

  static void _agregarHojaCompras(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Compras'];
    _fila(hoja, ['Embarcación', 'Producto', 'Kilos', 'Precio Unit.', 'Total']);
    for (var item in c.compras) {
      _fila(hoja, [item.embarcacion, item.producto, item.kilos, fmt.format(item.precioUnitario), fmt.format(item.total)]);
    }
  }

  static void _agregarHojaGastos(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Gastos'];
    _fila(hoja, ['Tipo', 'Concepto', 'Cantidad', 'Costo Unit.', 'Total']);
    for (var item in c.gastos) {
      _fila(hoja, [item.tipo, item.concepto, item.cantidad, fmt.format(item.costoUnitario), fmt.format(item.total)]);
    }
  }

  static void _agregarHojaVentas(Excel excel, CuadreWebModelo c, NumberFormat fmt) {
    final hoja = excel['Ventas'];
    _fila(hoja, ['Lugar', 'Producto', 'Kilos', 'Precio Unit.', 'Total']);
    for (var item in c.ventas) {
      _fila(hoja, [item.lugar, item.producto, item.kilos, fmt.format(item.precioUnitario), fmt.format(item.total)]);
    }
  }

  static void _fila(Sheet hoja, List<dynamic> valores) {
    hoja.appendRow(valores.map((v) => TextCellValue(v.toString())).toList());
  }
}
