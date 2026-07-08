import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';
import '../../dominio/modelos/cuadre_web_modelo.dart';

class HojaLiquidacionExcel extends StatelessWidget {
  final CuadreWebModelo cuadre;
  final NumberFormat fmt;

  const HojaLiquidacionExcel({
    super.key,
    required this.cuadre,
    required this.fmt,
  });

  // Colores del Excel original
  static const Color colorCelesteCabecera = Color(0xFFB4C6E7);
  static const Color colorCelesteTabla = Color(0xFFD9E1F2);
  static const Color colorAmarillo = Color(0xFFFFFF00);
  static const Color colorVerdeSeparador = Color(0xFFC6E0B4);
  static const Color colorAzulOscuro = Color(0xFF203764);
  static const Color colorNaranjaClaro = Color(0xFFFCE4D6);
  static const Color colorBorde = Color(0xFF000000);

  // Clasificación de Gastos
  List<GastoWebModelo> get gastosAdministrativos {
    return cuadre.gastos.where((g) {
      if (g.tipo == 'Administrativo') return true;
      
      // Por si hay registros antiguos sin el tipo correcto
      final c = g.concepto.toUpperCase().trim();
      return c == 'FACTURACION_PLANTA' ||
             c == 'PESADOR_PLANTA' ||
             c == 'GASTOS FINANCIEROS' ||
             c == 'CERTIFICADO' ||
             c == 'LIQUIDACION' ||
             c == 'IMPUESTO DE RENTA';
    }).toList();
  }

