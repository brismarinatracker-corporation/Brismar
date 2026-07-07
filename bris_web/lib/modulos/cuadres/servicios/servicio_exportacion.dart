import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import '../dominio/modelos/cuadre_web_modelo.dart';

class ServicioExportacion {
  // Mantengo intacta exportarCuadresAExcel (no se cambia según el plan)
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

  // NUEVA LÓGICA DE EXPORTACIÓN (EXCEL EXACTO A LA UI)
  static Future<void> exportarCuadreUnicoAExcel(CuadreWebModelo cuadre) async {
    final excel = Excel.createExcel();
    final hoja = excel['Liquidación'];
    excel.setDefaultSheet('Liquidación');
    excel.delete('Sheet1');
    
    // Clasificar Gastos
    List<GastoWebModelo> gastosAdmin = cuadre.gastos.where((g) {
      final c = g.concepto.toLowerCase();
      return c.contains('administrativo') || c.contains('facturacion') || 
             c.contains('facturación') || c.contains('certificado') || 
             c.contains('liquidacion') || c.contains('liquidación') || 
             c.contains('financiero') || c.contains('impuesto') || c.contains('renta');
    }).toList();
    List<GastoWebModelo> gastosMuelle = cuadre.gastos.where((g) => !gastosAdmin.contains(g)).toList();

    // ESTILOS
    var estiloCelesteCabecera = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#B4C6E7'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    var estiloCelesteTabla = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#D9E1F2'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    var estiloAmarillo = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FFFF00'),
      bold: true,
    );
    var estiloVerdeSeparador = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#C6E0B4'),
    );
    var estiloAzulOscuro = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#203764'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    var estiloNaranja = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FCE4D6'),
      bold: true,
    );
    var estiloNegritaDerecha = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Right);
    var estiloCabeceraColumna = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);

    // Ajustar anchos
    hoja.setColumnWidth(0, 12.0); // A
    hoja.setColumnWidth(1, 25.0); // B
    hoja.setColumnWidth(2, 15.0); // C
    hoja.setColumnWidth(3, 12.0); // D
    hoja.setColumnWidth(4, 12.0); // E
    hoja.setColumnWidth(5, 12.0); // F
    hoja.setColumnWidth(6, 4.0);  // G (Espacio)
    hoja.setColumnWidth(7, 4.0);  // H (Verde)
    hoja.setColumnWidth(8, 4.0);  // I (Espacio)
    hoja.setColumnWidth(9, 25.0); // J
    hoja.setColumnWidth(10, 15.0);// K
    hoja.setColumnWidth(11, 4.0); // L
    hoja.setColumnWidth(12, 15.0);// M
    hoja.setColumnWidth(13, 15.0);// N

    // Fila 1: Cabecera
    _escribir(hoja, 'B1', 'PLACA ${cuadre.placa}', estiloCelesteCabecera);
    hoja.merge(CellIndex.indexByString('B1'), CellIndex.indexByString('C1'));
    _escribir(hoja, 'D1', 'CAJAS', estiloCelesteCabecera);
    _escribir(hoja, 'E1', '${cuadre.cajasLlenas ?? 0}', estiloCelesteCabecera);
    
    // Panel Derecho - Margen (Fila 2)
    _escribir(hoja, 'M2', 'MARGEN', estiloNaranja);

    // TABLA COMPRA
    int fila = 3;
    _escribir(hoja, 'B$fila', 'COMPRA', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('F$fila'));
    fila++;
    
    _escribir(hoja, 'A$fila', 'FECHA', estiloCabeceraColumna);
    _escribir(hoja, 'B$fila', 'EMBARCACION', estiloCabeceraColumna);
    _escribir(hoja, 'C$fila', 'PRODUCTO', estiloCabeceraColumna);
    _escribir(hoja, 'D$fila', 'KILOS', estiloCabeceraColumna);
    _escribir(hoja, 'E$fila', 'PRECIO', estiloCabeceraColumna);
    _escribir(hoja, 'F$fila', 'TOTAL', estiloCabeceraColumna);
    fila++;
    
    int filaInicioCompra = fila;
    for (var c in cuadre.compras) {
      _escribir(hoja, 'A$fila', cuadre.fechaZarpe != null ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaZarpe!) ?? DateTime.now()).toUpperCase() : '');
      _escribir(hoja, 'B$fila', c.embarcacion);
      _escribir(hoja, 'C$fila', c.producto);
      _escribirNumero(hoja, 'D$fila', c.kilos);
      _escribirNumero(hoja, 'E$fila', c.precioUnitario);
      _escribirNumero(hoja, 'F$fila', c.total);
      fila++;
    }
    int filaFinCompra = fila - 1;
    if (filaFinCompra < filaInicioCompra) { filaFinCompra = filaInicioCompra; } // Para rangos vacíos
    
    _escribir(hoja, 'D$fila', '=SUM(D$filaInicioCompra:D$filaFinCompra)', estiloNegritaDerecha);
    _escribir(hoja, 'F$fila', '=SUM(F$filaInicioCompra:F$filaFinCompra)', estiloNegritaDerecha);
    int filaTotalCompra = fila;
    fila += 2;

    // TABLA VENTA
    _escribir(hoja, 'B$fila', 'VENTA', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('F$fila'));
    fila++;
    
    _escribir(hoja, 'A$fila', 'FECHA', estiloCabeceraColumna);
    _escribir(hoja, 'B$fila', 'LUGAR', estiloCabeceraColumna);
    _escribir(hoja, 'C$fila', 'PRODUCTO', estiloCabeceraColumna);
    _escribir(hoja, 'D$fila', 'KILOS', estiloCabeceraColumna);
    _escribir(hoja, 'E$fila', 'PRECIO', estiloCabeceraColumna);
    _escribir(hoja, 'F$fila', 'TOTAL', estiloCabeceraColumna);
    fila++;
    
    int filaInicioVenta = fila;
    for (var v in cuadre.ventas) {
      _escribir(hoja, 'A$fila', cuadre.fechaCuadre != null ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaCuadre!) ?? DateTime.now()).toUpperCase() : '');
      _escribir(hoja, 'B$fila', v.lugar);
      _escribir(hoja, 'C$fila', v.producto);
      _escribirNumero(hoja, 'D$fila', v.kilos);
      _escribirNumero(hoja, 'E$fila', v.precioUnitario);
      _escribirNumero(hoja, 'F$fila', v.total);
      fila++;
    }
    int filaFinVenta = fila - 1;
    if (filaFinVenta < filaInicioVenta) { filaFinVenta = filaInicioVenta; }
    
    _escribir(hoja, 'A$fila', 'TOTAL VENTA', estiloNegritaDerecha);
    _escribir(hoja, 'D$fila', '=SUM(D$filaInicioVenta:D$filaFinVenta)', estiloNegritaDerecha);
    _escribir(hoja, 'F$fila', '=SUM(F$filaInicioVenta:F$filaFinVenta)', estiloNegritaDerecha);
    int filaTotalVenta = fila;
    fila += 2;

    // RENDIMIENTO KILOS
    _escribir(hoja, 'A$fila', 'RENDIMIENTO', estiloAmarillo);
    hoja.merge(CellIndex.indexByString('A$fila'), CellIndex.indexByString('C$fila'));
    _escribir(hoja, 'D$fila', '=D$filaTotalVenta-D$filaTotalCompra', estiloAmarillo);
    
    // Separador central (Columna H) desde fila 1 hasta la actual
    for (int i = 1; i <= fila + 25; i++) {
      _escribir(hoja, 'H$i', '', estiloVerdeSeparador);
    }
    
    fila += 2;

    // Columna Izquierda Inferior: Gastos Muelle
    _escribir(hoja, 'B$fila', 'GASTOS MUELLE', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('C$fila'));
    fila++;
    
    _escribir(hoja, 'B$fila', 'DETALLE', estiloCabeceraColumna);
    _escribir(hoja, 'D$fila', 'IMPORTE', estiloCabeceraColumna);
    fila++;
    
    int filaInicioGM = fila;
    for (var g in gastosMuelle) {
      _escribir(hoja, 'B$fila', g.concepto);
      _escribirNumero(hoja, 'D$fila', g.total);
      fila++;
    }
    int filaFinGM = fila - 1;
    if (filaFinGM < filaInicioGM) { filaFinGM = filaInicioGM; }
    
    _escribir(hoja, 'B$fila', 'TOTAL', estiloNegritaDerecha);
    _escribir(hoja, 'D$fila', '=SUM(D$filaInicioGM:D$filaFinGM)', estiloNegritaDerecha);
    int filaTotalGM = fila;
    fila += 2;

    // Gastos Administrativo
    _escribir(hoja, 'B$fila', 'GASTOS ADMINISTRATIVO', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('C$fila'));
    fila++;
    
    _escribir(hoja, 'B$fila', 'DETALLE', estiloCabeceraColumna);
    _escribir(hoja, 'D$fila', 'IMPORTE', estiloCabeceraColumna);
    fila++;
    
    int filaInicioGA = fila;
    for (var g in gastosAdmin) {
      _escribir(hoja, 'B$fila', g.concepto);
      _escribirNumero(hoja, 'D$fila', g.total);
      fila++;
    }
    int filaFinGA = fila - 1;
    if (filaFinGA < filaInicioGA) { filaFinGA = filaInicioGA; }
    
    _escribir(hoja, 'B$fila', 'TOTAL', estiloNegritaDerecha);
    _escribir(hoja, 'D$fila', '=SUM(D$filaInicioGA:D$filaFinGA)', estiloNegritaDerecha);
    int filaTotalGA = fila;

    // Utilidades a la derecha (Panel flotante)
    // Usaremos la fila 18 estática a la derecha
    int filaUD = 18;
    _escribir(hoja, 'J$filaUD', 'UTILIDAD BRUTA', estiloAmarillo);
    _escribir(hoja, 'K$filaUD', '=F$filaTotalVenta-F$filaTotalCompra', estiloAmarillo);
    int cellUB = filaUD;
    
    filaUD += 2;
    _escribir(hoja, 'J$filaUD', 'UTILIDAD OPERATIVA', estiloAmarillo);
    _escribir(hoja, 'K$filaUD', '=K$cellUB-D$filaTotalGM', estiloAmarillo);
    int cellUO = filaUD;
    
    filaUD += 2;
    _escribir(hoja, 'J$filaUD', 'UT. ANTES DE REPARTO', estiloAmarillo);
    _escribir(hoja, 'K$filaUD', '=K$cellUO-D$filaTotalGA', estiloAmarillo);
    int cellUAR = filaUD;
    
    filaUD++;
    _escribir(hoja, 'J$filaUD', 'UTILIDAD DE TERCEROS');
    _escribirNumero(hoja, 'K$filaUD', 0.0);
    int cellUT = filaUD;
    
    filaUD += 2;
    _escribir(hoja, 'J$filaUD', 'UTILIDAD NETA', estiloAmarillo);
    _escribir(hoja, 'K$filaUD', '=K$cellUAR-K$cellUT', estiloAmarillo);
    int cellUN = filaUD;

    // Fila N2 Margen (Fórmula corregida sin IF)
    _escribir(hoja, 'N2', '=K$cellUN/F$filaTotalVenta', estiloNaranja);

    // Tabla Resumen (Abajo a la derecha del separador)
    int filaResumen = filaTotalGA + 2;
    if(filaResumen < filaUD + 2) filaResumen = filaUD + 2;

    _escribir(hoja, 'B$filaResumen', 'RESUMEN', estiloAzulOscuro);
    hoja.merge(CellIndex.indexByString('B$filaResumen'), CellIndex.indexByString('D$filaResumen'));
    filaResumen++;
    
    _escribir(hoja, 'B$filaResumen', '(1) VENTA'); _escribir(hoja, 'D$filaResumen', '=F$filaTotalVenta'); filaResumen++;
    _escribir(hoja, 'B$filaResumen', '(2) COMPRA'); _escribir(hoja, 'D$filaResumen', '=-F$filaTotalCompra'); filaResumen++;
    _escribir(hoja, 'B$filaResumen', '(3) GASTOS MUELLE'); _escribir(hoja, 'D$filaResumen', '=-D$filaTotalGM'); filaResumen++;
    _escribir(hoja, 'B$filaResumen', '(4) GASTOS ADMINISTRATIVO'); _escribir(hoja, 'D$filaResumen', '=-D$filaTotalGA'); filaResumen++;
    
    _escribir(hoja, 'B$filaResumen', 'TOTAL', estiloNegritaDerecha);
    _escribir(hoja, 'D$filaResumen', '=SUM(D${filaResumen-4}:D${filaResumen-1})', estiloNegritaDerecha);
    int celdaResumenTotal = filaResumen;
    
    filaResumen += 3;
    _escribir(hoja, 'B$filaResumen', '50%'); _escribir(hoja, 'C$filaResumen', 'EMPRESA'); _escribir(hoja, 'D$filaResumen', '=D$celdaResumenTotal*0.5'); filaResumen++;
    _escribir(hoja, 'B$filaResumen', '50%'); _escribir(hoja, 'C$filaResumen', 'DANIEL'); _escribir(hoja, 'D$filaResumen', '=D$celdaResumenTotal*0.5'); filaResumen++;

    final nombreArchivo = 'Liquidacion_${cuadre.placa}_${DateTime.now().millisecondsSinceEpoch}';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      await FileSaver.instance.saveFile(
        name: '$nombreArchivo.xlsx',
        bytes: Uint8List.fromList(fileBytes),
        mimeType: MimeType.microsoftExcel,
      );
    }
  }

  static void _escribir(Sheet hoja, String index, String valor, [CellStyle? estilo]) {
    var cell = hoja.cell(CellIndex.indexByString(index));
    if (valor.startsWith('=')) {
      cell.value = FormulaCellValue(valor);
    } else {
      cell.value = TextCellValue(valor);
    }
    if (estilo != null) {
      cell.cellStyle = estilo;
    }
  }

  static void _escribirNumero(Sheet hoja, String index, double valor, [CellStyle? estilo]) {
    var cell = hoja.cell(CellIndex.indexByString(index));
    cell.value = DoubleCellValue(valor);
    if (estilo != null) {
      cell.cellStyle = estilo;
    }
  }
}
