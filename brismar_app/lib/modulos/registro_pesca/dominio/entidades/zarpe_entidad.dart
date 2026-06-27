class ZarpeEntidad {
  final String id;
  final String placaCamara;
  final String chofer;
  final String muellePartida;
  final String fotoUrlEvidencia;
  final String? fotoLocalPath;
  final DateTime fechaZarpe;
  final String estado;

  ZarpeEntidad({
    required this.id,
    required this.placaCamara,
    required this.chofer,
    required this.muellePartida,
    required this.fotoUrlEvidencia,
    this.fotoLocalPath,
    required this.fechaZarpe,
    required this.estado,
  });

  ZarpeEntidad copyWith({
    String? id,
    String? placaCamara,
    String? chofer,
    String? muellePartida,
    String? fotoUrlEvidencia,
    String? fotoLocalPath,
    DateTime? fechaZarpe,
    String? estado,
  }) {
    return ZarpeEntidad(
      id: id ?? this.id,
      placaCamara: placaCamara ?? this.placaCamara,
      chofer: chofer ?? this.chofer,
      muellePartida: muellePartida ?? this.muellePartida,
      fotoUrlEvidencia: fotoUrlEvidencia ?? this.fotoUrlEvidencia,
      fotoLocalPath: fotoLocalPath ?? this.fotoLocalPath,
      fechaZarpe: fechaZarpe ?? this.fechaZarpe,
      estado: estado ?? this.estado,
    );
  }
}
