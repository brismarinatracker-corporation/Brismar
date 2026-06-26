import '../entidades/cuadre_entidad.dart';

abstract class CuadreRepositorio {
  Future<void> guardarCuadre(CuadreEntidad cuadre);
  Future<List<CuadreEntidad>> obtenerHistorial(String usuarioId);
  Future<void> sincronizarPendientes(String usuarioId);
}
