import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../modelos/registro_modelo.dart';
import '../../../../nucleo/red/cliente_supabase.dart';

import '../../../../nucleo/errores/diccionario_errores.dart';
import 'dart:async';

/// Fuente de datos remota para gestionar registros en Supabase.
/// Sigue el principio de Responsabilidad Única (SRP).
class FuenteDatosRegistroRemota {
  final sb.SupabaseClient _client = sb.Supabase.instance.client;

  /// Sube un lote de registros a Supabase mediante una operación de bulk upsert.
  Future<void> subirRegistros(List<RegistroModelo> registros) async {
    // Si no está configurada la URL de Supabase, simulamos éxito para desarrollo local
    if (ConfiguracionSupabase.url.contains('tu-proyecto-supabase')) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      final cargasUtiles = registros.map((r) => r.toJson()).toList();
      // Usamos upsert para evitar duplicados en caso de reintentos
      await _client
          .from('registro_embarcaciones')
          .upsert(cargasUtiles)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ExcepcionApp('NET-002', mensajeTecnico: 'Timeout al subir registros');
    } catch (e) {
      throw ExcepcionApp('DB-001', mensajeTecnico: 'Error al subir registros a Supabase: $e');
    }
  }

  /// Obtiene todos los registros guardados en la nube de Supabase.
  Future<List<RegistroModelo>> obtenerHistorialRemoto() async {
    if (ConfiguracionSupabase.url.contains('tu-proyecto-supabase')) {
      return [];
    }

    try {
      final List<dynamic> response = await _client
          .from('registro_embarcaciones')
          .select()
          .order('fecha', ascending: false)
          .order('hora', ascending: false)
          .timeout(const Duration(seconds: 10));

      return response.map((json) => RegistroModelo.fromJson(json)).toList();
    } on TimeoutException {
      throw const ExcepcionApp('NET-002', mensajeTecnico: 'Timeout al descargar historial');
    } catch (e) {
      throw ExcepcionApp('DB-002', mensajeTecnico: 'Error al descargar historial remoto: $e');
    }
  }
}
