import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:package_info_plus/package_info_plus.dart';
import '../../dominio/entidades/usuario.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
import 'dart:async';

/// Fuente de datos remota para la autenticación en Supabase.
class FuenteDatosAutenticacionRemota {
  final sb.SupabaseClient _client = sb.Supabase.instance.client;

  /// Inicia sesión usando Supabase.
  Future<Usuario> iniciarSesion({
    required String correo,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: correo,
        password: password,
      ).timeout(const Duration(seconds: 10));

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
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

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
    } on TimeoutException {
      throw const ExcepcionApp(
        'NET-002',
        mensajeTecnico: 'Timeout al iniciar sesión.',
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
}
