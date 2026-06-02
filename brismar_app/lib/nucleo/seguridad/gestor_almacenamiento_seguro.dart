import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gestor de almacenamiento seguro para tokens y credenciales sensibles.
/// Implementa el patrón Singleton.
class GestorAlmacenamientoSeguro {
  static final GestorAlmacenamientoSeguro instance =
      GestorAlmacenamientoSeguro._init();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  GestorAlmacenamientoSeguro._init();

  static const String _keyToken = 'auth_token';
  static const String _keyOfflineHash = 'offline_password_hash';
  static const String _keyOfflineUser = 'offline_user_data';

  /// Guarda el token de sesión en el almacenamiento seguro.
  Future<void> guardarToken(String token) async {
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (e) {
      throw Exception('Error al guardar el token de forma segura: $e');
    }
  }

  /// Obtiene el token de sesión guardado.
  Future<String?> obtenerToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      throw Exception('Error al leer el token de forma segura: $e');
    }
  }

  /// Elimina el token de sesión (Cerrar Sesión).
  Future<void> eliminarToken() async {
    try {
      await _storage.delete(key: _keyToken);
      // Opcional: También borrar datos offline al cerrar sesión explícitamente,
      // pero usualmente se conservan por si vuelve a fallar la red. Dependerá de las reglas de negocio.
    } catch (e) {
      throw Exception('Error al eliminar el token de forma segura: $e');
    }
  }

  /// Guarda el hash de la contraseña y los datos del usuario para modo offline
  Future<void> guardarCredencialesOffline(
    String hash,
    String userDataJson,
  ) async {
    try {
      await _storage.write(key: _keyOfflineHash, value: hash);
      await _storage.write(key: _keyOfflineUser, value: userDataJson);
    } catch (e) {
      throw Exception('Error al guardar credenciales offline: $e');
    }
  }

  /// Obtiene el hash guardado de la contraseña
  Future<String?> obtenerHashOffline() async {
    return await _storage.read(key: _keyOfflineHash);
  }

  /// Obtiene los datos del usuario en formato JSON guardados offline
  Future<String?> obtenerDatosUsuarioOffline() async {
    return await _storage.read(key: _keyOfflineUser);
  }
}
