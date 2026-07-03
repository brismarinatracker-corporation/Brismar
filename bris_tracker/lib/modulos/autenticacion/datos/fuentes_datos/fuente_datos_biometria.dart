import 'package:local_auth/local_auth.dart';

/// Fuente de datos para la autenticación biométrica del dispositivo.
///
/// Cubre el nodo [Task_ProvideBiometrics] y [Gateway_BiometricCheck]
/// del FLUJO_01_AUTENTICACION.bpmn.
class FuenteDatosBiometria {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Verifica si el dispositivo tiene biometría disponible y configurada.
  Future<bool> esBiometriaDisponible() async {
    try {
      final disponible = await _auth.canCheckBiometrics;
      final soportado = await _auth.isDeviceSupported();
      return disponible && soportado;
    } catch (e) {
      throw Exception('Error al verificar disponibilidad biométrica: $e');
    }
  }

  /// Obtiene los tipos de biometría disponibles en el dispositivo.
  Future<List<BiometricType>> obtenerTiposBiometria() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      throw Exception('Error al obtener tipos de biometría: $e');
    }
  }

  /// Solicita autenticación biométrica al usuario (huella digital).
  ///
  /// Retorna `true` si la huella fue válida y aceptada.
  /// Retorna `false` si el usuario canceló o la huella no coincidió.
  Future<bool> autenticarConHuella() async {
    try {
      final disponible = await esBiometriaDisponible();
      if (!disponible) return false;

      return await _auth.authenticate(
        localizedReason: 'Presenta tu huella digital para acceder a BRISMAR',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      // En lugar de lanzar excepción que crashea el flujo, retornamos false
      // para que el usuario pueda usar el PIN como alternativa.
      return false;
    }
  }
}
