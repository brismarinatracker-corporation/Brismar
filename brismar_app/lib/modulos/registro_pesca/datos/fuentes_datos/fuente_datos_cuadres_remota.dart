import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../modelos/cuadre_modelo.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
// import '../../../../nucleo/utilidades/gestor_pdf.dart';
// import '../../../../nucleo/utilidades/gestor_excel.dart';

/// Fuente de datos remota para subir cuadres y reportes a Supabase.
class FuenteDatosCuadresRemota {
  final sb.SupabaseClient _cliente;

  /// Constructor de [FuenteDatosCuadresRemota].
  FuenteDatosCuadresRemota(this._cliente);

  /// Sube un cuadre completo a Supabase de forma transaccional/lógica.
  Future<Map<String, String?>> subirCuadre(CuadreModelo cuadre) async {
    try {
      final String? urlFotoCloud = await _procesarYSubirFotosZarpe(
        cuadre.fotoZarpeUrl, 
        cuadre.id, 
        cuadre.usuarioId,
      );

      final cuadreJson = cuadre.toJson();
      cuadreJson['url_pdf_cloud'] = null; // temporal
      cuadreJson['url_excel_cloud'] = null; // temporal
      cuadreJson['foto_zarpe_url'] = urlFotoCloud;
      await _cliente.from('cuadres').upsert(cuadreJson);

      await _eliminarRelacionesAnteriores(cuadre.id);
      await _subirRelaciones(cuadre);

      return {
        'urlPdf': null,
        'urlExcel': null,
        'urlFoto': urlFotoCloud,
      };
    } catch (e) {
      throw ExcepcionRed(mensaje: 'Error sincronizando cuadre con Supabase: $e');
    }
  }

  /// Procesa y sube todas las fotos locales de un zarpe de cámara.
  Future<String?> _procesarYSubirFotosZarpe(String? urlFotoCloud, String cuadreId, String usuarioId) async {
    if (urlFotoCloud == null || urlFotoCloud.isEmpty) return null;
    final paths = urlFotoCloud.split(',');
    final List<String> urlsSubidas = [];
    for (int i = 0; i < paths.length; i++) {
      final path = paths[i].trim();
      if (path.isEmpty) continue;
      if (path.startsWith('http')) {
        urlsSubidas.add(path);
      } else {
        final publicUrl = await _subirFotoUnica(path, cuadreId, usuarioId, i);
        if (publicUrl != null) urlsSubidas.add(publicUrl);
      }
    }
    return urlsSubidas.isEmpty ? null : urlsSubidas.join(',');
  }

  /// Sube una foto única al almacenamiento seguro de Supabase.
  Future<String?> _subirFotoUnica(String path, String cuadreId, String usuarioId, int indice) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final ext = path.split('.').last;
        final nombreArchivo = '$usuarioId/${cuadreId}_zarpe_$indice.$ext';
        await _cliente.storage.from('camaras-zarpes').upload(
          nombreArchivo,
          file,
          fileOptions: const sb.FileOptions(upsert: true),
        );
        return _cliente.storage.from('camaras-zarpes').getPublicUrl(nombreArchivo);
      }
    } catch (e) {
      debugPrint('Error subiendo foto $indice de zarpe a Supabase: $e');
    }
    return path;
  }

  /// Elimina las relaciones anteriores para evitar duplicados o huérfanos.
  Future<void> _eliminarRelacionesAnteriores(String cuadreId) async {
    await Future.wait([
      _cliente.from('compras').delete().eq('cuadre_id', cuadreId),
      _cliente.from('gastos').delete().eq('cuadre_id', cuadreId),
      _cliente.from('ventas').delete().eq('cuadre_id', cuadreId),
    ]);
  }

  /// Sube de forma masiva (upsert) las compras, gastos y ventas de un cuadre.
  Future<void> _subirRelaciones(CuadreModelo cuadre) async {
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
  }
}
