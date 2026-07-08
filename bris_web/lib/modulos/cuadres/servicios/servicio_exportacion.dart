import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import '../dominio/modelos/cuadre_web_modelo.dart';

/// Servicio encargado de exportar los datos de los cuadres operativos a
/// formato Excel (.xlsx) y guardarlos en el dispositivo local.
class ServicioExportacion {
  /// Exporta una lista de cuadres operativos en un reporte consolidado de Excel.
  ///
  /// Dibuja cada compra asociada a cada cuadre y calcula los gastos prorrateados
  /// y utilidades de bahía (50%).
  static Future<void> exportarCuadresAExcel(List<CuadreWebModelo> cuadres) async {
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Cuadres Operativos'];
    excel.setDefaultSheet('Cuadres Operativos');
    excel.delete('Sheet1');

    _escribirHeadersCuadres(sheetObject);
    _escribirDatosCuadres(sheetObject, cuadres);
    await _guardarReporteGeneral(excel);
  }

  /// Exporta un único cuadre simulando visualmente la hoja de liquidación de Excel original.
  ///
  /// Dibuja tablas separadas de compras, ventas y gastos del muelle/administrativos,
  /// incorporando fórmulas dinámicas nativas de Excel.
  static Future<void> exportarCuadreUnicoAExcel(CuadreWebModelo cuadre) async {
    final escritor = _EscritorCuadreExcel(cuadre);
    await escritor.exportar();
  }

