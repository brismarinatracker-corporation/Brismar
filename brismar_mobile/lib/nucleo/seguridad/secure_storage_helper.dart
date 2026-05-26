import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gestor de almacenamiento seguro para tokens y credenciales sensibles.
/// Implementa el patrón Singleton.
class SecureStorageHelper {
  static final SecureStorageHelper instance = SecureStorageHelper._init();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SecureStorageHelper._init();

  static const String _keyToken = 'auth_token';

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
    } catch (e) {
      throw Exception('Error al eliminar el token de forma segura: $e');
    }
  }
}
