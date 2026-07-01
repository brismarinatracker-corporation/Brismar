import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../modelos/zarpe_modelo.dart';

class FuenteDatosZarpesRemota {
  final sb.SupabaseClient _cliente;

  FuenteDatosZarpesRemota(this._cliente);

  /// Sube un zarpe de cámara a Supabase, incluyendo la subida de su foto de evidencia.
  Future<void> subirZarpe(ZarpeModelo zarpe) async {
    try {
      final String urlFotoFinal = await _subirFotoZarpeSegura(zarpe);

      final zarpeJson = zarpe.toJsonSupabase();
      zarpeJson['foto_url_evidencia'] = urlFotoFinal;
      zarpeJson['creado_por'] = _cliente.auth.currentUser?.id;
      
      await _cliente.from('zarpes').upsert(zarpeJson);
    } catch (e) {
      debugPrint('Error en FuenteDatosZarpesRemota: $e');
      throw Exception('No se pudo subir a Supabase: $e');
    }
  }

  /// Sube de forma segura el archivo local de la foto de evidencia al Storage si existe.
  Future<String> _subirFotoZarpeSegura(ZarpeModelo zarpe) async {
    if (zarpe.fotoLocalPath != null && zarpe.fotoLocalPath!.isNotEmpty) {
      final paths = zarpe.fotoLocalPath!.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      final List<String> urlsSubidas = [];

      for (int i = 0; i < paths.length; i++) {
        final path = paths[i];
        final file = File(path);
        if (await file.exists()) {
          final ext = path.split('.').last;
          final userId = _cliente.auth.currentUser?.id ?? 'desconocido';
          final nombreArchivo = '$userId/${zarpe.id}_zarpe_$i.$ext';
          
          try {
            await _cliente.storage.from('camaras-zarpes').upload(
              nombreArchivo,
              file,
              fileOptions: const sb.FileOptions(upsert: true),
            );
            
            final publicUrl = _cliente.storage.from('camaras-zarpes').getPublicUrl(nombreArchivo);
            urlsSubidas.add(publicUrl);
          } catch (e) {
            debugPrint('Error subiendo foto $i: $e');
            if (path.startsWith('http')) {
              urlsSubidas.add(path);
            }
          }
        } else if (path.startsWith('http')) {
          urlsSubidas.add(path);
        }
      }

      if (urlsSubidas.isNotEmpty) {
        return urlsSubidas.join(',');
      }
    }
    return zarpe.fotoUrlEvidencia;
  }

  /// Obtiene los zarpes que han sido actualizados en la base de datos central desde una fecha dada.
  Future<List<Map<String, dynamic>>> obtenerZarpesActualizados(DateTime desde) async {
    try {
      final respuesta = await _cliente
          .from('zarpes')
          .select()
          .gte('updated_at', desde.toIso8601String())
          .order('updated_at', ascending: true);
      
      return List<Map<String, dynamic>>.from(respuesta);
    } catch (e) {
      debugPrint('Error obteniendo zarpes actualizados: $e');
      return [];
    }
  }
}
