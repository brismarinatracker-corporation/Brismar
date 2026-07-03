import 'package:bcrypt/bcrypt.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Servicio centralizado de cifrado para toda la aplicación.
///
/// Sigue las directrices del Manifiesto BiPenc (Motor Ironclad) y las reglas
/// globales de Clean Code (funciones de menos de 20 líneas con DartDoc).
class ServicioCifrado {
  /// Genera un hash usando el algoritmo BCrypt.
  ///
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

  /// Cifra una cadena utilizando el algoritmo AES-256-CBC.
  ///
  /// Toma el [textoPlano] y aplica cifrado usando la [clave] y el [vectorInicializacion].
  static String cifrarAes(
    String textoPlano,
    String clave,
    String vectorInicializacion,
  ) {
    final key = enc.Key.fromUtf8(clave.padRight(32).substring(0, 32));
    final iv = enc.IV.fromUtf8(
      vectorInicializacion.padRight(16).substring(0, 16),
    );
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(textoPlano, iv: iv).base64;
  }

  /// Descifra una cadena en base64 utilizando el algoritmo AES-256-CBC.
  ///
  /// Toma el [textoCifradoBase64] y aplica descifrado usando la [clave] y el [vectorInicializacion].
  static String descifrarAes(
    String textoCifradoBase64,
    String clave,
    String vectorInicializacion,
  ) {
    final key = enc.Key.fromUtf8(clave.padRight(32).substring(0, 32));
    final iv = enc.IV.fromUtf8(
      vectorInicializacion.padRight(16).substring(0, 16),
    );
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt64(textoCifradoBase64, iv: iv);
  }
}
