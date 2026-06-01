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

  /// Crea un [Usuario] a partir de un mapa JSON.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nombreUsuario: json['nombreUsuario'] as String,
      nombreReal: json['nombreReal'] as String,
      rol: json['rol'] as String,
    );
  }

  /// Convierte el [Usuario] a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreUsuario': nombreUsuario,
      'nombreReal': nombreReal,
      'rol': rol,
    };
  }
}
