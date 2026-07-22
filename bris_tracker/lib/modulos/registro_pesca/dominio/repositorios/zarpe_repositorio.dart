import '../entidades/zarpe_entidad.dart';

/// Contrato para el repositorio de Zarpes.
/// Define las operaciones de persistencia y sincronización.
abstract class ZarpeRepositorio {
  /// Guarda un zarpe (offline-first: local, luego intenta remoto).
  Future<void> guardarZarpe(ZarpeEntidad zarpe);

  /// Obtiene el historial de zarpes del usuario desde el almacenamiento local.
  Future<List<ZarpeEntidad>> obtenerHistorial(String usuarioId);

  /// Sincroniza los zarpes locales pendientes de subida con Supabase.
  Future<void> sincronizarPendientes();

  /// Descarga los cambios de estado de negocio desde Supabase al local.
  Future<void> sincronizarZarpesDownstream();
}
