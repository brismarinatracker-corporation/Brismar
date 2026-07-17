import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Clase para inicializar y gestionar la conexión directa con Supabase.
class ConfiguracionSupabase {
  /// URL de tu proyecto Supabase.
  static String get url =>
      dotenv.env['SUPABASE_URL'] ?? 'https://tu-proyecto-supabase.supabase.co';

  /// Llave pública anónima (anon key) de Supabase.
  static String get anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
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
