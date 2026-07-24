// ============================================================
// Módulo   : Tránsito — Web Admin
// Archivo  : zarpe_modelo.dart
// Propósito: Modelo de dominio tipado para un Zarpe/Cámara.
// ============================================================

import '../enums/estado_zarpe.dart';

/// Modelo de dominio para un Zarpe (cámara de pesca).
///
/// Reemplaza el uso de `Map<String, dynamic>` que causaba crashes
/// en runtime al renombrar columnas en Supabase. Todos los campos
/// tienen tipos Dart concretos con defaults seguros.
///
/// El modelo mapea la vista `vista_zarpes_detallados` de Supabase.
class ZarpeModelo {
  final String id;
  final String placaCamara;
  final String chofer;
  final String numeroChofer;
  final String muellePartida;
  final String? muelleDestino;
  final EstadoZarpe estado;
  final DateTime? fechaZarpe;
  final String? fotoUrlEvidencia;
  final int? numeroCajas;
  final double? pesoAproximado;
  final String? observaciones;
  final String? usuarioId;
  // Campos agregados de vista_zarpes_detallados
  final double? pesoTotal;
  final int? cajasLlenas;
  final String? embarcacionesAsociadas;
  final double? costoFlete;
  final String? usuarioNombre;
  final String? usuarioCorreo;
  final String? usuarioRol;

  const ZarpeModelo({
    required this.id,
    required this.placaCamara,
    required this.chofer,
    required this.numeroChofer,
    required this.muellePartida,
    this.muelleDestino,
    this.estado = EstadoZarpe.pendiente,
    this.fechaZarpe,
    this.fotoUrlEvidencia,
    this.numeroCajas,
    this.pesoAproximado,
    this.observaciones,
    this.usuarioId,
    this.pesoTotal,
    this.cajasLlenas,
    this.embarcacionesAsociadas,
    this.costoFlete,
    this.usuarioNombre,
    this.usuarioCorreo,
    this.usuarioRol,
  });

  /// Construye desde el [Map] retornado por Supabase.
  ///
  /// Nunca lanza excepción: campos desconocidos o nulos usan defaults.
  factory ZarpeModelo.desdeJson(Map<String, dynamic> json) {
    return ZarpeModelo(
      id: json['id'] as String? ?? '',
      placaCamara: json['placa_camara'] as String? ?? '',
      chofer: json['chofer'] as String? ?? '',
      numeroChofer: json['numero_chofer'] as String? ?? '-',
      muellePartida: json['muelle_partida'] as String? ?? '',
      muelleDestino: json['muelle_destino'] as String?,
      estado: EstadoZarpe.desdeDb(
        (json['estado_transito'] ?? json['estado']) as String?,
      ),
      fechaZarpe: _parsearFecha(json['fecha_zarpe']),
      fotoUrlEvidencia: json['foto_url_evidencia'] as String?,
      numeroCajas: (json['numero_cajas'] as num?)?.toInt(),
      pesoAproximado: (json['peso_aproximado'] as num?)?.toDouble(),
      observaciones: json['observaciones'] as String?,
      usuarioId: json['usuario_id'] as String?,
      pesoTotal: (json['peso_total'] as num?)?.toDouble(),
      cajasLlenas: (json['cajas_llenas'] as num?)?.toInt(),
      embarcacionesAsociadas: json['embarcaciones_asociadas'] as String?,
      costoFlete: (json['costo_flete'] as num?)?.toDouble(),
      usuarioNombre: json['usuario_nombre'] as String?,
      usuarioCorreo: json['usuario_correo'] as String?,
      usuarioRol: json['usuario_rol'] as String?,
    );
  }

  /// Convierte el modelo a [Map] para operaciones de UPDATE en Supabase.
  Map<String, dynamic> aJson() {
    return {
      'id': id,
      'placa_camara': placaCamara,
      'chofer': chofer,
      'numero_chofer': numeroChofer,
      'muelle_partida': muellePartida,
      if (muelleDestino != null) 'muelle_destino': muelleDestino,
      'estado': estado.valorDb,
      if (fechaZarpe != null)
        'fecha_zarpe': fechaZarpe!.toIso8601String().substring(0, 10),
      if (observaciones != null) 'observaciones': observaciones,
    };
  }

  /// Parsea una fecha de la DB que puede ser String o DateTime.
  static DateTime? _parsearFecha(dynamic valor) {
    if (valor == null) return null;
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    return null;
  }

  /// Extrae las URLs de fotos de la columna `foto_url_evidencia`.
  ///
  /// El campo almacena URLs separadas por coma en la DB.
  List<String> get urlsFotos {
    final raw = fotoUrlEvidencia ?? '';
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.startsWith('http'))
        .toList();
  }

  /// Crea una copia inmutable con campos actualizados.
  ZarpeModelo copiarCon({
    String? placaCamara,
    String? chofer,
    String? numeroChofer,
    String? muellePartida,
    EstadoZarpe? estado,
  }) {
    return ZarpeModelo(
      id: id,
      placaCamara: placaCamara ?? this.placaCamara,
      chofer: chofer ?? this.chofer,
      numeroChofer: numeroChofer ?? this.numeroChofer,
      muellePartida: muellePartida ?? this.muellePartida,
      muelleDestino: muelleDestino,
      estado: estado ?? this.estado,
      fechaZarpe: fechaZarpe,
      fotoUrlEvidencia: fotoUrlEvidencia,
      numeroCajas: numeroCajas,
      pesoAproximado: pesoAproximado,
      observaciones: observaciones,
      usuarioId: usuarioId,
    );
  }

  @override
  bool operator ==(Object other) => other is ZarpeModelo && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ZarpeModelo(id: $id, placa: $placaCamara, estado: ${estado.valorDb})';
}
