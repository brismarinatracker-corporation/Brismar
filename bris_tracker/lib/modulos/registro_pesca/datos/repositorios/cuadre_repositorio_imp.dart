import 'package:flutter/foundation.dart';
import '../../dominio/entidades/cuadre_entidad.dart';
import '../../dominio/repositorios/cuadre_repositorio.dart';
import '../fuentes_datos/fuente_datos_cuadres_local.dart';
import '../fuentes_datos/fuente_datos_cuadres_remota.dart';
import '../modelos/cuadre_modelo.dart';

/// Implementación concreta de [CuadreRepositorio].
class CuadreRepositorioImp implements CuadreRepositorio {
  /// Fuente de datos para la persistencia local.
  final FuenteDatosCuadresLocal local;

  /// Fuente de datos para el envío remoto.
  final FuenteDatosCuadresRemota remota;

  /// Constructor de [CuadreRepositorioImp].
  CuadreRepositorioImp({required this.local, required this.remota});

  @override
  Future<void> guardarCuadre(CuadreEntidad cuadre) async {
    final modelo = cuadre is CuadreModelo
        ? cuadre
        : CuadreModelo.fromEntidad(cuadre);
    await local.guardarCuadreCompleto(modelo);
  }

  @override
  Future<List<CuadreEntidad>> obtenerHistorial(String usuarioId) async {
    return await local.obtenerCuadres(usuarioId);
  }

  @override
  Future<void> sincronizarPendientes(String usuarioId) async {
    final cuadresLocales = await local.obtenerCuadres(usuarioId);
    final pendientes = cuadresLocales.where((c) => !c.sincronizado).toList();

    for (var cuadre in pendientes) {
      try {
        final urls = await remota.subirCuadre(cuadre);
        await local.marcarComoSincronizado(
          cuadre.id,
          urls['urlPdf'],
          urls['urlExcel'],
          urls['urlFoto'],
        );
      } catch (e) {
        // Log error, continue with next
        debugPrint("Error sincronizando cuadre ${cuadre.id}: $e");
      }
    }
  }
}
