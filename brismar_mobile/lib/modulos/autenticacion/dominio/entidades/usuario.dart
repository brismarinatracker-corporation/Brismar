/// Representa al usuario autenticado en la aplicación.
class Usuario {
  /// Identificador único del usuario (UUID de Supabase).
  final String id;

  /// Nombre de usuario / correo electrónico utilizado para el login.
  final String nombreUsuario;

  /// Nombre real completo del usuario.
  final String nombreReal;

  /// Rol asignado al usuario (ej: 'bahia', 'administrador').
  final String rol;

  /// Constructor principal de la entidad [Usuario].
  const Usuario({
    required this.id,
    required this.nombreUsuario,
    required this.nombreReal,
    required this.rol,
  });
}
