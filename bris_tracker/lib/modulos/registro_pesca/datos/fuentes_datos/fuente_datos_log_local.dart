import 'package:bris_tracker/nucleo/base_datos/gestor_base_datos.dart';
import '../modelos/log_zarpe_modelo.dart';
import '../../dominio/entidades/log_zarpe_entidad.dart';

/// Fuente de datos local para el sistema de auditoría de zarpes.
///
/// Implementa todas las operaciones CRUD sobre la tabla [zarpe_log] en SQLite.
class FuenteDatosLogLocal {
  /// Instancia del gestor singleton de la base de datos local.
  final _db = GestorBaseDatos.instance;

  /// Inserta un nuevo evento de log en SQLite.
  ///
  /// Throws [Exception] si la inserción falla.
  Future<void> insertarLog(LogZarpeEntidad log) async {
    try {
      final db = await _db.database;
      final modelo = LogZarpeModelo.fromEntidad(log);
      await db.insert('zarpe_log', modelo.toSqlite());
    } catch (e) {
      throw Exception('Error al guardar log de auditoría: $e');
    }
  }

  /// Obtiene todos los logs de un cuadre ordenados por timestamp descendente.
  Future<List<LogZarpeModelo>> obtenerPorCuadre(String cuadreId) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'zarpe_log',
        where: 'cuadre_id = ?',
        whereArgs: [cuadreId],
        orderBy: 'timestamp DESC',
      );
      return maps.map(LogZarpeModelo.fromSqlite).toList();
    } catch (e) {
      throw Exception('Error al leer logs de cuadre: $e');
    }
  }

  /// Obtiene todos los logs de un zarpe ordenados por timestamp descendente.
  Future<List<LogZarpeModelo>> obtenerPorZarpe(String zarpeId) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'zarpe_log',
        where: 'zarpe_id = ?',
        whereArgs: [zarpeId],
        orderBy: 'timestamp DESC',
      );
      return maps.map(LogZarpeModelo.fromSqlite).toList();
    } catch (e) {
      throw Exception('Error al leer logs de zarpe: $e');
    }
  }

  /// Retorna todos los logs que aún no han sido enviados a Supabase.
  Future<List<LogZarpeModelo>> obtenerPendientes() async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'zarpe_log',
        where: 'sincronizado = 0',
        orderBy: 'timestamp ASC',
      );
      return maps.map(LogZarpeModelo.fromSqlite).toList();
    } catch (e) {
      throw Exception('Error al leer logs pendientes: $e');
    }
  }

  /// Actualiza el flag de sincronización de un log específico.
  Future<void> marcarSincronizado(String logId) async {
    try {
      final db = await _db.database;
      await db.update(
        'zarpe_log',
        {'sincronizado': 1},
        where: 'id = ?',
        whereArgs: [logId],
      );
    } catch (e) {
      throw Exception('Error al marcar log como sincronizado: $e');
    }
  }
}