  List<GastoWebModelo> get gastosMuelle {
    return cuadre.gastos.where((g) => !gastosAdministrativos.contains(g)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Totales
    final double totalCompra = cuadre.totalCompras;
    final double totalVenta = cuadre.totalVentas;
    
    final double totalGastosMuelle = gastosMuelle.fold(0.0, (s, g) => s + g.total);
    final double totalGastosAdmin = gastosAdministrativos.fold(0.0, (s, g) => s + g.total);

    final double kilosCompra = cuadre.compras.fold(0.0, (s, c) => s + c.kilos);
    final double kilosVenta = cuadre.ventas.fold(0.0, (s, v) => s + v.kilos);
    final double rendimientoKilos = kilosVenta - kilosCompra;

    // Resumen y Utilidades (Matemática corregida)
    final double utilidadBruta = totalVenta - totalCompra;
    final double utilidadOperativa = utilidadBruta - totalGastosMuelle;
    final double utilidadAntesReparto = utilidadOperativa - totalGastosAdmin;
    // Asumimos 0 para utilidad de terceros por defecto
    const double utilidadTerceros = 0.0; 
    final double utilidadNeta = utilidadAntesReparto - utilidadTerceros;
    
    final double margen = totalVenta > 0 ? (utilidadNeta / totalVenta) : 0.0;
    final double repartoEmpresa = utilidadNeta * 0.50;
    final double repartoDaniel = utilidadNeta * 0.50;

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
                // PANEL IZQUIERDO (COMPRAS, VENTAS, GASTOS, RESUMEN)
                SizedBox(
                  width: 650,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirCabeceraPrincipal(),
                      const SizedBox(height: 16),
                      _construirTablaCompras(totalCompra),
                      const SizedBox(height: 16),
                      _construirTablaVentas(totalVenta),
                      const SizedBox(height: 16),
                      _construirRendimiento(rendimientoKilos),
                      const SizedBox(height: 24),
                      
                      // Contenedor de Gastos y Resumen alineados
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Columna de Gastos (Muelle y Administrativos)
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
                          // Columna de Resumen y Reparto
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
                      ),
                    ],
                  ),
                ),
                
                // SEPARADOR VERDE
                Container(
                  width: 40,
                  height: 600,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorVerdeSeparador,
                    border: Border.all(color: colorBorde, width: 0.5),
                  ),
                ),

                // PANEL DERECHO (UTILIDADES Y MARGEN)
                SizedBox(
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Componentes de UI ──────────────────────────────────────────────────────

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

  Widget _construirTablaCompras(double totalCompra) {
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
            TableRow(
              children: [
                _celdaCabecera('FECHA'),
                _celdaCabecera('EMBARCACION'),
                _celdaCabecera('PRODUCTO'),
                _celdaCabecera('KILOS'),
                _celdaCabecera('PRECIO'),
                _celdaCabecera('TOTAL'),
              ]
            ),
            for (var c in cuadre.compras)
              TableRow(
                children: [
                  _celdaDato(cuadre.fechaZarpe != null ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaZarpe!) ?? DateTime.now()).toUpperCase() : ''),
                  _celdaDato(c.embarcacion),
                  _celdaDato(c.producto),
                  _celdaNumero(c.kilos),
                  _celdaNumero(c.precioUnitario),
                  _celdaNumero(c.total),
                ]
              ),
            TableRow(
              children: [
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                _celdaNumero(cuadre.compras.fold(0.0, (s, c) => s + c.kilos), negrita: true),
                const SizedBox.shrink(),
                _celdaNumero(totalCompra, negrita: true),
              ]
            ),
          ],
        ),
      ],
    );
  }

  Widget _construirTablaVentas(double totalVenta) {
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
            TableRow(
              children: [
                _celdaCabecera('FECHA'),
                _celdaCabecera('LUGAR'),
                _celdaCabecera('PRODUCTO'),
                _celdaCabecera('KILOS'),
                _celdaCabecera('PRECIO'),
                _celdaCabecera('TOTAL'),
              ]
            ),
            for (var v in cuadre.ventas)
              TableRow(
                children: [
                  _celdaDato(cuadre.fechaCuadre != null ? DateFormat('dd-MMM').format(DateTime.tryParse(cuadre.fechaCuadre!) ?? DateTime.now()).toUpperCase() : ''),
                  _celdaDato(v.lugar),
                  _celdaDato(v.producto),
                  _celdaNumero(v.kilos),
                  _celdaNumero(v.precioUnitario),
                  _celdaNumero(v.total),
                ]
              ),
            TableRow(
              children: [
                _celdaDato('TOTAL VENTA', negrita: true),
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                _celdaNumero(cuadre.ventas.fold(0.0, (s, v) => s + v.kilos), negrita: true),
                const SizedBox.shrink(),
                _celdaNumero(totalVenta, negrita: true),
              ]
            ),
          ],
        ),
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
            TableRow(
              children: [
                _celdaCabecera('DETALLE'),
                _celdaCabecera('IMPORTE'),
              ]
            ),
            for (var g in gastos)
              TableRow(
                children: [
                  _celdaDato(g.concepto),
                  _celdaNumero(g.total),
                ]
              ),
            TableRow(
              children: [
                _celdaCabecera('TOTAL', alineacion: Alignment.centerLeft),
                _celdaNumero(total, negrita: true),
              ]
            ),
          ],
        ),
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
        TableRow(
          decoration: const BoxDecoration(color: colorAzulOscuro),
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text('RESUMEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const SizedBox.shrink(),
          ]
        ),
        TableRow(
          children: [
            _celdaDato('(1) VENTA', negrita: true),
            _celdaNumero(v),
          ]
        ),
        TableRow(
          children: [
            _celdaDato('(2) COMPRA', negrita: true),
            _celdaNumero(-c),
          ]
        ),
        TableRow(
          children: [
            _celdaDato('(3) GASTOS MUELLE', negrita: true),
            _celdaNumero(-gm),
          ]
        ),
        TableRow(
          children: [
            _celdaDato('(4) GASTOS ADMINISTRATIVO', negrita: true),
            _celdaNumero(-ga),
          ]
        ),
        TableRow(
          children: [
            _celdaDato('TOTAL', negrita: true),
            _celdaNumero(neta, negrita: true),
          ]
        ),
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
