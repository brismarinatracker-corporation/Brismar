import '../entidades/usuario.dart';

/// Contrato abstracto para la gestión de la autenticación de usuarios.
///
/// Cubre todos los nodos del FLUJO_01_AUTENTICACION.bpmn:
/// - Login completo online/offline
/// - Periodo de gracia 1 min
/// - Configuración y verificación de PIN
/// - Autenticación biométrica
/// - Invalidación de bóveda ("Olvidé PIN")
///
/// Sigue el principio SOLID de Abierto/Cerrado (OCP).
abstract class RepositorioAutenticacion {
  /// Realiza el inicio de sesión completo (correo + contraseña).
  ///
  /// Gestiona la bifurcación online/offline según el BPMN.
  /// Lanza una excepción con mensaje claro si hay algún error.
  Future<Usuario> iniciarSesion({
    required String usuario,
    required String password,
  });

  /// Cierra la sesión activa del usuario e invalida la bóveda completa.
  Future<void> cerrarSesion();

  /// Obtiene el usuario actualmente autenticado, validando el periodo de gracia.
  ///
  /// Retorna `null` si no hay sesión.
  /// Lanza [SesionExpiradaException] si el token existe pero la gracia de 1 min expiró.
  Future<Usuario?> obtenerUsuarioActual();

  /// Guarda el PIN hasheado en la bóveda tras el primer login exitoso.
  Future<void> configurarPin(String pin);

  /// Verifica el PIN ingresado contra el hash guardado en la bóveda.
  ///
  /// Si es correcto, actualiza el timestamp de verificación.
  /// Retorna `true` si el PIN coincide.
  Future<bool> verificarPin(String pin);

  /// Autentica al usuario mediante biometría del dispositivo.
  ///
  /// Si es exitoso, actualiza el timestamp de verificación.
  /// Retorna `true` si la huella fue válida.
  Future<bool> verificarBiometria();

  /// Guarda la preferencia de acceso rápido del usuario (PIN o Huella).
  Future<void> guardarPreferenciaAcceso(String preferencia);

  /// Invalida token, PIN y hash offline — ejecutado al "Olvidé PIN".
  ///
  /// Obliga al usuario a realizar un login completo nuevamente.
  Future<void> invalidarPinYToken();

  /// Obtiene los datos de perfil más recientes de un usuario.
  ///
  /// Si está online los trae de Supabase y los persiste en local;
  /// si está offline los lee de la caché local.
  Future<Usuario> obtenerPerfilActualizado(String id);
}

/// Excepción lanzada cuando el token existe pero el periodo de gracia de 1 min expiró.
class SesionExpiradaException implements Exception {
  /// Mensaje descriptivo de la excepción.
  final String mensaje;

  /// Constructor de [SesionExpiradaException].
  const SesionExpiradaException([
    this.mensaje =
        'Periodo de gracia expirado. Se requiere verificación rápida.',
  ]);

  @override
  String toString() => 'SesionExpiradaException: $mensaje';
}
