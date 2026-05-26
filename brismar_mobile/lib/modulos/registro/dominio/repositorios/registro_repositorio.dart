import '../entidades/registro_entidad.dart';

/// Contrato abstracto para la persistencia e integración de registros de pesca.
/// Sigue el principio SOLID de Abierto/Cerrado (OCP).
abstract class RegistroRepositorio {
  /// Guarda un registro de pesca en el almacenamiento local SQLite.
  /// Lanza una excepción en caso de error.
  Future<void> guardarRegistro(RegistroEntidad registro);

  /// Obtiene la lista completa de registros guardados, ordenados del más reciente al más antiguo.
  Future<List<RegistroEntidad>> obtenerHistorial();

  /// Busca registros locales no sincronizados y los envía a Supabase en lote.
  Future<void> sincronizarPendientes();
}
