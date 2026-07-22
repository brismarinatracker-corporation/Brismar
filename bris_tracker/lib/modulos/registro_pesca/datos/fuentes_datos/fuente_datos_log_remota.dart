import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/log_zarpe_modelo.dart';

/// Fuente de datos remota para el sistema de auditoría de zarpes.
///
/// Encargada de enviar los logs a Supabase.
class FuenteDatosLogRemota {
  /// Instancia de cliente Supabase.
  final _supabase = Supabase.instance.client;

  /// Envía un log a la tabla [zarpe_log] en Supabase.
  ///
  /// Lanza excepción si falla.
  Future<void> sincronizarLog(LogZarpeModelo log) async {
    try {
      await _supabase.from('zarpe_log').insert(log.toSupabase());
    } catch (e) {
      throw Exception('Error al sincronizar log en Supabase: $e');
    }
  }
}
