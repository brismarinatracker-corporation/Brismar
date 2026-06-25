import '../entidades/cuadre_entidad.dart';

abstract class CuadreRepositorio {
  Future<void> guardarCuadre(CuadreEntidad cuadre);
  Future<List<CuadreEntidad>> obtenerHistorial();
  Future<void> sincronizarPendientes();
}
