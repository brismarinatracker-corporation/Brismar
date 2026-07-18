import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gestor de almacenamiento seguro para tokens y credenciales sensibles.
///
/// Implementa el patrón Singleton. Cubre todos los datos de la Bóveda
/// definidos en el FLUJO_01_AUTENTICACION.bpmn:
/// - Token de sesión
/// - Hash BCrypt de contraseña (offline)
/// - PIN hasheado (acceso rápido diario)
/// - Timestamp de última verificación (periodo de gracia 1 min para pruebas)
/// - Preferencia de acceso rápido (pin | huella)
class GestorAlmacenamientoSeguro {
  static final GestorAlmacenamientoSeguro instance =
      GestorAlmacenamientoSeguro._init();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  GestorAlmacenamientoSeguro._init();

  // ─── Claves de la Bóveda ─────────────────────────────────────────────────
  static const String _keyToken = 'auth_token';
  static const String _keyOfflineHash = 'offline_password_hash';
  static const String _keyOfflineUser = 'offline_user_data';
  static const String _keyPin = 'acceso_rapido_pin_hash';
  static const String _keyTimestamp = 'ultima_verificacion_timestamp';
  static const String _keyPreferenciaAcceso = 'preferencia_acceso_rapido';

  // ─── Token ────────────────────────────────────────────────────────────────

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

  /// Elimina el token de sesión.
  Future<void> eliminarToken() async {
    try {
      await _storage.delete(key: _keyToken);
    } catch (e) {
      throw Exception('Error al eliminar el token de forma segura: $e');
    }
  }

  // ─── Credenciales Offline (Hash Contraseña + Datos Usuario) ─────────────

  /// Guarda el hash BCrypt de la contraseña y los datos del usuario para modo offline.
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

  /// Obtiene el hash BCrypt de la contraseña guardada offline.
  Future<String?> obtenerHashOffline() async {
    return await _storage.read(key: _keyOfflineHash);
  }

  /// Obtiene los datos del usuario en formato JSON guardados offline.
  Future<String?> obtenerDatosUsuarioOffline() async {
    return await _storage.read(key: _keyOfflineUser);
  }

  // ─── PIN de Acceso Rápido ─────────────────────────────────────────────────

  /// Persiste el hash BCrypt del PIN de acceso rápido diario.
  Future<void> guardarPin(String pinHash) async {
    try {
      await _storage.write(key: _keyPin, value: pinHash);
    } catch (e) {
      throw Exception('Error al guardar el PIN en la bóveda: $e');
    }
  }

  /// Obtiene el hash BCrypt del PIN guardado.
  Future<String?> obtenerPin() async {
    try {
      return await _storage.read(key: _keyPin);
    } catch (e) {
      throw Exception('Error al leer el PIN de la bóveda: $e');
    }
  }

  /// Elimina el hash del PIN de la bóveda.
  Future<void> eliminarPin() async {
    try {
      await _storage.delete(key: _keyPin);
    } catch (e) {
      throw Exception('Error al eliminar el PIN de la bóveda: $e');
    }
  }

  // ─── Timestamp de Verificación (Periodo de Gracia 1 min) ───────────────────

  /// Guarda el timestamp Unix (ms) de la última verificación exitosa.
  Future<void> guardarTimestamp() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      await _storage.write(key: _keyTimestamp, value: now);
    } catch (e) {
      throw Exception('Error al guardar el timestamp de verificación: $e');
    }
  }

  /// Obtiene el timestamp Unix (ms) de la última verificación.
  Future<DateTime?> obtenerTimestamp() async {
    try {
      final raw = await _storage.read(key: _keyTimestamp);
      if (raw == null) return null;
      // Usamos tryParse para protegernos de valores corruptos en SecureStorage.
      // Si el valor no es parseable, lo tratamos como "sin timestamp".
      final ms = int.tryParse(raw);
      if (ms == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (e) {
      throw Exception('Error al leer el timestamp de verificación: $e');
    }
  }

  /// Verifica si el periodo de gracia (12 horas) sigue vigente.
  Future<bool> esPeriodoGraciaVigente() async {
    final ultima = await obtenerTimestamp();
    if (ultima == null) return false;
    final diferencia = DateTime.now().difference(ultima);
    return diferencia.inHours < 12;
  }

  // ─── Preferencia de Acceso Rápido ────────────────────────────────────────

  /// Persiste la preferencia de acceso rápido ('pin' o 'huella').
  Future<void> guardarPreferenciaAcceso(String preferencia) async {
    try {
      await _storage.write(key: _keyPreferenciaAcceso, value: preferencia);
    } catch (e) {
      throw Exception('Error al guardar preferencia de acceso: $e');
    }
  }

  /// Obtiene la preferencia de acceso rápido guardada.
  Future<String?> obtenerPreferenciaAcceso() async {
    try {
      return await _storage.read(key: _keyPreferenciaAcceso);
    } catch (e) {
      throw Exception('Error al leer preferencia de acceso: $e');
    }
  }

  // ─── Invalidación (Task_ClearSession BPMN) ───────────────────────────────

  /// Invalida completamente la bóveda al seleccionar "Olvidé mi PIN".
  ///
  /// Decisión de negocio: si el usuario olvidó el PIN, necesita hacer login
  /// completo con internet. Al re-autenticarse, el hash offline se regenera
  /// automáticamente. No tiene sentido conservar datos obsoletos.
  /// Borra todos los datos: token, PIN, hash offline, timestamp y preferencia.
  Future<void> invalidarAccesoRapido() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Error al invalidar el acceso rápido: $e');
    }
  }

  /// Invalida la bóveda completa (logout explícito del usuario).
  ///
  /// Borra todos los datos: token, PIN, hash de contraseña, timestamp y preferencia.
  /// Se ejecuta cuando el usuario cierra sesión de forma voluntaria.
  Future<void> invalidarBoveda() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Error al invalidar la bóveda de seguridad: $e');
    }
  }
}
