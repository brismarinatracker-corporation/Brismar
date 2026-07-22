import 'package:flutter/foundation.dart';
import '../../dominio/entidades/zarpe_entidad.dart';
import '../../dominio/repositorios/zarpe_repositorio.dart';
import '../fuentes_datos/fuente_datos_zarpes_local.dart';
import '../fuentes_datos/fuente_datos_zarpes_remota.dart';
import '../modelos/zarpe_modelo.dart';

/// Implementación concreta de [ZarpeRepositorio].
///
/// Aplica estrategia **Offline-First**: toda escritura se persiste localmente
/// antes de intentar sincronizar con Supabase. Si no hay red, el zarpe queda
/// en cola (`sincronizado = 0`) para el próximo ciclo de sincronización.
class ZarpeRepositorioImp implements ZarpeRepositorio {
  final FuenteDatosZarpesLocal local;
  final FuenteDatosZarpesRemota remota;

  ZarpeRepositorioImp({required this.local, required this.remota});

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
  /// Retorna todos los zarpes almacenados localmente en el dispositivo.
  ///
  /// El parámetro [usuarioId] está reservado para filtrado futuro si la
  /// tabla local incorpora el campo. Hoy el aislamiento lo hace Supabase RLS.
  Future<List<ZarpeEntidad>> obtenerHistorial(String usuarioId) async {
    final listaModelos = await local.obtenerZarpesLocales();

    return listaModelos
        .map(
          (m) => ZarpeEntidad(
            id: m.id,
            placaCamara: m.placaCamara,
            chofer: m.chofer,
            numeroChofer: m.numeroChofer,
            muellePartida: m.muellePartida,
            fotoUrlEvidencia: m.fotoUrlEvidencia,
            fotoLocalPath: m.fotoLocalPath,
            fechaZarpe: m.fechaZarpe,
            estado: m.estado,
          ),
        )
        .toList();
  }

  @override
  /// Sube a Supabase todos los zarpes locales con [sincronizado == 0].
  ///
  /// Opera sobre todos los zarpes del dispositivo. Si un zarpe falla,
  /// se registra en debug y se continúa con el siguiente (no bloquea la cola).
  Future<void> sincronizarPendientes() async {
    final zarpesLocales = await local.obtenerZarpesLocales();
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
    final zarpesActualizados = await remota.obtenerZarpesActualizados(
      haceUnaSemana,
    );

    for (var z in zarpesActualizados) {
      // Usar sqlite o gestordb directo desde la fuente local
      await local.actualizarEstadoDownstream(z['id'], z['estado']);
    }
  }
}
