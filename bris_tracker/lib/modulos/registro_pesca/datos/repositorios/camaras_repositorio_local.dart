import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';

class CamarasRepositorioLocal {
  final GestorBaseDatos _bd = GestorBaseDatos.instance;

  /// Obtiene todas las placas guardadas localmente para el autocompletado.
  Future<List<String>> obtenerPlacasActivas() async {
    try {
      final db = await _bd.database;
      final resultado = await db.query(
        'camaras',
        columns: ['placa'],
        orderBy: 'placa ASC',
      );

      return resultado.map((e) => e['placa'] as String).toList();
    } catch (e) {
      // Fallo tolerado: si SQLite no responde, el autocompletado queda vacío.
      // No se propaga para no interrumpir el flujo del formulario de zarpe.
      if (kDebugMode) {
        debugPrint('[CamarasRepo] obtenerPlacasActivas falló: $e');
      }
      return [];
    }
  }

  /// Registra una nueva placa localmente y la marca como no sincronizada
  /// para que se suba a Supabase en el próximo ciclo de sincronización.
  Future<void> guardarPlacaLocal(String placa) async {
    final cleanPlaca = placa.trim().toUpperCase();
    if (cleanPlaca.isEmpty) return;

    try {
      final db = await _bd.database;

      // Verificar si ya existe
      final existente = await db.query(
        'camaras',
        where: 'placa = ?',
        whereArgs: [cleanPlaca],
      );

      if (existente.isEmpty) {
        await db.insert('camaras', {
          'id': const Uuid().v4(),
          'placa': cleanPlaca,
          'sincronizado': 0, // 0 = Pendiente de subir
        });
      }
    } catch (e) {
      // Fallo tolerado: si la placa ya existe o SQLite falla, se descarta
      // silenciosamente. La placa se creará en el próximo intento.
      if (kDebugMode) {
        debugPrint('[CamarasRepo] guardarPlacaLocal falló para "$cleanPlaca": $e');
      }
    }
  }

  /// Sincroniza las placas entre SQLite local y Supabase.
  Future<void> sincronizarCamaras() async {
    try {
      final db = await _bd.database;
      final supabase = Supabase.instance.client;

      // 1. PUSH: Subir placas locales nuevas (sincronizado = 0)
      final pendientes = await db.query('camaras', where: 'sincronizado = 0');
      for (final p in pendientes) {
        try {
          await supabase.from('camaras').insert({
            'placa': p['placa'],
            'estado_activo': true,
          });
          // Marcar como sincronizado
          await db.update(
            'camaras',
            {'sincronizado': 1},
            where: 'id = ?',
            whereArgs: [p['id']],
          );
        } catch (e) {
          // Fallo individual tolerado: la placa ya puede existir en Supabase
          // (conflicto de duplicado) o no hay red. Se reintenta en el siguiente sync.
          if (kDebugMode) {
            debugPrint('[CamarasRepo] Push placa "${p['placa']}" falló: $e');
          }
        }
      }

      // 2. PULL: Descargar placas activas desde Supabase
      final remotas = await supabase
          .from('camaras')
          .select('id, placa')
          .eq('estado_activo', true);

      final batch = db.batch();
      for (final r in (remotas as List)) {
        batch.insert(
          'camaras',
          {'id': r['id'], 'placa': r['placa'], 'sincronizado': 1},
          conflictAlgorithm:
              ConflictAlgorithm.ignore, // Ignora si la placa ya existe
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      // Fallo del ciclo completo de sincronización.
      // No se propaga: la app sigue funcionando en modo local hasta el próximo ciclo.
      if (kDebugMode) {
        debugPrint('[CamarasRepo] sincronizarCamaras falló: $e');
      }
    }
  }
}
