import 'package:bris_tracker/modulos/registro_pesca/dominio/entidades/estado_zarpe.dart';

/// Entidad que representa el Zarpe de una cámara transportadora.
class ZarpeEntidad {
  /// Identificador único del zarpe.
  final String id;

  /// Placa identificadora de la cámara.
  final String placaCamara;

  /// Nombre completo del chofer de la cámara.
  final String chofer;

  /// Nombre del muelle de partida.
  final String muellePartida;

  /// URL pública de la foto de evidencia subida a Supabase.
  final String fotoUrlEvidencia;

  /// Ruta local absoluta del archivo de foto de evidencia en el dispositivo.
  final String? fotoLocalPath;

  /// Fecha y hora del zarpe.
  final DateTime fechaZarpe;

  /// Estado de negocio del zarpe.
  final EstadoZarpe estado;

  /// Constructor de [ZarpeEntidad].
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

  /// Crea una copia de esta entidad reemplazando los campos provistos.
  ZarpeEntidad copyWith({
    String? id,
    String? placaCamara,
    String? chofer,
    String? muellePartida,
    String? fotoUrlEvidencia,
    String? fotoLocalPath,
    DateTime? fechaZarpe,
    EstadoZarpe? estado,
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
