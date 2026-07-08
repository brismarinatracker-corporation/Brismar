import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';

/// Un widget que renderiza visualmente un cuadre en formato similar a una
/// hoja de liquidación de Excel.
class HojaLiquidacionExcel extends StatelessWidget {
  /// El modelo del cuadre que contiene la información de compras, ventas y gastos.
  final CuadreWebModelo cuadre;

  /// El formateador numérico para dar formato monetario y de cantidades.
  final NumberFormat fmt;

  /// Crea una instancia de [HojaLiquidacionExcel].
  const HojaLiquidacionExcel({
    super.key,
    required this.cuadre,
    required this.fmt,
  });

  /// Color celeste utilizado para cabeceras principales en la liquidación.
  static const Color colorCelesteCabecera = Color(0xFFB4C6E7);

  /// Color celeste utilizado para celdas de título de tablas.
  static const Color colorCelesteTabla = Color(0xFFD9E1F2);

  /// Color amarillo utilizado para destacar rendimientos y utilidades.
  static const Color colorAmarillo = Color(0xFFFFFF00);

  /// Color verde utilizado para el separador central de la liquidación.
  static const Color colorVerdeSeparador = Color(0xFFC6E0B4);

  /// Color azul oscuro utilizado para la sección del resumen.
  static const Color colorAzulOscuro = Color(0xFF203764);

  /// Color naranja claro utilizado para la celda de margen.
  static const Color colorNaranjaClaro = Color(0xFFFCE4D6);

  /// Color de borde negro por defecto.
  static const Color colorBorde = Color(0xFF000000);

  /// Obtiene los gastos administrativos filtrados por palabra clave en el concepto.
  List<GastoWebModelo> get gastosAdministrativos {
    return cuadre.gastos.where((g) {
      final c = g.concepto.toLowerCase();
      return c.contains('administrativo') ||
             c.contains('facturacion') ||
             c.contains('facturación') ||
             c.contains('certificado') ||
             c.contains('liquidacion') ||
             c.contains('liquidación') ||
             c.contains('financiero') ||
             c.contains('impuesto') ||
             c.contains('renta');
    }).toList();
  }

  /// Obtiene los gastos de muelle que no son administrativos.
  List<GastoWebModelo> get gastosMuelle {
    return cuadre.gastos.where((g) => !gastosAdministrativos.contains(g)).toList();
  }

  /// Total acumulado de las compras.
  double get totalCompra => cuadre.totalCompras;

  /// Total acumulado de las ventas.
  double get totalVenta => cuadre.totalVentas;

  /// Total acumulado de los gastos de muelle.
  double get totalGastosMuelle => gastosMuelle.fold(0.0, (s, g) => s + g.total);

  /// Total acumulado de los gastos administrativos.
  double get totalGastosAdmin => gastosAdministrativos.fold(0.0, (s, g) => s + g.total);

  /// Cantidad total de kilos comprados.
  double get kilosCompra => cuadre.compras.fold(0.0, (s, c) => s + c.kilos);

  /// Cantidad total de kilos vendidos.
  double get kilosVenta => cuadre.ventas.fold(0.0, (s, v) => s + v.kilos);

  /// Diferencia de kilos entre venta y compra (rendimiento).
  double get rendimientoKilos => kilosVenta - kilosCompra;

  /// Utilidad bruta calculada como ventas menos compras.
  double get utilidadBruta => totalVenta - totalCompra;

  /// Utilidad operativa calculada como utilidad bruta menos gastos de muelle.
  double get utilidadOperativa => utilidadBruta - totalGastosMuelle;

  /// Utilidad antes de reparto calculada como utilidad operativa menos gastos administrativos.
  double get utilidadAntesReparto => utilidadOperativa - totalGastosAdmin;

  /// Utilidad correspondiente a terceros (fija en 0.0 por defecto).
  double get utilidadTerceros => 0.0;

  /// Utilidad neta final a distribuir.
  double get utilidadNeta => utilidadAntesReparto - utilidadTerceros;

  /// Margen porcentual de utilidad sobre la venta total.
  double get margen => totalVenta > 0 ? (utilidadNeta / totalVenta) : 0.0;

