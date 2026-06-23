import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../dominio/entidades/usuario.dart';
import '../../../../nucleo/red/cliente_supabase.dart';

/// Fuente de datos remota para la autenticación en Supabase.
class FuenteDatosAutenticacionRemota {
  final sb.SupabaseClient _client = sb.Supabase.instance.client;

  /// Inicia sesión usando Supabase. Si la URL es la de plantilla,
  /// simula el inicio de sesión para facilitar las pruebas locales.
  Future<Usuario> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    // Si no está configurada la URL real de Supabase, activamos simulación de pruebas
    if (ConfiguracionSupabase.url.contains('tu-proyecto-supabase')) {
      return _iniciarSesionSimulado(correo, password);
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: correo,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('El servidor no devolvió información del usuario.');
      }

      // Consultamos el rol y nombre real en la tabla de base de datos 'usuarios'
      final userDetails = await _client
          .from('usuarios')
          .select('nombre_real, rol')
          .eq('id', user.id)
          .single();

      return Usuario(
        id: user.id,
        nombreUsuario: user.email ?? correo,
        nombreReal: userDetails['nombre_real'] ?? 'Usuario Brismar',
        rol: userDetails['rol'] ?? 'bahia',
      );
    } on sb.AuthException catch (e) {
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      throw Exception('Error de red al iniciar sesión: $e');
    }
  }

  /// Cierra la sesión activa en el servidor de Supabase.
  Future<void> cerrarSesion() async {
    if (ConfiguracionSupabase.url.contains('tu-proyecto-supabase')) return;
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión remota: $e');
    }
  }

  /// Simulación del login para testing/pruebas locales.
  Future<Usuario> _iniciarSesionSimulado(String correo, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simula latencia
    final correoLower = correo.toLowerCase().trim();
    
    if ((correoLower == 'daniel@brismar.com.pe' || correoLower == 'daniel' || correoLower == 'usuario') &&
        password == '1234') {
      return const Usuario(
        id: 'mock-uuid-daniel',
        nombreUsuario: 'daniel@brismar.com.pe',
        nombreReal: 'Daniel',
        rol: 'bahia',
      );
    } else if ((correoLower == 'jim@brismar.com.pe' || correoLower == 'jim') &&
        password == '1234') {
      return const Usuario(
        id: 'mock-uuid-jim',
        nombreUsuario: 'jim@brismar.com.pe',
        nombreReal: 'Jim',
        rol: 'bahia',
      );
    }
    throw Exception('Usuario o contraseña incorrectos (Modo Simulación)');
  }
}
