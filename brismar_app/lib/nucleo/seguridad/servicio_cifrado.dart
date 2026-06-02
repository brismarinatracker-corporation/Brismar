import 'package:bcrypt/bcrypt.dart';

/// Servicio centralizado de cifrado para toda la aplicación.
/// Sigue las directrices del Manifiesto BiPenc (Motor Ironclad).
class ServicioCifrado {
  /// Genera un hash usando el algoritmo BCrypt.
  /// Ideal para contraseñas, PINes de administradores y guardado offline seguro.
  static String hashearPasswordBcrypt(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  /// Verifica si una contraseña plana coincide con el hash generado por BCrypt.
  static bool verificarPasswordBcrypt(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } catch (_) {
      return false; // Evita crashear si el hash tiene formato incorrecto
    }
  }

  // TODO: Agregar en el futuro métodos AES-256-CBC para cifrado de bases locales en SQLite
}
