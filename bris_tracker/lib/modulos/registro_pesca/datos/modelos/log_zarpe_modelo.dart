import 'dart:convert';
import '../../dominio/entidades/log_zarpe_entidad.dart';

/// Modelo de datos de [LogZarpeEntidad] con capacidad de serialización.
///
/// Extiende la entidad del dominio para añadir lógica de persistencia
/// sin contaminar la capa de dominio.
class LogZarpeModelo extends LogZarpeEntidad {
  /// Constructor que delega al super de la entidad.
  const LogZarpeModelo({
    required super.id,
    super.zarpeId,
    super.cuadreId,
    required super.usuarioId,
    required super.nombreUsuario,
    required super.origen,
    required super.accion,
    super.detalle,
    required super.timestamp,
    super.sincronizado,
  });

  /// Crea un [LogZarpeModelo] a partir de una [LogZarpeEntidad].
  factory LogZarpeModelo.fromEntidad(LogZarpeEntidad e) => LogZarpeModelo(
    id: e.id,
    zarpeId: e.zarpeId,
    cuadreId: e.cuadreId,
    usuarioId: e.usuarioId,
    nombreUsuario: e.nombreUsuario,
    origen: e.origen,
    accion: e.accion,
    detalle: e.detalle,
    timestamp: e.timestamp,
    sincronizado: e.sincronizado,
  );

  /// Convierte el modelo a un mapa compatible con SQLite.
  Map<String, dynamic> toSqlite() => {
    'id': id,
    'zarpe_id': zarpeId,
    'cuadre_id': cuadreId,
    'usuario_id': usuarioId,
    'nombre_usuario': nombreUsuario,
    'origen': origen.valor,
    'accion': accion.valor,
    'detalle': detalle,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'sincronizado': sincronizado ? 1 : 0,
  };

  /// Crea un [LogZarpeModelo] a partir de un mapa de SQLite.
  factory LogZarpeModelo.fromSqlite(Map<String, dynamic> map) => LogZarpeModelo(
    id: map['id'] as String,
    zarpeId: map['zarpe_id'] as String?,
    cuadreId: map['cuadre_id'] as String?,
    usuarioId: map['usuario_id'] as String,
    nombreUsuario: map['nombre_usuario'] as String,
    origen: OrigenLog.fromString(map['origen'] as String? ?? 'app'),
    accion: AccionLog.fromString(map['accion'] as String? ?? 'OTRO'),
    detalle: map['detalle'] as String?,
    timestamp: DateTime.parse(map['timestamp'] as String),
    sincronizado: (map['sincronizado'] as int? ?? 0) == 1,
  );

  /// Convierte el modelo a un mapa JSON para Supabase.
  Map<String, dynamic> toSupabase() => {
    'id': id,
    'zarpe_id': zarpeId,
    'cuadre_id': cuadreId,
    'usuario_id': usuarioId,
    'nombre_usuario': nombreUsuario,
    'origen': origen.valor,
    'accion': accion.valor,
    'detalle': detalle != null ? jsonDecode(detalle!) : null,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  /// Crea un [LogZarpeModelo] a partir de un mapa JSON de Supabase.
  factory LogZarpeModelo.fromSupabase(Map<String, dynamic> map) =>
      LogZarpeModelo(
        id: map['id'] as String,
        zarpeId: map['zarpe_id'] as String?,
        cuadreId: map['cuadre_id'] as String?,
        usuarioId: map['usuario_id'] as String,
        nombreUsuario: map['nombre_usuario'] as String? ?? 'Desconocido',
        origen: OrigenLog.fromString(map['origen'] as String? ?? 'app'),
        accion: AccionLog.fromString(map['accion'] as String? ?? 'OTRO'),
        detalle: map['detalle'] != null ? jsonEncode(map['detalle']) : null,
        timestamp: DateTime.parse(map['timestamp'] as String),
        sincronizado: true,
      );
}
