import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import '../dominio/modelos/cuadre_web_modelo.dart';

class ServicioExportacionPdf {
  static Future<void> exportar(CuadreWebModelo cuadre) async {
    try {
    final pdf = pw.Document();
    final fmt = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

    List<GastoWebModelo> gastosAdmin = cuadre.gastos.where((g) {
      if (g.tipo == 'Administrativo') return true;
      final c = g.concepto.toUpperCase().trim();
      return c == 'FACTURACION_PLANTA' ||
          c == 'PESADOR_PLANTA' ||
          c == 'GASTOS FINANCIEROS' ||
          c == 'CERTIFICADO' ||
          c == 'LIQUIDACION' ||
          c == 'IMPUESTO DE RENTA';
    }).toList();

    List<GastoWebModelo> gastosMuelle = cuadre.gastos
        .where((g) => !gastosAdmin.contains(g) && g.concepto.toUpperCase().trim() != 'OBSERVACIONES')
        .toList();

    double totalCompra = cuadre.totalCompras;
    double totalVenta = cuadre.totalVentas;
    double totalGastosMuelle = gastosMuelle.fold(0.0, (s, g) => s + g.total);
    double totalGastosAdmin = gastosAdmin.fold(0.0, (s, g) => s + g.total);
    double kilosCompra = cuadre.compras.fold(0.0, (s, c) => s + c.kilos);
    double kilosVenta = cuadre.ventas.fold(0.0, (s, v) => s + v.kilos);
    double rendimientoKilos = kilosVenta - kilosCompra;
    double utilidadBruta = totalVenta - totalCompra;
    double utilidadOperativa = utilidadBruta - totalGastosMuelle;
    double utilidadAntesReparto = utilidadOperativa - totalGastosAdmin;
    double utilidadTerceros = 0.0;
    double utilidadNeta = utilidadAntesReparto - utilidadTerceros;
    double margen = totalVenta > 0 ? (utilidadNeta / totalVenta) : 0.0;

    final colorCelesteCabecera = PdfColor.fromHex('#B4C6E7');
    final colorCelesteTabla = PdfColor.fromHex('#D9E1F2');
    final colorAmarillo = PdfColor.fromHex('#FFFF00');
    final colorAzulOscuro = PdfColor.fromHex('#203764');
    final colorNaranjaClaro = PdfColor.fromHex('#FCE4D6');

    pw.Widget celda(String texto, {PdfColor? bgColor, pw.FontWeight? weight, pw.TextAlign align = pw.TextAlign.center, PdfColor? fontColor}) {
      return pw.Container(
        color: bgColor,
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          texto,
          textAlign: align,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: weight,
            color: fontColor ?? PdfColors.black,
          ),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('MUELLE ${cuadre.muellePartida ?? cuadre.plantaDestino ?? ''}', bgColor: colorCelesteCabecera, weight: pw.FontWeight.bold),
                              celda('PLACA ${cuadre.placa}', bgColor: colorCelesteCabecera, weight: pw.FontWeight.bold),
                              celda('CAJAS', bgColor: colorCelesteCabecera, weight: pw.FontWeight.bold),
                              celda('${cuadre.cajasLlenas ?? 0}', bgColor: colorCelesteCabecera, weight: pw.FontWeight.bold),
                            ]
                          )
                        ]
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(color: colorCelesteTabla, padding: const pw.EdgeInsets.all(4), child: pw.Text('COMPRA', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('FECHA', weight: pw.FontWeight.bold),
                              celda('EMBARCACION', weight: pw.FontWeight.bold),
                              celda('PRODUCTO', weight: pw.FontWeight.bold),
                              celda('KILOS', weight: pw.FontWeight.bold),
                              celda('PRECIO', weight: pw.FontWeight.bold),
                              celda('TOTAL', weight: pw.FontWeight.bold),
                            ]
                          ),
                          ...cuadre.compras.map((c) {
                            final fechaStr = cuadre.fechaZarpe ?? cuadre.fechaCuadre;
                            final fecha = fechaStr != null ? DateFormat('dd-MMM').format(DateTime.tryParse(fechaStr) ?? DateTime.now()).toUpperCase() : DateFormat('dd-MMM').format(DateTime.now()).toUpperCase();
                            return pw.TableRow(
                              children: [
                                celda(fecha),
                                celda(c.embarcacion),
                                celda(c.producto),
                                celda(c.kilos.toStringAsFixed(2), align: pw.TextAlign.right),
                                celda(fmt.format(c.precioUnitario), align: pw.TextAlign.right),
                                celda(fmt.format(c.total), align: pw.TextAlign.right),
                              ]
                            );
                          }),
                          pw.TableRow(
                            children: [
                              celda(''), celda(''), celda(''), 
                              celda(kilosCompra.toStringAsFixed(2), align: pw.TextAlign.right, weight: pw.FontWeight.bold), 
                              celda(''), 
                              celda(fmt.format(totalCompra), align: pw.TextAlign.right, weight: pw.FontWeight.bold),
                            ]
                          )
                        ]
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(color: colorCelesteTabla, padding: const pw.EdgeInsets.all(4), child: pw.Text('VENTA', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('FECHA', weight: pw.FontWeight.bold),
                              celda('LUGAR', weight: pw.FontWeight.bold),
                              celda('PRODUCTO', weight: pw.FontWeight.bold),
                              celda('KILOS', weight: pw.FontWeight.bold),
                              celda('PRECIO', weight: pw.FontWeight.bold),
                              celda('TOTAL', weight: pw.FontWeight.bold),
                            ]
                          ),
                          ...cuadre.ventas.map((v) {
                            final fechaStr = cuadre.fechaCuadre ?? cuadre.fechaZarpe;
                            final fecha = fechaStr != null ? DateFormat('dd-MMM').format(DateTime.tryParse(fechaStr) ?? DateTime.now()).toUpperCase() : DateFormat('dd-MMM').format(DateTime.now()).toUpperCase();
                            return pw.TableRow(
                              children: [
                                celda(fecha),
                                celda(v.lugar),
                                celda(v.producto),
                                celda(v.kilos.toStringAsFixed(2), align: pw.TextAlign.right),
                                celda(fmt.format(v.precioUnitario), align: pw.TextAlign.right),
                                celda(fmt.format(v.total), align: pw.TextAlign.right),
                              ]
                            );
                          }),
                          pw.TableRow(
                            children: [
                              celda('TOTAL VENTA', align: pw.TextAlign.right, weight: pw.FontWeight.bold),
                              celda(''), celda(''), 
                              celda(kilosVenta.toStringAsFixed(2), align: pw.TextAlign.right, weight: pw.FontWeight.bold), 
                              celda(''), 
                              celda(fmt.format(totalVenta), align: pw.TextAlign.right, weight: pw.FontWeight.bold),
                            ]
                          )
                        ]
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('RENDIMIENTO', bgColor: colorAmarillo, weight: pw.FontWeight.bold),
                              celda(rendimientoKilos.toStringAsFixed(2), bgColor: colorAmarillo, weight: pw.FontWeight.bold, align: pw.TextAlign.right),
                            ]
                          )
                        ]
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(color: colorCelesteTabla, padding: const pw.EdgeInsets.all(4), child: pw.Text('GASTOS MUELLE', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('DETALLE', weight: pw.FontWeight.bold),
                              celda('IMPORTE', weight: pw.FontWeight.bold),
                            ]
                          ),
                          ...gastosMuelle.map((g) => pw.TableRow(
                            children: [
                              celda(g.concepto, align: pw.TextAlign.left),
                              celda(fmt.format(g.total), align: pw.TextAlign.right),
                            ]
                          )),
                          pw.TableRow(
                            children: [
                              celda('TOTAL', weight: pw.FontWeight.bold, align: pw.TextAlign.right),
                              celda(fmt.format(totalGastosMuelle), weight: pw.FontWeight.bold, align: pw.TextAlign.right),
                            ]
                          )
                        ]
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(color: colorCelesteTabla, padding: const pw.EdgeInsets.all(4), child: pw.Text('GASTOS ADMINISTRATIVO', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('DETALLE', weight: pw.FontWeight.bold),
                              celda('IMPORTE', weight: pw.FontWeight.bold),
                            ]
                          ),
                          ...gastosAdmin.map((g) => pw.TableRow(
                            children: [
                              celda(g.concepto, align: pw.TextAlign.left),
                              celda(fmt.format(g.total), align: pw.TextAlign.right),
                            ]
                          )),
                          pw.TableRow(
                            children: [
                              celda('TOTAL', weight: pw.FontWeight.bold, align: pw.TextAlign.right),
                              celda(fmt.format(totalGastosAdmin), weight: pw.FontWeight.bold, align: pw.TextAlign.right),
                            ]
                          )
                        ]
                      ),
                    ]
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('MARGEN', bgColor: colorNaranjaClaro, weight: pw.FontWeight.bold),
                              celda('${(margen * 100).toStringAsFixed(2)}%', bgColor: colorNaranjaClaro, weight: pw.FontWeight.bold, align: pw.TextAlign.right),
                            ]
                          )
                        ]
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(children: [celda('UTILIDAD BRUTA', bgColor: colorAmarillo, weight: pw.FontWeight.bold), celda(fmt.format(utilidadBruta), bgColor: colorAmarillo, align: pw.TextAlign.right, weight: pw.FontWeight.bold)]),
                          pw.TableRow(children: [celda('UTILIDAD OPERATIVA', bgColor: colorAmarillo, weight: pw.FontWeight.bold), celda(fmt.format(utilidadOperativa), bgColor: colorAmarillo, align: pw.TextAlign.right, weight: pw.FontWeight.bold)]),
                          pw.TableRow(children: [celda('UT. ANTES DE REPARTO', bgColor: colorAmarillo, weight: pw.FontWeight.bold), celda(fmt.format(utilidadAntesReparto), bgColor: colorAmarillo, align: pw.TextAlign.right, weight: pw.FontWeight.bold)]),
                          pw.TableRow(children: [celda('UTILIDAD DE TERCEROS', weight: pw.FontWeight.bold), celda(fmt.format(utilidadTerceros), align: pw.TextAlign.right, weight: pw.FontWeight.bold)]),
                          pw.TableRow(children: [celda('UTILIDAD NETA', bgColor: colorAmarillo, weight: pw.FontWeight.bold), celda(fmt.format(utilidadNeta), bgColor: colorAmarillo, align: pw.TextAlign.right, weight: pw.FontWeight.bold)]),
                        ]
                      ),
                      pw.SizedBox(height: 20),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              celda('RESUMEN', bgColor: colorAzulOscuro, fontColor: PdfColors.white, weight: pw.FontWeight.bold),
                              celda('', bgColor: colorAzulOscuro),
                            ]
                          ),
                          pw.TableRow(children: [celda('(1) VENTA'), celda(fmt.format(totalVenta), align: pw.TextAlign.right)]),
                          pw.TableRow(children: [celda('(2) COMPRA'), celda(fmt.format(-totalCompra), align: pw.TextAlign.right)]),
                          pw.TableRow(children: [celda('(3) GASTOS MUELLE'), celda(fmt.format(-totalGastosMuelle), align: pw.TextAlign.right)]),
                          pw.TableRow(children: [celda('(4) GASTOS ADMINISTRATIVO'), celda(fmt.format(-totalGastosAdmin), align: pw.TextAlign.right)]),
                          pw.TableRow(children: [celda('TOTAL', weight: pw.FontWeight.bold, align: pw.TextAlign.right), celda(fmt.format(totalVenta - totalCompra - totalGastosMuelle - totalGastosAdmin), weight: pw.FontWeight.bold, align: pw.TextAlign.right)]),
                        ]
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(children: [celda('50%'), celda('EMPRESA'), celda(fmt.format(utilidadNeta * 0.5), align: pw.TextAlign.right)]),
                          pw.TableRow(children: [celda('50%'), celda((cuadre.nombreBahia?.trim().isNotEmpty == true) ? 'BAHÍA ${cuadre.nombreBahia!.toUpperCase()}' : 'BAHÍA'), celda(fmt.format(utilidadNeta * 0.5), align: pw.TextAlign.right)]),
                          pw.TableRow(children: [celda('TOTAL', weight: pw.FontWeight.bold, align: pw.TextAlign.right), celda(''), celda(fmt.format(utilidadNeta), weight: pw.FontWeight.bold, align: pw.TextAlign.right)]),
                        ]
                      ),
                    ]
                  )
                )
              ]
            )
          ];
        },
      )
    );

    final bytes = await pdf.save();
    await FileSaver.instance.saveFile(
      name: 'Cuadre_${cuadre.placa}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      bytes: bytes,
      mimeType: MimeType.pdf,
    );
    } catch (e) {
      print('Error exporting PDF: $e');
    }
  }
}
