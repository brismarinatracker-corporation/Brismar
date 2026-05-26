import '../repositorios/registro_repositorio.dart';

/// Caso de uso para sincronizar los registros pendientes desde SQLite local a Supabase.
/// Cumple con la Responsabilidad Única (SRP).
class SincronizarPendientesCasoUso {
  final RegistroRepositorio _repositorio;

  SincronizarPendientesCasoUso(this._repositorio);

  /// Ejecuta el proceso de sincronización en lote.
  Future<void> ejecutar() async {
    await _repositorio.sincronizarPendientes();
  }
}
