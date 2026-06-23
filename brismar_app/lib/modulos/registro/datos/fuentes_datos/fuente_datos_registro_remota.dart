import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../modelos/registro_modelo.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
import '../../../../nucleo/red/cliente_supabase.dart';

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
      final registrosSinUsuario = registros.where(
        (registro) => registro.usuarioId.trim().isEmpty,
      );
      if (registrosSinUsuario.isNotEmpty) {
        throw const ExcepcionApp(
          'NET-003',
          mensajeTecnico:
              'El lote contiene registros sin usuario_id para aplicar RLS.',
        );
      }

      final payloads = registros.map((r) => r.toJson()).toList();
      // Usamos upsert para evitar duplicados en caso de reintentos
      await _client.from('registro_embarcaciones').upsert(payloads);
    } on ExcepcionApp {
      rethrow;
    } catch (e, stack) {
      throw ExcepcionApp(
        'NET-003',
        mensajeTecnico: 'Error al subir registros a Supabase.',
        causa: e,
        stackTrace: stack,
      );
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
          .order('hora', ascending: false);

      return response.map((json) => RegistroModelo.fromJson(json)).toList();
    } catch (e, stack) {
      throw ExcepcionApp(
        'NET-003',
        mensajeTecnico: 'Error al descargar historial remoto.',
        causa: e,
        stackTrace: stack,
      );
    }
  }
}
