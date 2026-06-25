import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

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

    // Ping real para evitar falsos positivos de conectividad. Funciona en Web, Android, iOS.
    try {
      final response = await http.head(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302;
    } catch (_) {
      // kIsWeb como fallback si la validación estricta falla por CORS u otros motivos web
      if (kIsWeb) return true;
      return false;
    }
  }
}

