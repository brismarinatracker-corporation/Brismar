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

final proveedorZarpes = StateNotifierProvider<ControladorZarpes, AsyncValue<void>>((ref) {
  return ControladorZarpes(ref.read(proveedorFuenteZarpes));
});

class ControladorZarpes extends StateNotifier<AsyncValue<void>> {
  final FuenteDatosZarpesRemota _fuenteRemota;

  ControladorZarpes(this._fuenteRemota) : super(const AsyncValue.data(null));

  Future<void> registrarZarpe(ZarpeEntidad zarpe) async {
    state = const AsyncValue.loading();
    try {
      final modelo = ZarpeModelo(
        id: zarpe.id,
        placaCamara: zarpe.placaCamara,
        chofer: zarpe.chofer,
        muellePartida: zarpe.muellePartida,
        fotoUrlEvidencia: zarpe.fotoUrlEvidencia,
        fotoLocalPath: zarpe.fotoLocalPath,
        fechaZarpe: zarpe.fechaZarpe,
        estado: 'pendiente',
      );

      // 1. Guardar Local en SQLite
      final db = await GestorBaseDatos.instance.database;
      await db.insert('zarpes', modelo.toMap());

      // 2. Intentar subir a Storage y Postgres
      try {
        await _fuenteRemota.subirZarpe(modelo);
        // Si tiene éxito, actualizar estado en SQLite a sincronizado
        await db.update(
          'zarpes', 
          {'estado': 'sincronizado'}, 
          where: 'id = ?', 
          whereArgs: [modelo.id]
        );
      } catch (e) {
        debugPrint('Error subiendo Zarpe a la nube (Se mantiene offline): $e');
        // Se queda como pendiente en SQLite para sincronizar después
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> sincronizarZarpesPendientes() async {
    final db = await GestorBaseDatos.instance.database;
    final pendientes = await db.query('zarpes', where: 'estado = ?', whereArgs: ['pendiente']);
    
    for (var row in pendientes) {
      final modelo = ZarpeModelo.fromMap(row);
      try {
        await _fuenteRemota.subirZarpe(modelo);
        await db.update(
          'zarpes', 
          {'estado': 'sincronizado'}, 
          where: 'id = ?', 
          whereArgs: [modelo.id]
        );
      } catch (e) {
        debugPrint('Error auto-sincronizando Zarpe: $e');
      }
    }
  }
}
