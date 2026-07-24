import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dominio/modelos/usuario_admin_modelo.dart';

class FuenteDatosUsuariosAdmin {
  final SupabaseClient _supabaseClient;

  FuenteDatosUsuariosAdmin(this._supabaseClient);

  Future<List<UsuarioAdminModelo>> obtenerUsuarios() async {
    try {
      // Obtenemos los usuarios desde nuestra tabla pública que se sincroniza con Auth
      final response = await _supabaseClient
          .from('usuarios')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => UsuarioAdminModelo.desdeJson(e))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  Future<void> crearUsuario(UsuarioAdminModelo usuario, String password) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'admin_usuarios',
        body: {
          'action': 'create_user',
          'payload': {
            'email': usuario.correo,
            'password': password,
            'nombre': usuario.nombre,
            'dni': usuario.dni,
            'rol': usuario.rol,
            'sede': usuario.sede,
            'foto_perfil': usuario.fotoPerfil,
            'fecha_nacimiento': usuario.fechaNacimiento?.toIso8601String(),
          },
        },
      );

      if (response.status != 200) {
        throw Exception(
          response.data['error'] ?? 'Error desconocido en Edge Function',
        );
      }
    } catch (e) {
      throw Exception('No se pudo crear el usuario: $e');
    }
  }

  Future<void> actualizarUsuario(
    UsuarioAdminModelo usuario, {
    String? nuevaPassword,
  }) async {
    try {
      final payload = {
        'uid': usuario.uid,
        'email': usuario.correo,
        'nombre': usuario.nombre,
        'dni': usuario.dni,
        'rol': usuario.rol,
        'sede': usuario.sede,
        'foto_perfil': usuario.fotoPerfil,
        'fecha_nacimiento': usuario.fechaNacimiento?.toIso8601String(),
      };

      if (nuevaPassword != null && nuevaPassword.isNotEmpty) {
        payload['password'] = nuevaPassword;
      }

      final response = await _supabaseClient.functions.invoke(
        'admin_usuarios',
        body: {'action': 'update_user', 'payload': payload},
      );

      if (response.status != 200) {
        throw Exception(
          response.data['error'] ?? 'Error al actualizar usuario',
        );
      }
    } catch (e) {
      throw Exception('No se pudo actualizar el usuario: $e');
    }
  }

  Future<void> alternarEstadoUsuario(String uid, bool activar) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'admin_usuarios',
        body: {
          'action': activar ? 'enable_user' : 'disable_user',
          'payload': {'uid': uid},
        },
      );

      if (response.status != 200) {
        throw Exception(
          response.data['error'] ?? 'Error al cambiar estado del usuario',
        );
      }
    } catch (e) {
      throw Exception('No se pudo cambiar el estado del usuario: $e');
    }
  }

  Future<void> eliminarUsuario(String uid) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'admin_usuarios',
        body: {
          'action': 'delete_user',
          'payload': {'uid': uid},
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Error al eliminar usuario');
      }
    } catch (e) {
      throw Exception('No se pudo eliminar el usuario: $e');
    }
  }

  /// Sube un avatar al bucket "avatars" y devuelve la URL pública.
  Future<String> subirAvatar(
    String idUnico,
    dynamic archivoBytes,
    String extension,
  ) async {
    try {
      final ruta = 'avatar_$idUnico.$extension';
      await _supabaseClient.storage
          .from('avatars')
          .uploadBinary(
            ruta,
            archivoBytes,
            fileOptions: const FileOptions(
              upsert: true,
              cacheControl: '3600',
            ),
          );
      final urlPublica = _supabaseClient.storage
          .from('avatars')
          .getPublicUrl(ruta);
      // Evitar cache del navegador añadiendo un timestamp
      return '$urlPublica?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('No se pudo subir la foto de perfil: $e');
    }
  }
}
