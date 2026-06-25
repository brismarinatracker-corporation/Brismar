import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:async';
import '../modelos/cuadre_modelo.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
// import '../../../../nucleo/utilidades/gestor_pdf.dart';
// import '../../../../nucleo/utilidades/gestor_excel.dart';

class FuenteDatosCuadresRemota {
  final sb.SupabaseClient _cliente;

  FuenteDatosCuadresRemota(this._cliente);

  Future<Map<String, String?>> subirCuadre(CuadreModelo cuadre) async {
    try {
      String? urlPdfCloud;
      String? urlExcelCloud;

      // 1. TODO: Generar archivos y subirlos al Storage (comentado hasta adaptar los gestores)
      /*
      final archivoPdf = await GestorPdf.generarPdf(cuadre);
      final archivoExcel = await GestorExcel.generarExcel(cuadre);

      final nombreBase = '${cuadre.usuarioId}/${cuadre.placa}_${DateTime.now().millisecondsSinceEpoch}';

      await _cliente.storage.from('reportes').upload('$nombreBase.pdf', archivoPdf, fileOptions: const sb.FileOptions(upsert: true));
      await _cliente.storage.from('reportes').upload('$nombreBase.xlsx', archivoExcel, fileOptions: const sb.FileOptions(upsert: true));

      urlPdfCloud = _cliente.storage.from('reportes').getPublicUrl('$nombreBase.pdf');
      urlExcelCloud = _cliente.storage.from('reportes').getPublicUrl('$nombreBase.xlsx');
      */

      // 2. Insertar Cabecera (Cuadre)
      final cuadreJson = cuadre.toJson();
      cuadreJson['url_pdf_cloud'] = urlPdfCloud;
      cuadreJson['url_excel_cloud'] = urlExcelCloud;
      await _cliente.from('cuadres').upsert(cuadreJson);

      // 3. Insertar Relaciones (Compras, Gastos, Ventas)
      if (cuadre.compras.isNotEmpty) {
        await _cliente.from('compras').upsert(cuadre.compras.map((c) {
          final cModelo = c is CompraModelo ? c : CompraModelo.fromEntidad(c);
          return cModelo.toJson();
        }).toList());
      }

      if (cuadre.gastos.isNotEmpty) {
        await _cliente.from('gastos').upsert(cuadre.gastos.map((g) {
          final gModelo = g is GastoModelo ? g : GastoModelo.fromEntidad(g);
          return gModelo.toJson();
        }).toList());
      }

      if (cuadre.ventas.isNotEmpty) {
        await _cliente.from('ventas').upsert(cuadre.ventas.map((v) {
          final vModelo = v is VentaModelo ? v : VentaModelo.fromEntidad(v);
          return vModelo.toJson();
        }).toList());
      }

      return {
        'urlPdf': urlPdfCloud,
        'urlExcel': urlExcelCloud,
      };
    } catch (e) {
      throw ExcepcionRed(mensaje: 'Error sincronizando cuadre con Supabase: $e');
    }
  }
}