  static void _escribirHeadersCuadres(Sheet sheet) {
    final headers = [
      'ID Cuadre', 'Fecha Zarpe', 'Placa Cámara', 'Embarcación', 'Especie', 
      'Kilos', 'Precio Unitario', 'Poder de Compra (Bruto)', 
      'Gastos Operativos (Prorrateo)', 'Utilidad Bahía (50%)', 'Estado'
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
  }

  static void _escribirDatosCuadres(Sheet sheet, List<CuadreWebModelo> cuadres) {
    for (var cuadre in cuadres) {
      final fechaStr = cuadre.fechaZarpe ?? 'Sin Fecha';
      final double gastosTotales = cuadre.gastos.fold(0.0, (sum, g) => sum + g.total);
      final double kilosTotales = cuadre.compras.fold(0.0, (sum, c) => sum + c.kilos);

      for (var compra in cuadre.compras) {
        _escribirFilaCompraCuadre(sheet, cuadre, compra, fechaStr, gastosTotales, kilosTotales);
      }
    }
  }

  static void _escribirFilaCompraCuadre(
    Sheet sheet,
    CuadreWebModelo cuadre,
    CompraWebModelo compra,
    String fechaStr,
    double gastosTotales,
    double kilosTotales,
  ) {
    final double porcentajeKilos = kilosTotales > 0 ? (compra.kilos / kilosTotales) : 0;
    final double gastoAsignado = gastosTotales * porcentajeKilos;
    final double utilidadLote = compra.total - gastoAsignado - (compra.adelanto ?? 0.0);
    final double utilidadBahia = utilidadLote / 2;

    sheet.appendRow([
      TextCellValue(cuadre.id.substring(0, 8)),
      TextCellValue(fechaStr),
      TextCellValue(cuadre.placa),
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

  static Future<void> _guardarReporteGeneral(Excel excel) async {
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
}

/// Helper privado que encapsula la escritura y formateo del reporte detallado
/// de liquidación de un único cuadre.
class _EscritorCuadreExcel {
  final CuadreWebModelo cuadre;
  final Excel excel;
  late final Sheet hoja;
  
  late final List<GastoWebModelo> gastosAdmin;
  late final List<GastoWebModelo> gastosMuelle;
  
  late final CellStyle estiloCelesteCabecera;
  late final CellStyle estiloCelesteTabla;
  late final CellStyle estiloAmarillo;
  late final CellStyle estiloVerdeSeparador;
  late final CellStyle estiloAzulOscuro;
  late final CellStyle estiloNaranja;
  late final CellStyle estiloNegritaDerecha;
  late final CellStyle estiloCabeceraColumna;

  int fila = 3;
  
  int filaTotalCompra = 0;
  int filaTotalVenta = 0;
  int filaTotalGM = 0;
  int filaTotalGA = 0;
  int cellUB = 18;
  int cellUO = 20;
  int cellUAR = 22;
  int cellUT = 23;
  int cellUN = 25;
  
  _EscritorCuadreExcel(this.cuadre) : excel = Excel.createExcel() {
    hoja = excel['Liquidación'];
    excel.setDefaultSheet('Liquidación');
    excel.delete('Sheet1');
    _clasificarGastos();
    _inicializarEstilos();
  }
  
  void _clasificarGastos() {
    gastosAdmin = cuadre.gastos.where((g) {
      final c = g.concepto.toLowerCase();
      return c.contains('administrativo') || c.contains('facturacion') || 
             c.contains('facturación') || c.contains('certificado') || 
             c.contains('liquidacion') || c.contains('liquidación') || 
             c.contains('financiero') || c.contains('impuesto') || c.contains('renta');
    }).toList();
    gastosMuelle = cuadre.gastos.where((g) => !gastosAdmin.contains(g)).toList();
  }
  
  void _inicializarEstilos() {
    estiloCelesteCabecera = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#B4C6E7'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    estiloCelesteTabla = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#D9E1F2'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    estiloAmarillo = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FFFF00'),
      bold: true,
    );
    estiloVerdeSeparador = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#C6E0B4'),
    );
    estiloAzulOscuro = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#203764'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );
    estiloNaranja = CellStyle(
      backgroundColorHex: ExcelColor.fromHexString('#FCE4D6'),
      bold: true,
    );
    estiloNegritaDerecha = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Right);
    estiloCabeceraColumna = CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
  }
  
  Future<void> exportar() async {
    _ajustarAnchosColumna();
    _escribirCabeceraInicial();
    _escribirTablaCompra();
    _escribirTablaVenta();
    _escribirRendimientoKilos();
    _escribirSeparadorVerde();
    _escribirGastosMuelle();
    _escribirGastosAdministrativos();
    _escribirUtilidadesDerecha();
    _escribirTablaResumenYReparto();
    await _guardarArchivo();
  }
  
  void _ajustarAnchosColumna() {
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
  }

  void _escribirCabeceraInicial() {
    _escribirCelda('B1', 'PLACA ${cuadre.placa}', estiloCelesteCabecera);
    hoja.merge(CellIndex.indexByString('B1'), CellIndex.indexByString('C1'));
    _escribirCelda('D1', 'CAJAS', estiloCelesteCabecera);
    _escribirCelda('E1', '${cuadre.cajasLlenas ?? 0}', estiloCelesteCabecera);
    _escribirCelda('M2', 'MARGEN', estiloNaranja);
  }

  void _escribirTablaCompra() {
    _escribirCelda('B$fila', 'COMPRA', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('F$fila'));
    fila++;
    
    _escribirCelda('A$fila', 'FECHA', estiloCabeceraColumna);
    _escribirCelda('B$fila', 'EMBARCACION', estiloCabeceraColumna);
    _escribirCelda('C$fila', 'PRODUCTO', estiloCabeceraColumna);
    _escribirCelda('D$fila', 'KILOS', estiloCabeceraColumna);
    _escribirCelda('E$fila', 'PRECIO', estiloCabeceraColumna);
    _escribirCelda('F$fila', 'TOTAL', estiloCabeceraColumna);
    fila++;
    
    final filaInicio = fila;
    for (var c in cuadre.compras) {
      final fecha = cuadre.fechaZarpe != null ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaZarpe!) ?? DateTime.now()).toUpperCase() : '';
      _escribirCelda('A$fila', fecha);
      _escribirCelda('B$fila', c.embarcacion);
      _escribirCelda('C$fila', c.producto);
      _escribirNumeroCelda('D$fila', c.kilos);
      _escribirNumeroCelda('E$fila', c.precioUnitario);
      _escribirNumeroCelda('F$fila', c.total);
      fila++;
    }
    final filaFin = (fila - 1) < filaInicio ? filaInicio : (fila - 1);
    
    _escribirCelda('D$fila', '=SUM(D$filaInicio:D$filaFin)', estiloNegritaDerecha);
    _escribirCelda('F$fila', '=SUM(F$filaInicio:F$filaFin)', estiloNegritaDerecha);
    filaTotalCompra = fila;
    fila += 2;
  }

