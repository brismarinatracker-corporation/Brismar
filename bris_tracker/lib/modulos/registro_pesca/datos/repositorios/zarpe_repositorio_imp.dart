import 'package:flutter/foundation.dart';
import '../../dominio/entidades/zarpe_entidad.dart';
import '../../dominio/repositorios/zarpe_repositorio.dart';
import '../fuentes_datos/fuente_datos_zarpes_local.dart';
import '../fuentes_datos/fuente_datos_zarpes_remota.dart';
import '../modelos/zarpe_modelo.dart';

/// Implementación concreta de [ZarpeRepositorio].
/// Maneja la lógica Offline-First.
class ZarpeRepositorioImp implements ZarpeRepositorio {
  final FuenteDatosZarpesLocal local;
  final FuenteDatosZarpesRemota remota;

  ZarpeRepositorioImp({
    required this.local,
    required this.remota,
  });

  @override
  Future<void> guardarZarpe(ZarpeEntidad zarpe) async {
    final ZarpeModelo modelo;
    if (zarpe is ZarpeModelo) {
      modelo = zarpe as ZarpeModelo;
    } else {
      modelo = ZarpeModelo.fromEntidad(zarpe);
    }
    
    // 1. Guardar localmente siempre primero (Offline-first)
    await local.guardarZarpeLocal(modelo);

    // 2. Intentar subir a Supabase si hay red
    try {
      await remota.subirZarpe(modelo);
      // Si tuvo éxito, marcamos como sincronizado
      await local.marcarComoSincronizado(modelo.id, modelo.fotoUrlEvidencia);
    } catch (e) {
      debugPrint('Zarpe guardado localmente, pero falló sincronización: $e');
    }
  }

  @override
  Future<List<ZarpeEntidad>> obtenerHistorial(String usuarioId) async {
    final listaModelos = await local.obtenerZarpesLocales(usuarioId);
    
    return listaModelos.map((m) => ZarpeEntidad(
      id: m.id,
      placaCamara: m.placaCamara,
      chofer: m.chofer,
      muellePartida: m.muellePartida,
      fotoUrlEvidencia: m.fotoUrlEvidencia,
      fotoLocalPath: m.fotoLocalPath,
      fechaZarpe: m.fechaZarpe,
      estado: m.estado,
    )).toList();
  }

  @override
  Future<void> sincronizarPendientes() async {
    final zarpesLocales = await local.obtenerZarpesLocales(''); // Obtiene todos por ahora
    final pendientes = zarpesLocales.where((z) => z.sincronizado == 0).toList();

    for (var zarpe in pendientes) {
      try {
        await remota.subirZarpe(zarpe);
        await local.marcarComoSincronizado(zarpe.id, zarpe.fotoUrlEvidencia);
      } catch (e) {
        debugPrint("Error sincronizando zarpe ${zarpe.id}: $e");
      }
    }
  }

  @override
  Future<void> sincronizarZarpesDownstream() async {
    final haceUnaSemana = DateTime.now().subtract(const Duration(days: 7));
    final zarpesActualizados = await remota.obtenerZarpesActualizados(haceUnaSemana);

    for (var z in zarpesActualizados) {
      // Usar sqlite o gestordb directo desde la fuente local
      await local.actualizarEstadoDownstream(z['id'], z['estado']);
    }
  }
}
