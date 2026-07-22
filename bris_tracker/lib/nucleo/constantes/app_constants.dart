/// Constantes globales de negocio para la app móvil BRISMAR Tracker.
///
/// Centraliza valores de configuración que representan reglas del negocio.
/// Si una regla cambia (ej. máximo de fotos permitidas), solo se modifica aquí.
class AppConstants {
  AppConstants._();

  // ─── Fotografías de evidencia ────────────────────────────────────────

  /// Máximo de fotos de evidencia permitidas por zarpe.
  static const int maxFotosEvidencia = 3;

  /// Calidad de compresión para las imágenes capturadas (0-100).
  /// 70 equilibra tamaño y calidad visual para el uso en campo.
  static const int calidadCompresionImagen = 70;

  // ─── Sincronización ──────────────────────────────────────────────────

  /// Tiempo de espera en segundos antes de iniciar auto-sincronización
  /// después de detectar reconexión de red.
  static const int delayAutoSyncSegundos = 1;

  /// Ventana de tiempo hacia atrás para la sincronización downstream de zarpes.
  static const int diasSyncDownstreamZarpes = 7;

  // ─── Autenticación ───────────────────────────────────────────────────

  /// Timeout en segundos para las operaciones de autenticación con Supabase.
  static const int timeoutAuthSegundos = 10;

  // ─── Roles del sistema ───────────────────────────────────────────────

  /// Roles que tienen permiso de acceso a la app móvil.
  static const List<String> rolesPermitidosMovil = [
    'empleado',
    'bahia',
    'supervisor',
    'administrador',
  ];
}
