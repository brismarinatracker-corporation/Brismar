import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show InternetAddress, SocketException;

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

    // En plataforma Web dart:io no es soportado, por lo que devolvemos true si hay interfaz activa
    if (kIsWeb) {
      return true;
    }

    // Ping real para evitar falsos positivos de conectividad (solo móvil/desktop nativo)
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

