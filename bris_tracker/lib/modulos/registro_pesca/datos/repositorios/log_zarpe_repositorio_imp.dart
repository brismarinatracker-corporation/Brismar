import 'package:flutter/foundation.dart';
import '../../dominio/entidades/log_zarpe_entidad.dart';
import '../../dominio/repositorios/log_zarpe_repositorio.dart';
import '../fuentes_datos/fuente_datos_log_local.dart';
import '../fuentes_datos/fuente_datos_log_remota.dart';

/// Implementación concreta del [LogZarpeRepositorio].
///
/// Orquesta las operaciones entre la fuente de datos local (SQLite)
/// y la fuente remota (Supabase) con soporte offline-first.
class LogZarpeRepositorioImp implements LogZarpeRepositorio {
  /// Fuente de datos local (SQLite).
  final FuenteDatosLogLocal _local;

  /// Fuente de datos remota (Supabase).
  final FuenteDatosLogRemota _remota;

  /// Constructor que recibe las fuentes de datos por inyección.
  const LogZarpeRepositorioImp({
    required FuenteDatosLogLocal local,
    required FuenteDatosLogRemota remota,
  }) : _local = local,
       _remota = remota;

  @override
  Future<void> registrarEvento(LogZarpeEntidad log) async {
    // Siempre guarda primero en local (offline-first).
    await _local.insertarLog(log);
  }

  @override
  Future<List<LogZarpeEntidad>> obtenerLogsPorCuadre(String cuadreId) =>
      _local.obtenerPorCuadre(cuadreId);

  @override
  Future<List<LogZarpeEntidad>> obtenerLogsPorZarpe(String zarpeId) =>
      _local.obtenerPorZarpe(zarpeId);

  @override
  Future<List<LogZarpeEntidad>> obtenerLogsPendientes() =>
      _local.obtenerPendientes();

  @override
  Future<void> marcarComoSincronizado(String logId) =>
      _local.marcarSincronizado(logId);

  @override
  Future<void> sincronizarLogsPendientes() async {
    final pendientes = await _local.obtenerPendientes();
    for (var p in pendientes) {
      try {
        await _remota.sincronizarLog(p);
        await _local.marcarSincronizado(p.id);
      } catch (e) {
        // Falló un log, continúa con el siguiente.
        // Se volverá a intentar en la próxima sincronización.
        debugPrint('Error sincronizando log ${p.id}: $e');
      }
    }
  }
}
