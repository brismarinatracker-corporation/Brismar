class Producto {
  final String id;
  final String nombre;
  final String? descripcion;
  final bool estadoActivo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estadoActivo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      estadoActivo: json['estado_activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'estado_activo': estadoActivo,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Producto copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? estadoActivo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      estadoActivo: estadoActivo ?? this.estadoActivo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
