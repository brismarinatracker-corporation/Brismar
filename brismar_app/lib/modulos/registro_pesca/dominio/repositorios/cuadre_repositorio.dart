import '../entidades/cuadre_entidad.dart';

/// Contrato para el repositorio de cuadres de pesca.
abstract class CuadreRepositorio {
  /// Guarda el cuadre (cabecera y relaciones) localmente.
  Future<void> guardarCuadre(CuadreEntidad cuadre);

  /// Obtiene la lista histórica de cuadres creados por un usuario.
  Future<List<CuadreEntidad>> obtenerHistorial(String usuarioId);

  /// Sincroniza los cuadres pendientes locales con la base de datos central Supabase.
  Future<void> sincronizarPendientes(String usuarioId);
}
