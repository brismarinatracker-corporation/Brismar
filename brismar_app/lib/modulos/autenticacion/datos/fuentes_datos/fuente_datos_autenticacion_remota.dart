import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:package_info_plus/package_info_plus.dart';
import '../../dominio/entidades/usuario.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
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
        throw const ExcepcionApp(
          'AUTH-001',
          mensajeTecnico: 'El servidor no devolvió información del usuario.',
        );
      }

      // Guardamos la versión actual de la app en los metadatos del usuario
      try {
        final info = await PackageInfo.fromPlatform();
        await _client.auth.updateUser(sb.UserAttributes(
          data: {'app_version': info.version},
        ));
      } catch (_) {
        // Ignorar fallo de versión para no bloquear el login
      }

      // Consultamos el rol y nombre real en la tabla 'usuarios'.
      // maybeSingle() retorna null en vez de PGRST116 si el perfil aún no existe.
      final userDetails = await _client
          .from('usuarios')
          .select('nombre_real, rol')
          .eq('id', user.id)
          .maybeSingle();

      return Usuario(
        id: user.id,
        nombreUsuario: user.email ?? correo,
        nombreReal: userDetails?['nombre_real'] ?? 'Usuario Brismar',
        rol: userDetails?['rol'] ?? 'bahia',
      );
    } on ExcepcionApp {
      rethrow;
    } on sb.AuthException catch (e) {
      throw ExcepcionApp(
        'AUTH-001',
        mensajeTecnico: 'AuthException de Supabase: ${e.message}',
        causa: e,
      );
    } catch (e, stack) {
      throw ExcepcionApp(
        'NET-002',
        mensajeTecnico: 'Error de red al iniciar sesión.',
        causa: e,
        stackTrace: stack,
      );
    }
  }

  /// Cierra la sesión activa en el servidor de Supabase.
  Future<void> cerrarSesion() async {
    if (ConfiguracionSupabase.url.contains('tu-proyecto-supabase')) return;
    try {
      await _client.auth.signOut();
    } catch (e, stack) {
      throw ExcepcionApp(
        'NET-002',
        mensajeTecnico: 'Error al cerrar sesión remota.',
        causa: e,
        stackTrace: stack,
      );
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
    throw const ExcepcionApp(
      'AUTH-001',
      mensajeTecnico: 'Credenciales incorrectas (Modo Simulación).',
    );
  }
}