  /// Reparto de utilidad correspondiente a la empresa (50%).
  double get repartoEmpresa => utilidadNeta * 0.50;

  /// Reparto de utilidad correspondiente al bahía Daniel (50%).
  double get repartoDaniel => utilidadNeta * 0.50;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.black, fontSize: 11, fontFamily: 'Arial'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirPanelIzquierdo(),
                _construirSeparadorVerde(),
                _construirPanelDerecho(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Componentes de UI ──────────────────────────────────────────────────────

  Widget _construirSeparadorVerde() {
    return Container(
      width: 40,
      height: 600,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorVerdeSeparador,
        border: Border.all(color: colorBorde, width: 0.5),
      ),
    );
  }

  Widget _construirPanelIzquierdo() {
    return SizedBox(
      width: 650,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirCabeceraPrincipal(),
          const SizedBox(height: 16),
          _construirTablaCompras(),
          const SizedBox(height: 16),
          _construirTablaVentas(),
          const SizedBox(height: 16),
          _construirRendimiento(rendimientoKilos),
          const SizedBox(height: 24),
          _construirFilaGastosYResumen(),
        ],
      ),
    );
  }

  Widget _construirFilaGastosYResumen() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 250,
          child: Column(
            children: [
              _construirTablaGastos('GASTOS MUELLE', gastosMuelle, totalGastosMuelle),
              const SizedBox(height: 16),
              _construirTablaGastos('GASTOS ADMINISTRATIVO', gastosAdministrativos, totalGastosAdmin),
            ],
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _construirTablaResumen(totalVenta, totalCompra, totalGastosMuelle, totalGastosAdmin, utilidadNeta),
              const SizedBox(height: 24),
              _construirTablaReparto(repartoEmpresa, repartoDaniel),
              const SizedBox(height: 32),
              _construirRendimientoFooter(kilosVenta, kilosCompra, rendimientoKilos),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirPanelDerecho() {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _celdaIndependiente('MARGEN', '${(margen * 100).toStringAsFixed(2)}%', colorFondo: colorNaranjaClaro),
          const SizedBox(height: 180),
          _filaUtilidadDerecha('UTILIDAD BRUTA', utilidadBruta),
          const SizedBox(height: 90),
          _filaUtilidadDerecha('UTILIDAD OPERATIVA', utilidadOperativa),
          const SizedBox(height: 90),
          _filaUtilidadDerecha('UT. ANTES DE REPARTO', utilidadAntesReparto),
          _filaValorSolo('UTILIDAD DE TERCEROS', utilidadTerceros, colorTexto: Colors.red),
          const SizedBox(height: 8),
          _filaUtilidadDerecha('UTILIDAD NETA', utilidadNeta),
        ],
      ),
    );
  }

  Widget _construirCabeceraPrincipal() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(100),
        1: FixedColumnWidth(250),
        2: FixedColumnWidth(80),
        3: FixedColumnWidth(100),
      },
      border: TableBorder.all(color: colorBorde, width: 1),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: colorCelesteCabecera),
          children: [
            const SizedBox.shrink(),
            _celdaCabecera('PLACA ${cuadre.placa}'),
            const SizedBox.shrink(),
            _celdaCabecera('CAJAS: ${cuadre.cajasLlenas ?? 0}'),
          ]
        )
      ],
    );
  }

  Widget _construirTablaCompras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colorCelesteTabla,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          child: const Text('COMPRA', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(80),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FixedColumnWidth(80),
            4: FixedColumnWidth(80),
            5: FixedColumnWidth(100),
          },
          border: TableBorder.all(color: colorBorde, width: 0.5),
          children: [
            _construirFilaCabeceraCompra(),
            for (var c in cuadre.compras) _construirFilaDatoCompra(c),
            _construirFilaTotalCompra(),
          ],
        ),
      ],
    );
  }

  TableRow _construirFilaCabeceraCompra() {
    return TableRow(
      children: [
        _celdaCabecera('FECHA'),
        _celdaCabecera('EMBARCACION'),
        _celdaCabecera('PRODUCTO'),
        _celdaCabecera('KILOS'),
        _celdaCabecera('PRECIO'),
        _celdaCabecera('TOTAL'),
      ],
    );
  }

  TableRow _construirFilaDatoCompra(CompraWebModelo c) {
    final fecha = cuadre.fechaZarpe != null
        ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaZarpe!) ?? DateTime.now()).toUpperCase()
        : '';
    return TableRow(
      children: [
        _celdaDato(fecha),
        _celdaDato(c.embarcacion),
        _celdaDato(c.producto),
        _celdaNumero(c.kilos),
        _celdaNumero(c.precioUnitario),
        _celdaNumero(c.total),
      ],
    );
  }

  TableRow _construirFilaTotalCompra() {
    return TableRow(
      children: [
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        _celdaNumero(kilosCompra, negrita: true),
        const SizedBox.shrink(),
        _celdaNumero(totalCompra, negrita: true),
      ],
    );
  }

  Widget _construirTablaVentas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colorCelesteTabla,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          child: const Text('VENTA', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Table(
          columnWidths: const {
            0: FixedColumnWidth(80),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FixedColumnWidth(80),
            4: FixedColumnWidth(80),
            5: FixedColumnWidth(100),
          },
          border: TableBorder.all(color: colorBorde, width: 0.5),
          children: [
            _construirFilaCabeceraVenta(),
            for (var v in cuadre.ventas) _construirFilaDatoVenta(v),
            _construirFilaTotalVenta(),
          ],
        ),
      ],
    );
  }

  TableRow _construirFilaCabeceraVenta() {
    return TableRow(
      children: [
        _celdaCabecera('FECHA'),
        _celdaCabecera('LUGAR'),
        _celdaCabecera('PRODUCTO'),
        _celdaCabecera('KILOS'),
        _celdaCabecera('PRECIO'),
        _celdaCabecera('TOTAL'),
      ],
    );
  }

  TableRow _construirFilaDatoVenta(VentaWebModelo v) {
    final fecha = cuadre.fechaCuadre != null
        ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaCuadre!) ?? DateTime.now()).toUpperCase()
        : '';
    return TableRow(
      children: [
        _celdaDato(fecha),
        _celdaDato(v.lugar),
        _celdaDato(v.producto),
        _celdaNumero(v.kilos),
        _celdaNumero(v.precioUnitario),
        _celdaNumero(v.total),
      ],
    );
  }

  TableRow _construirFilaTotalVenta() {
    return TableRow(
      children: [
        _celdaDato('TOTAL VENTA', negrita: true),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        _celdaNumero(kilosVenta, negrita: true),
        const SizedBox.shrink(),
        _celdaNumero(totalVenta, negrita: true),
      ],
    );
  }

  Widget _construirRendimiento(double rendimiento) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(250),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(100),
      },
      border: TableBorder.all(color: colorBorde, width: 1),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: colorAmarillo),
          children: [
            _celdaCabecera('RENDIMIENTO', alineacion: Alignment.centerLeft),
            const SizedBox.shrink(),
            _celdaNumero(rendimiento, negrita: true),
          ]
        )
      ],
    );
  }

  Widget _construirTablaGastos(String titulo, List<GastoWebModelo> gastos, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colorCelesteTabla,
          padding: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FixedColumnWidth(100),
          },
          border: TableBorder.all(color: colorBorde, width: 0.5),
          children: [
            _construirFilaCabeceraGastos(),
            for (var g in gastos) _construirFilaDatoGasto(g),
            _construirFilaTotalGastos(total),
          ],
        ),
      ],
    );
  }

  TableRow _construirFilaCabeceraGastos() {
    return TableRow(
      children: [
        _celdaCabecera('DETALLE'),
        _celdaCabecera('IMPORTE'),
      ],
    );
  }

  TableRow _construirFilaDatoGasto(GastoWebModelo g) {
    return TableRow(
      children: [
        _celdaDato(g.concepto),
        _celdaNumero(g.total),
      ],
    );
  }

  TableRow _construirFilaTotalGastos(double total) {
    return TableRow(
      children: [
        _celdaCabecera('TOTAL', alineacion: Alignment.centerLeft),
        _celdaNumero(total, negrita: true),
      ],
    );
  }

  Widget _construirTablaResumen(double v, double c, double gm, double ga, double neta) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FixedColumnWidth(100),
      },
      border: TableBorder.all(color: colorBorde, width: 1),
      children: [
        _construirFilaCabeceraResumen(),
        _construirFilaResumenValor('(1) VENTA', v),
        _construirFilaResumenValor('(2) COMPRA', -c),
        _construirFilaResumenValor('(3) GASTOS MUELLE', -gm),
        _construirFilaResumenValor('(4) GASTOS ADMINISTRATIVO', -ga),
        _construirFilaResumenValor('TOTAL', neta, negrita: true),
      ],
    );
  }

  TableRow _construirFilaCabeceraResumen() {
    return const TableRow(
      decoration: BoxDecoration(color: colorAzulOscuro),
      children: [
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Text('RESUMEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
        SizedBox.shrink(),
      ],
    );
  }

  TableRow _construirFilaResumenValor(String etiqueta, double valor, {bool negrita = false}) {
    return TableRow(
      children: [
        _celdaDato(etiqueta, negrita: negrita || etiqueta == 'TOTAL'),
        _celdaNumero(valor, negrita: negrita || etiqueta == 'TOTAL'),
      ],
    );
  }

  Widget _construirTablaReparto(double e, double d) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FlexColumnWidth(1),
        2: FixedColumnWidth(100),
      },
      border: TableBorder.all(color: colorBorde, width: 1),
      children: [
        TableRow(
          children: [
            _celdaDato('50%', alineacion: Alignment.center),
            _celdaDato('EMPRESA', negrita: true),
            _celdaNumero(e),
          ]
        ),
        TableRow(
          children: [
            _celdaDato('50%', alineacion: Alignment.center),
            _celdaDato('DANIEL', negrita: true),
            _celdaNumero(d),
          ]
        ),
      ],
    );
  }

  Widget _construirRendimientoFooter(double v, double c, double r) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(100),
        1: FixedColumnWidth(100),
        2: FixedColumnWidth(100),
      },
      border: TableBorder.all(color: colorBorde, width: 1),
      children: [
        TableRow(
          children: [
            _celdaCabecera('VENTA'),
            _celdaCabecera('COMPRA'),
            Container(color: colorAmarillo, child: _celdaCabecera('RENDIMIENTO')),
          ]
        ),
        TableRow(
          children: [
            _celdaNumero(v),
            _celdaNumero(c),
            Container(color: colorAmarillo, child: _celdaNumero(r, negrita: true)),
          ]
        ),
      ],
    );
  }

  // ─── Utilidades ─────────────────────────────────────────────────────────────

  Widget _filaUtilidadDerecha(String etiqueta, double valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 200,
          color: colorAmarillo,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: 100,
          color: colorAmarillo,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.centerRight,
          child: Text(fmt.format(valor), style: TextStyle(fontWeight: FontWeight.bold, color: valor < 0 ? Colors.red : Colors.black)),
        ),
      ],
    );
  }

  Widget _filaValorSolo(String etiqueta, double valor, {Color colorTexto = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.centerRight,
          child: Text(fmt.format(valor), style: TextStyle(color: colorTexto)),
        ),
      ],
    );
  }

  Widget _celdaIndependiente(String etiqueta, String valor, {Color colorFondo = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(border: Border.all(color: colorBorde)),
          child: Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Container(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(color: colorFondo, border: Border.all(color: colorBorde)),
          child: Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _celdaCabecera(String texto, {Alignment alineacion = Alignment.center}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
        alignment: alineacion,
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _celdaDato(String texto, {bool negrita = false, Alignment alineacion = Alignment.centerLeft}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
        alignment: alineacion,
        child: Text(texto, style: TextStyle(fontWeight: negrita ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  Widget _celdaNumero(double numero, {bool negrita = false}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          fmt.format(numero),
          style: TextStyle(fontWeight: negrita ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }
}
