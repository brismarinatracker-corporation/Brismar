/// Modelo de datos para un Zarpe de cámara frigorífica.
///
/// Separa el [estado] de negocio (DESPACHADO_PIURA, RECIBIDO_LAMBAYEQUE)
/// del indicador de sincronización [sincronizado] (0 = pendiente, 1 = en Supabase).
class ZarpeModelo {
  final String id;
  final String placaCamara;
  final String chofer;
  final String muellePartida;
  final String fotoUrlEvidencia;
  final String? fotoLocalPath;
  final DateTime fechaZarpe;

  /// Estado de negocio: 'DESPACHADO_PIURA' | 'RECIBIDO_LAMBAYEQUE'
  final String estado;

  /// 0 = no sincronizado con Supabase, 1 = ya existe en Supabase.
  final int sincronizado;

  ZarpeModelo({
    required this.id,
    required this.placaCamara,
    required this.chofer,
    required this.muellePartida,
    required this.fotoUrlEvidencia,
    this.fotoLocalPath,
    required this.fechaZarpe,
    this.estado = 'DESPACHADO_PIURA',
    this.sincronizado = 0,
  });

  /// Construye un [ZarpeModelo] desde un [Map] de SQLite.
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
      estado: map['estado'] ?? 'DESPACHADO_PIURA',
      sincronizado: (map['sincronizado'] as int?) ?? 0,
    );
  }

  /// Construye un [ZarpeModelo] a partir de una [ZarpeEntidad].
  factory ZarpeModelo.fromEntidad(dynamic entidad) {
    return ZarpeModelo(
      id: entidad.id,
      placaCamara: entidad.placaCamara,
      chofer: entidad.chofer,
      muellePartida: entidad.muellePartida,
      fotoUrlEvidencia: entidad.fotoUrlEvidencia,
      fotoLocalPath: entidad.fotoLocalPath,
      fechaZarpe: entidad.fechaZarpe,
      estado: entidad.estado,
      sincronizado: 0, // Por defecto no sincronizado
    );
  }

  /// Serializa para INSERT/UPDATE en SQLite local.
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
      'sincronizado': sincronizado,
    };
  }

  /// Serializa solo los campos necesarios para Supabase (sin datos locales).
  Map<String, dynamic> toJsonSupabase() {
    return {
      'id': id,
      'placa_camara': placaCamara,
      'chofer': chofer,
      'muelle_partida': muellePartida,
      'foto_url_evidencia': fotoUrlEvidencia,
      'fecha_zarpe': fechaZarpe.toIso8601String(),
      'estado': estado,
    };
  }
}
