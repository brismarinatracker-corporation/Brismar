import '../entidades/usuario.dart';

/// Contrato abstracto para la gestión de la autenticación de usuarios.
/// Sigue el principio SOLID de Abierto/Cerrado (OCP).
abstract class RepositorioAutenticacion {
  /// Realiza el inicio de sesión del usuario.
  /// Lanza una excepción con un mensaje claro si ocurre algún error.
  Future<Usuario> iniciarSesion({
    required String usuario,
    required String password,
  });

  /// Cierra la sesión activa del usuario.
  Future<void> cerrarSesion();

  /// Obtiene los detalles del usuario actualmente autenticado (si lo hay).
  Future<Usuario?> obtenerUsuarioActual();
}
