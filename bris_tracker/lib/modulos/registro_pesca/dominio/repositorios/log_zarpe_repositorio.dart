import '../entidades/log_zarpe_entidad.dart';

/// Interfaz del repositorio para el sistema de auditoría de zarpes.
///
/// Separa el contrato de negocio de la implementación concreta (SQLite/Supabase).
abstract class LogZarpeRepositorio {
  /// Persiste un nuevo evento de log.
  Future<void> registrarEvento(LogZarpeEntidad log);

  /// Obtiene todos los logs de un cuadre específico, ordenados por timestamp DESC.
  Future<List<LogZarpeEntidad>> obtenerLogsPorCuadre(String cuadreId);

  /// Obtiene todos los logs de un zarpe específico, ordenados por timestamp DESC.
  Future<List<LogZarpeEntidad>> obtenerLogsPorZarpe(String zarpeId);

  /// Retorna los logs pendientes de sincronización con Supabase.
  Future<List<LogZarpeEntidad>> obtenerLogsPendientes();

  /// Marca un log como sincronizado en la base de datos local.
  Future<void> marcarComoSincronizado(String logId);

  /// Sincroniza todos los logs pendientes hacia Supabase.
  Future<void> sincronizarLogsPendientes();
}
