/// Constantes globales de negocio para la aplicación Web Admin de BRISMAR.
///
/// Centraliza valores de configuración que representan reglas del negocio,
/// evitando que vivan enterradas dentro de widgets o validadores.
/// Si una regla cambia, solo se modifica aquí.
class AppConstants {
  AppConstants._();

  // ─── Autenticación y Acceso ──────────────────────────────────────────

  /// Dominio corporativo permitido para los correos de los empleados.
  static const String dominioCorporativo = '@brismar.com.pe';

  /// Si [true], solo se permiten correos con el [dominioCorporativo].
  /// Cambiar a [false] para permitir correos externos (ej. @gmail.com).
  static const bool soloDominioCorporativo = true;

  // ─── Roles del sistema ───────────────────────────────────────────────

  /// Roles válidos para asignar a un usuario en el sistema.
  static const List<String> rolesValidos = [
    'empleado',
    'administrador',
    'bahia',
    'supervisor',
  ];

  // ─── Sedes operativas ────────────────────────────────────────────────

  /// Sedes operativas activas de BRISMAR.
  static const List<String> sedesValidas = ['paita', 'piura', 'lambayeque'];

  /// Sede por defecto cuando no se puede determinar la sede del usuario.
  static const String sedePorDefecto = 'paita';

  // ─── Almacenamiento ──────────────────────────────────────────────────

  /// Nombre del bucket de Supabase Storage para avatares de usuario.
  static const String bucketAvatares = 'avatars';
}
