import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
      String? urlFotoCloud = cuadre.fotoZarpeUrl;

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

      // Subida de Fotos de Zarpe de Cámara si son archivos locales
      if (urlFotoCloud != null && urlFotoCloud.isNotEmpty) {
        final paths = urlFotoCloud.split(',');
        final List<String> urlsSubidas = [];
        for (int i = 0; i < paths.length; i++) {
          final path = paths[i].trim();
          if (path.isEmpty) continue;
          if (path.startsWith('http')) {
            urlsSubidas.add(path);
          } else {
            try {
              final file = File(path);
              if (await file.exists()) {
                final ext = path.split('.').last;
                final nombreArchivo = '${cuadre.usuarioId}/${cuadre.id}_zarpe_$i.$ext';
                
                await _cliente.storage.from('camaras-zarpes').upload(
                  nombreArchivo,
                  file,
                  fileOptions: const sb.FileOptions(upsert: true),
                );
                final publicUrl = _cliente.storage.from('camaras-zarpes').getPublicUrl(nombreArchivo);
                urlsSubidas.add(publicUrl);
              }
            } catch (e) {
              debugPrint('Error subiendo foto $i de zarpe a Supabase: $e');
              urlsSubidas.add(path); // Mantener ruta original para reintento
            }
          }
        }
        urlFotoCloud = urlsSubidas.join(',');
      }

      // 2. Insertar Cabecera (Cuadre)
      final cuadreJson = cuadre.toJson();
      cuadreJson['url_pdf_cloud'] = urlPdfCloud;
      cuadreJson['url_excel_cloud'] = urlExcelCloud;
      cuadreJson['foto_zarpe_url'] = urlFotoCloud;
      await _cliente.from('cuadres').upsert(cuadreJson);

      // 3. Insertar Relaciones (Compras, Gastos, Ventas)
      // Primero borramos las relaciones existentes para evitar huérfanos
      await Future.wait([
        _cliente.from('compras').delete().eq('cuadre_id', cuadre.id),
        _cliente.from('gastos').delete().eq('cuadre_id', cuadre.id),
        _cliente.from('ventas').delete().eq('cuadre_id', cuadre.id),
      ]);

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
        'urlFoto': urlFotoCloud,
      };
    } catch (e) {
      throw ExcepcionRed(mensaje: 'Error sincronizando cuadre con Supabase: $e');
    }
  }
}
