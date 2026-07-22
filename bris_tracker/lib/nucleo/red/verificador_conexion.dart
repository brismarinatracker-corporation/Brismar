import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Contrato para verificar la conectividad.
/// Permite inyectar dependencias y realizar pruebas unitarias (Mocks).
abstract class VerificadorConexion {
  Future<bool> hayConexion();
}

/// Implementación real que usa connectivity_plus y http ping.
class VerificadorConexionImpl implements VerificadorConexion {
  final Connectivity _connectivity;

  VerificadorConexionImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> hayConexion() async {
    final List<ConnectivityResult> connectivityResult = await _connectivity
        .checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    // Ping real para evitar falsos positivos de conectividad.
    try {
      final response = await http
          .head(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode == 200 ||
          response.statusCode == 301 ||
          response.statusCode == 302;
    } catch (_) {
      if (kIsWeb) return true;
      return false;
    }
  }
}
