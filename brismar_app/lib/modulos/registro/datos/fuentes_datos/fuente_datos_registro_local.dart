import 'package:sqflite/sqflite.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
import '../modelos/registro_modelo.dart';

/// Fuente de datos local para la persistencia offline en SQLite.
/// Sigue el principio de Responsabilidad Única (SRP).
class FuenteDatosRegistroLocal {
  final GestorBaseDatos _dbHelper = GestorBaseDatos.instance;

  /// Inserta o actualiza un registro en la base de datos local SQLite.
  Future<void> guardarRegistro(RegistroModelo modelo) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'registro_embarcaciones',
        modelo.toSqlite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stack) {
      throw ExcepcionApp(
        'DB-002',
        mensajeTecnico: 'Error al guardar el registro en SQLite.',
        causa: e,
        stackTrace: stack,
      );
    }
  }

  /// Obtiene todos los registros locales ordenados cronológicamente de forma descendente.
  Future<List<RegistroModelo>> obtenerHistorialLocal() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'registro_embarcaciones',
        orderBy: 'fecha DESC, hora DESC',
      );
      return result.map((map) => RegistroModelo.fromSqlite(map)).toList();
    } catch (e, stack) {
      throw ExcepcionApp(
        'DB-004',
        mensajeTecnico: 'Error al leer el historial local.',
        causa: e,
        stackTrace: stack,
      );
    }
  }

  /// Obtiene todos los registros que aún no se han subido al servidor.
  Future<List<RegistroModelo>> obtenerPendientesSincronizar() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'registro_embarcaciones',
        where: 'sincronizado = 0',
      );
      return result.map((map) => RegistroModelo.fromSqlite(map)).toList();
    } catch (e, stack) {
      throw ExcepcionApp(
        'DB-004',
        mensajeTecnico: 'Error al consultar registros pendientes.',
        causa: e,
        stackTrace: stack,
      );
    }
  }

  /// Actualiza la bandera de sincronización local para un lote de IDs.
  Future<void> marcarComoSincronizados(List<String> ids) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        for (final id in ids) {
          await txn.update(
            'registro_embarcaciones',
            {'sincronizado': 1},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      });
    } catch (e, stack) {
      throw ExcepcionApp(
        'DB-002',
        mensajeTecnico: 'Error al actualizar estado de sincronización.',
        causa: e,
        stackTrace: stack,
      );
    }
  }
}