  void _escribirTablaVenta() {
    _escribirCelda('B$fila', 'VENTA', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('F$fila'));
    fila++;
    
    _escribirCelda('A$fila', 'FECHA', estiloCabeceraColumna);
    _escribirCelda('B$fila', 'LUGAR', estiloCabeceraColumna);
    _escribirCelda('C$fila', 'PRODUCTO', estiloCabeceraColumna);
    _escribirCelda('D$fila', 'KILOS', estiloCabeceraColumna);
    _escribirCelda('E$fila', 'PRECIO', estiloCabeceraColumna);
    _escribirCelda('F$fila', 'TOTAL', estiloCabeceraColumna);
    fila++;
    
    final filaInicio = fila;
    for (var v in cuadre.ventas) {
      final fecha = cuadre.fechaCuadre != null ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaCuadre!) ?? DateTime.now()).toUpperCase() : '';
      _escribirCelda('A$fila', fecha);
      _escribirCelda('B$fila', v.lugar);
      _escribirCelda('C$fila', v.producto);
      _escribirNumeroCelda('D$fila', v.kilos);
      _escribirNumeroCelda('E$fila', v.precioUnitario);
      _escribirNumeroCelda('F$fila', v.total);
      fila++;
    }
    final filaFin = (fila - 1) < filaInicio ? filaInicio : (fila - 1);
    
    _escribirCelda('A$fila', 'TOTAL VENTA', estiloNegritaDerecha);
    _escribirCelda('D$fila', '=SUM(D$filaInicio:D$filaFin)', estiloNegritaDerecha);
    _escribirCelda('F$fila', '=SUM(F$filaInicio:F$filaFin)', estiloNegritaDerecha);
    filaTotalVenta = fila;
    fila += 2;
  }

  void _escribirRendimientoKilos() {
    _escribirCelda('A$fila', 'RENDIMIENTO', estiloAmarillo);
    hoja.merge(CellIndex.indexByString('A$fila'), CellIndex.indexByString('C$fila'));
    _escribirCelda('D$fila', '=D$filaTotalVenta-D$filaTotalCompra', estiloAmarillo);
  }

  void _escribirSeparadorVerde() {
    for (int i = 1; i <= fila + 25; i++) {
      _escribirCelda('H$i', '', estiloVerdeSeparador);
    }
    fila += 2;
  }

  void _escribirGastosMuelle() {
    _escribirCelda('B$fila', 'GASTOS MUELLE', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('C$fila'));
    fila++;
    
    _escribirCelda('B$fila', 'DETALLE', estiloCabeceraColumna);
    _escribirCelda('D$fila', 'IMPORTE', estiloCabeceraColumna);
    fila++;
    
    final filaInicio = fila;
    for (var g in gastosMuelle) {
      _escribirCelda('B$fila', g.concepto);
      _escribirNumeroCelda('D$fila', g.total);
      fila++;
    }
    final filaFin = (fila - 1) < filaInicio ? filaInicio : (fila - 1);
    
    _escribirCelda('B$fila', 'TOTAL', estiloNegritaDerecha);
    _escribirCelda('D$fila', '=SUM(D$filaInicio:D$filaFin)', estiloNegritaDerecha);
    filaTotalGM = fila;
    fila += 2;
  }

  void _escribirGastosAdministrativos() {
    _escribirCelda('B$fila', 'GASTOS ADMINISTRATIVO', estiloCelesteTabla);
    hoja.merge(CellIndex.indexByString('B$fila'), CellIndex.indexByString('C$fila'));
    fila++;
    
    _escribirCelda('B$fila', 'DETALLE', estiloCabeceraColumna);
    _escribirCelda('D$fila', 'IMPORTE', estiloCabeceraColumna);
    fila++;
    
    final filaInicio = fila;
    for (var g in gastosAdmin) {
      _escribirCelda('B$fila', g.concepto);
      _escribirNumeroCelda('D$fila', g.total);
      fila++;
    }
    final filaFin = (fila - 1) < filaInicio ? filaInicio : (fila - 1);
    
    _escribirCelda('B$fila', 'TOTAL', estiloNegritaDerecha);
    _escribirCelda('D$fila', '=SUM(D$filaInicio:D$filaFin)', estiloNegritaDerecha);
    filaTotalGA = fila;
  }

  void _escribirUtilidadesDerecha() {
    _escribirCelda('J$cellUB', 'UTILIDAD BRUTA', estiloAmarillo);
    _escribirCelda('K$cellUB', '=F$filaTotalVenta-F$filaTotalCompra', estiloAmarillo);
    
    _escribirCelda('J$cellUO', 'UTILIDAD OPERATIVA', estiloAmarillo);
    _escribirCelda('K$cellUO', '=K$cellUB-D$filaTotalGM', estiloAmarillo);
    
    _escribirCelda('J$cellUAR', 'UT. ANTES DE REPARTO', estiloAmarillo);
    _escribirCelda('K$cellUAR', '=K$cellUO-D$filaTotalGA', estiloAmarillo);
    
    _escribirCelda('J$cellUT', 'UTILIDAD DE TERCEROS');
    _escribirNumeroCelda('K$cellUT', 0.0);
    
    _escribirCelda('J$cellUN', 'UTILIDAD NETA', estiloAmarillo);
    _escribirCelda('K$cellUN', '=K$cellUAR-K$cellUT', estiloAmarillo);

    _escribirCelda('N2', '=K$cellUN/F$filaTotalVenta', estiloNaranja);
  }

  void _escribirTablaResumenYReparto() {
    int filaResumen = filaTotalGA + 2;
    if (filaResumen < cellUN + 2) { filaResumen = cellUN + 2; }

    _escribirCelda('B$filaResumen', 'RESUMEN', estiloAzulOscuro);
    hoja.merge(CellIndex.indexByString('B$filaResumen'), CellIndex.indexByString('D$filaResumen'));
    filaResumen++;
    
    _escribirCelda('B$filaResumen', '(1) VENTA'); _escribirCelda('D$filaResumen', '=F$filaTotalVenta'); filaResumen++;
    _escribirCelda('B$filaResumen', '(2) COMPRA'); _escribirCelda('D$filaResumen', '=-F$filaTotalCompra'); filaResumen++;
    _escribirCelda('B$filaResumen', '(3) GASTOS MUELLE'); _escribirCelda('D$filaResumen', '=-D$filaTotalGM'); filaResumen++;
    _escribirCelda('B$filaResumen', '(4) GASTOS ADMINISTRATIVO'); _escribirCelda('D$filaResumen', '=-D$filaTotalGA'); filaResumen++;
    
    _escribirCelda('B$filaResumen', 'TOTAL', estiloNegritaDerecha);
    _escribirCelda('D$filaResumen', '=SUM(D${filaResumen-4}:D${filaResumen-1})', estiloNegritaDerecha);
    final celdaResumenTotal = filaResumen;
    
    filaResumen += 3;
    _escribirCelda('B$filaResumen', '50%'); _escribirCelda('C$filaResumen', 'EMPRESA'); _escribirCelda('D$filaResumen', '=D$celdaResumenTotal*0.5'); filaResumen++;
    _escribirCelda('B$filaResumen', '50%'); _escribirCelda('C$filaResumen', 'DANIEL'); _escribirCelda('D$filaResumen', '=D$celdaResumenTotal*0.5');
  }

  Future<void> _guardarArchivo() async {
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
  
  void _escribirCelda(String index, String valor, [CellStyle? estilo]) {
    final cell = hoja.cell(CellIndex.indexByString(index));
    if (valor.startsWith('=')) {
      cell.value = FormulaCellValue(valor);
    } else {
      cell.value = TextCellValue(valor);
    }
    if (estilo != null) {
      cell.cellStyle = estilo;
    }
  }

  void _escribirNumeroCelda(String index, double valor, [CellStyle? estilo]) {
    final cell = hoja.cell(CellIndex.indexByString(index));
    cell.value = DoubleCellValue(valor);
    if (estilo != null) {
      cell.cellStyle = estilo;
    }
  }
}
