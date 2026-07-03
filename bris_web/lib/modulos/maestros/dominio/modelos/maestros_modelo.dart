class EspecieModelo {
  final String id;
  final String nombre;

  const EspecieModelo({required this.id, required this.nombre});

  factory EspecieModelo.desdeJson(Map<String, dynamic> json) {
    return EspecieModelo(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
    );
  }
}

class TipoGastoModelo {
  final String id;
  final String nombre;

  const TipoGastoModelo({required this.id, required this.nombre});

  factory TipoGastoModelo.desdeJson(Map<String, dynamic> json) {
    return TipoGastoModelo(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
    );
  }
}
