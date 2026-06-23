import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Utilidad para verificar si el dispositivo tiene acceso real a red de datos o WiFi.
class VerificadorConexion {
  static final Connectivity _connectivity = Connectivity();

  /// Retorna `true` si hay conexión a internet disponible de forma real,
  /// o `false` de lo contrario.
  static Future<bool> hayConexion() async {
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    // Ping real para evitar falsos positivos de conectividad
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
  }
}
