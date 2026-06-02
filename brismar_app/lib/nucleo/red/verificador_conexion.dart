import 'package:connectivity_plus/connectivity_plus.dart';

/// Utilidad para verificar si el dispositivo tiene acceso a red de datos o WiFi.
class VerificadorConexion {
  static final Connectivity _connectivity = Connectivity();

  /// Retorna `true` si hay conexión a internet disponible, `false` de lo contrario.
  static Future<bool> hayConexion() async {
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();

    // Si la lista contiene none, no hay conexión (según conectivity_plus reciente devuelve una lista).
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    return connectivityResult.isNotEmpty;
  }
}
