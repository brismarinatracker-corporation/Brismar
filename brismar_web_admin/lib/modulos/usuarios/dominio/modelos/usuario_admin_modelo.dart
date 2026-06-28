class UsuarioAdminModelo {
  final String uid;
  final String dni;
  final String correo;
  final String nombre;
  final String rol;
  final String sede;
  final bool activo;
  final String? fotoPerfil;
  final DateTime? fechaNacimiento;

  UsuarioAdminModelo({
    required this.uid,
    required this.dni,
    required this.correo,
    required this.nombre,
    required this.rol,
    required this.sede,
    required this.activo,
    this.fotoPerfil,
    this.fechaNacimiento,
  });

  factory UsuarioAdminModelo.desdeJson(Map<String, dynamic> json) {
    return UsuarioAdminModelo(
      uid: json['id']?.toString() ?? json['uid']?.toString() ?? '',
      dni: json['dni'] ?? '',
      correo: json['correo'] ?? '', 
      nombre: json['nombre_real'] ?? json['nombre'] ?? '',
      rol: json['rol'] ?? 'operario',
      sede: json['bahia'] ?? json['sede'] ?? 'Piura',
      activo: json['activo'] ?? true,
      fotoPerfil: json['foto_perfil'],
      fechaNacimiento: json['fecha_nacimiento'] != null ? DateTime.tryParse(json['fecha_nacimiento']) : null,
    );
  }

  Map<String, dynamic> aJson() {
    return {
      'uid': uid,
      'dni': dni,
      'correo': correo,
      'nombre': nombre,
      'rol': rol,
      'sede': sede,
      'activo': activo,
      'foto_perfil': fotoPerfil,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
    };
  }

  UsuarioAdminModelo copiarCon({
    String? uid,
    String? dni,
    String? correo,
    String? nombre,
    String? rol,
    String? sede,
    bool? activo,
    String? fotoPerfil,
    DateTime? fechaNacimiento,
  }) {
    return UsuarioAdminModelo(
      uid: uid ?? this.uid,
      dni: dni ?? this.dni,
      correo: correo ?? this.correo,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      sede: sede ?? this.sede,
      activo: activo ?? this.activo,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
    );
  }
}
