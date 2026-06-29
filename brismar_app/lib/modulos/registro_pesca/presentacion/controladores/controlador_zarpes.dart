import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dominio/entidades/zarpe_entidad.dart';
import '../../datos/modelos/zarpe_modelo.dart';
import '../../datos/fuentes_datos/fuente_datos_zarpes_remota.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

final proveedorFuenteZarpes = Provider<FuenteDatosZarpesRemota>((ref) {
  return FuenteDatosZarpesRemota(Supabase.instance.client);
});

final proveedorZarpes =
    StateNotifierProvider<ControladorZarpes, AsyncValue<void>>((ref) {
  return ControladorZarpes(ref.read(proveedorFuenteZarpes));
});

/// Controlador de zarpes offline-first.
///
/// Persiste primero en SQLite y luego intenta sincronizar con Supabase.
/// Usa la columna [sincronizado] para rastrear el estado de sync,
/// independientemente del [estado] de negocio del zarpe.
class ControladorZarpes extends StateNotifier<AsyncValue<void>> {
  final FuenteDatosZarpesRemota _fuenteRemota;

  ControladorZarpes(this._fuenteRemota) : super(const AsyncValue.data(null));

  /// Registra un zarpe localmente y lo intenta subir a Supabase.
  Future<void> registrarZarpe(ZarpeEntidad zarpe) async {
    state = const AsyncValue.loading();
    try {
      final modelo = _entidadAModelo(zarpe);
      await _guardarLocal(modelo);
      await _intentarSincronizar(modelo);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Sincroniza todos los zarpes con [sincronizado = 0] hacia Supabase.
  Future<void> sincronizarZarpesPendientes() async {
    final db = await GestorBaseDatos.instance.database;
    final pendientes =
        await db.query('zarpes', where: 'sincronizado = ?', whereArgs: [0]);

    for (var row in pendientes) {
      final modelo = ZarpeModelo.fromMap(row);
      try {
        await _fuenteRemota.subirZarpe(modelo);
        await _marcarComoSincronizado(db, modelo.id);
      } catch (e) {
        debugPrint('Error auto-sincronizando Zarpe ${modelo.id}: $e');
      }
    }
  }

  /// Descarga los cambios de estado de negocio desde Supabase al SQLite local.
  ///
  /// Actualiza SOLO el campo [estado] (negocio), sin tocar [sincronizado].
  Future<void> sincronizarZarpesDownstream() async {
    final db = await GestorBaseDatos.instance.database;
    final haceUnaSemana = DateTime.now().subtract(const Duration(days: 7));
    final zarpesActualizados =
        await _fuenteRemota.obtenerZarpesActualizados(haceUnaSemana);

    for (var z in zarpesActualizados) {
      await db.update(
        'zarpes',
        {'estado': z['estado']},
        where: 'id = ?',
        whereArgs: [z['id']],
      );
    }
  }

  // ─── Métodos Privados ──────────────────────────────────────────────────────

  ZarpeModelo _entidadAModelo(ZarpeEntidad zarpe) {
    return ZarpeModelo(
      id: zarpe.id,
      placaCamara: zarpe.placaCamara,
      chofer: zarpe.chofer,
      muellePartida: zarpe.muellePartida,
      fotoUrlEvidencia: zarpe.fotoUrlEvidencia,
      fotoLocalPath: zarpe.fotoLocalPath,
      fechaZarpe: zarpe.fechaZarpe,
      estado: 'DESPACHADO_PIURA',
      sincronizado: 0,
    );
  }

  Future<void> _guardarLocal(ZarpeModelo modelo) async {
    final db = await GestorBaseDatos.instance.database;
    await db.insert('zarpes', modelo.toMap());
  }

  Future<void> _intentarSincronizar(ZarpeModelo modelo) async {
    final db = await GestorBaseDatos.instance.database;
    try {
      await _fuenteRemota.subirZarpe(modelo);
      await _marcarComoSincronizado(db, modelo.id);
    } catch (e) {
      debugPrint('Zarpe guardado offline (sincronizará después): $e');
    }
  }

  Future<void> _marcarComoSincronizado(dynamic db, String id) async {
    await db.update(
      'zarpes',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
