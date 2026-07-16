class Camara {
  final String id;
  final String placa;
  final String? chofer;
  final String? marca;
  final double? capacidadKg;
  final bool estadoActivo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Camara({
    required this.id,
    required this.placa,
    this.chofer,
    this.marca,
    this.capacidadKg,
    required this.estadoActivo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Camara.fromJson(Map<String, dynamic> json) {
    return Camara(
      id: json['id'] as String,
      placa: json['placa'] as String,
      chofer: json['chofer'] as String?,
      marca: json['marca'] as String?,
      capacidadKg: json['capacidad_kg'] != null
          ? (json['capacidad_kg'] as num).toDouble()
          : null,
      estadoActivo: json['estado_activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placa': placa.toUpperCase(),
      'chofer': chofer,
      'marca': marca,
      'capacidad_kg': capacidadKg,
      'estado_activo': estadoActivo,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Camara copyWith({
    String? id,
    String? placa,
    String? chofer,
    String? marca,
    double? capacidadKg,
    bool? estadoActivo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Camara(
      id: id ?? this.id,
      placa: placa ?? this.placa,
      chofer: chofer ?? this.chofer,
      marca: marca ?? this.marca,
      capacidadKg: capacidadKg ?? this.capacidadKg,
      estadoActivo: estadoActivo ?? this.estadoActivo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
