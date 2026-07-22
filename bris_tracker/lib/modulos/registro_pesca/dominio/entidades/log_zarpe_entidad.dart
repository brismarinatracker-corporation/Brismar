/// Representa el origen desde donde se generó el evento de auditoría.
enum OrigenLog {
  /// Cambio realizado desde la app móvil (bris_tracker).
  app,

  /// Cambio realizado desde el panel web de administración (bris_web).
  web;

  /// Serializa el enum a String para persistencia.
  String get valor => name; // 'app' | 'web'

  /// Deserializa un String al enum correspondiente.
  static OrigenLog fromString(String v) =>
      v == 'web' ? OrigenLog.web : OrigenLog.app;
}

/// Tipos de acción que pueden quedar registrados en el audit log.
enum AccionLog {
  /// Se creó un nuevo zarpe de cámara.
  zarpeCreado,

  /// Se creó un nuevo cuadre de pesca.
  cuadreCreado,

  /// Se actualizó un cuadre existente (móvil).
  cuadreActualizado,

  /// Se editó un cuadre desde el panel web.
  cuadreEditadoWeb,

  /// El registro fue sincronizado con la nube (Supabase).
  sincronizadoNube,

  /// Evento genérico para acciones no clasificadas.
  otro;

  /// Serializa la acción a String para persistencia.
  String get valor {
    switch (this) {
      case AccionLog.zarpeCreado:
        return 'ZARPE_CREADO';
      case AccionLog.cuadreCreado:
        return 'CUADRE_CREADO';
      case AccionLog.cuadreActualizado:
        return 'CUADRE_ACTUALIZADO';
      case AccionLog.cuadreEditadoWeb:
        return 'CUADRE_EDITADO_WEB';
      case AccionLog.sincronizadoNube:
        return 'SINCRONIZADO_NUBE';
      case AccionLog.otro:
        return 'OTRO';
    }
  }

  /// Deserializa un String al enum correspondiente.
  static AccionLog fromString(String v) {
    switch (v) {
      case 'ZARPE_CREADO':
        return AccionLog.zarpeCreado;
      case 'CUADRE_CREADO':
        return AccionLog.cuadreCreado;
      case 'CUADRE_ACTUALIZADO':
        return AccionLog.cuadreActualizado;
      case 'CUADRE_EDITADO_WEB':
        return AccionLog.cuadreEditadoWeb;
      case 'SINCRONIZADO_NUBE':
        return AccionLog.sincronizadoNube;
      default:
        return AccionLog.otro;
    }
  }
}

/// Entidad de dominio que representa un evento de auditoría inmutable.
///
/// Cada instancia es un registro histórico del sistema y nunca debe modificarse.
/// Se genera automáticamente cada vez que ocurre un evento relevante.
class LogZarpeEntidad {
  /// Identificador único del log (UUID v4).
  final String id;

  /// ID del zarpe al que pertenece este log (puede ser null si aún no existe zarpe).
  final String? zarpeId;

  /// ID del cuadre al que pertenece este log.
  final String? cuadreId;

  /// ID del usuario que realizó la acción.
  final String usuarioId;

  /// Nombre legible del usuario (desnormalizado para eficiencia de lectura).
  final String nombreUsuario;

  /// Desde dónde se originó el cambio: app o web.
  final OrigenLog origen;

  /// Tipo de acción realizada.
  final AccionLog accion;

  /// Detalle en JSON de los campos que cambiaron (solo para admins).
  final String? detalle;

  /// Fecha y hora UTC en que ocurrió el evento.
  final DateTime timestamp;

  /// Indica si este log ya fue enviado a Supabase.
  final bool sincronizado;

  /// Constructor constante — LogZarpeEntidad es inmutable por diseño.
  const LogZarpeEntidad({
    required this.id,
    this.zarpeId,
    this.cuadreId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.origen,
    required this.accion,
    this.detalle,
    required this.timestamp,
    this.sincronizado = false,
  });
}
