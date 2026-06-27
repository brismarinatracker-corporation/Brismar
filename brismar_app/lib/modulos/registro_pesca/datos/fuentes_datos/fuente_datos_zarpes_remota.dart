import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../modelos/zarpe_modelo.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';

class FuenteDatosZarpesRemota {
  final sb.SupabaseClient _cliente;

  FuenteDatosZarpesRemota(this._cliente);

  Future<void> subirZarpe(ZarpeModelo zarpe) async {
    try {
      String urlFotoFinal = zarpe.fotoUrlEvidencia;

      // 1. Si la url de la foto está vacía o es una ruta local, debemos subirla a Storage
      if (zarpe.fotoLocalPath != null && zarpe.fotoLocalPath!.isNotEmpty) {
        final file = File(zarpe.fotoLocalPath!);
        if (await file.exists()) {
          final ext = zarpe.fotoLocalPath!.split('.').last;
          final userId = _cliente.auth.currentUser?.id ?? 'desconocido';
          final nombreArchivo = '$userId/${zarpe.id}_zarpe.$ext';
          
          await _cliente.storage.from('camaras-zarpes').upload(
            nombreArchivo,
            file,
            fileOptions: const sb.FileOptions(upsert: true),
          );
          
          urlFotoFinal = _cliente.storage.from('camaras-zarpes').getPublicUrl(nombreArchivo);
        }
      }

      // 2. Insertar/Actualizar en base de datos PostgreSQL
      final zarpeJson = zarpe.toJsonSupabase();
      zarpeJson['foto_url_evidencia'] = urlFotoFinal;
      zarpeJson['creado_por'] = _cliente.auth.currentUser?.id;
      
      await _cliente.from('zarpes').upsert(zarpeJson);
      
    } catch (e) {
      debugPrint('Error en FuenteDatosZarpesRemota: $e');
      throw Exception('No se pudo subir a Supabase: $e');
    }
  }
}
