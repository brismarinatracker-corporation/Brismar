class ZarpeModelo {
  final String id;
  final String placaCamara;
  final String chofer;
  final String muellePartida;
  final String fotoUrlEvidencia; // Supabase public URL
  final String? fotoLocalPath;   // Local path para Offline
  final DateTime fechaZarpe;
  final String estado; // 'pendiente', 'sincronizado'

  ZarpeModelo({
    required this.id,
    required this.placaCamara,
    required this.chofer,
    required this.muellePartida,
    required this.fotoUrlEvidencia,
    this.fotoLocalPath,
    required this.fechaZarpe,
    required this.estado,
  });

  factory ZarpeModelo.fromMap(Map<String, dynamic> map) {
    return ZarpeModelo(
      id: map['id'] ?? '',
      placaCamara: map['placa_camara'] ?? '',
      chofer: map['chofer'] ?? '',
      muellePartida: map['muelle_partida'] ?? '',
      fotoUrlEvidencia: map['foto_url_evidencia'] ?? '',
      fotoLocalPath: map['foto_local_path'],
      fechaZarpe: map['fecha_zarpe'] != null 
          ? DateTime.parse(map['fecha_zarpe']) 
          : DateTime.now(),
      estado: map['estado'] ?? 'sincronizado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placa_camara': placaCamara,
      'chofer': chofer,
      'muelle_partida': muellePartida,
      'foto_url_evidencia': fotoUrlEvidencia,
      'foto_local_path': fotoLocalPath,
      'fecha_zarpe': fechaZarpe.toIso8601String(),
      'estado': estado,
    };
  }

  // To Postgres Supabase (Sin foto_local_path ni estado, la DB lo ignora o los descarta)
  Map<String, dynamic> toJsonSupabase() {
    return {
      'id': id,
      'placa_camara': placaCamara,
      'chofer': chofer,
      'muelle_partida': muellePartida,
      'foto_url_evidencia': fotoUrlEvidencia,
      'fecha_zarpe': fechaZarpe.toIso8601String(),
    };
  }
}
