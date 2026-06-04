import '../entidades/registro_entidad.dart';
import '../repositorios/registro_repositorio.dart';

/// Caso de uso para obtener el historial de capturas guardadas.
/// Cumple con la Responsabilidad Única (SRP).
class ObtenerHistorialCasoUso {
  final RegistroRepositorio _repositorio;

  ObtenerHistorialCasoUso(this._repositorio);

  /// Obtiene los registros en orden cronológico descendente.
  Future<List<RegistroEntidad>> ejecutar() async {
    return await _repositorio.obtenerHistorial();
  }
}
