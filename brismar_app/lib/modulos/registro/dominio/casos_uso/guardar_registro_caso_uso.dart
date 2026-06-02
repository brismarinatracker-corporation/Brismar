import '../entidades/registro_entidad.dart';
import '../repositorios/registro_repositorio.dart';

/// Caso de uso para guardar un registro de pesca.
/// Cumple con la Responsabilidad Única (SRP).
class GuardarRegistroCasoUso {
  final RegistroRepositorio _repositorio;

  GuardarRegistroCasoUso(this._repositorio);

  /// Ejecuta la acción de negocio para guardar el registro.
  Future<void> ejecutar(RegistroEntidad registro) async {
    await _repositorio.guardarRegistro(registro);
  }
}
