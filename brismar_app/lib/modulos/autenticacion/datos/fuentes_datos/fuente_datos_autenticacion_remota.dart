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

      await _guardarVersionAppSilencioso();
      final userDetails = await obtenerDetallesUsuario(user.id);

      return Usuario(
        id: user.id,
        nombreUsuario: user.email ?? correo,
        nombreReal: userDetails?['nombre_real'] ?? 'Usuario Brismar',
        rol: userDetails?['rol'] ?? 'bahia',
        sede: userDetails?['sede'] ?? 'Piura',
        fotoPerfil: userDetails?['foto_perfil'],
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

  /// Guarda de forma silenciosa la versión de la aplicación en Supabase.
  Future<void> _guardarVersionAppSilencioso() async {
    try {
      final info = await PackageInfo.fromPlatform();
      await _client.auth.updateUser(sb.UserAttributes(
        data: {'app_version': info.version},
      ));
    } catch (_) {
      // Ignorar fallo de versión para no bloquear el login
    }
  }

  /// Obtiene los detalles extendidos (nombre real y rol) del usuario.
  Future<Map<String, dynamic>?> obtenerDetallesUsuario(String id) async {
    return await _client
        .from('usuarios')
        .select('nombre_real, rol, foto_perfil, sede')
        .eq('id', id)
        .maybeSingle()
        .timeout(const Duration(seconds: 10));
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

  /// Verifica de forma sincrónica si la sesión remota sigue siendo válida.
  /// Si el usuario fue eliminado, esto retornará false (depende del refresh token background).
  bool get esSesionValida {
    return _client.auth.currentUser != null;
  }
}
