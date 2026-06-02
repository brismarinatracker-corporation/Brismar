import 'package:supabase_flutter/supabase_flutter.dart';

/// Clase para inicializar y gestionar la conexión directa con Supabase.
class ConfiguracionSupabase {
  /// URL de tu proyecto Supabase.
  static const String url = 'https://tu-proyecto-supabase.supabase.co';

  /// Llave pública anónima (anon key) de Supabase.
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.placeholder';

  /// Inicializa el cliente global de Supabase.
  /// Lanza una excepción detallada en caso de fallar.
  static Future<void> inicializar() async {
    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
    } catch (e) {
      throw Exception('Error al conectar con Supabase: $e');
    }
  }
}
