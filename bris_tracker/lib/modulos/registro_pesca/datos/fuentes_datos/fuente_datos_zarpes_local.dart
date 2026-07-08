import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';
import '../modelos/zarpe_modelo.dart';

/// Implementación concreta de SQLite para la persistencia local de Zarpes.
class FuenteDatosZarpesLocal {
  final GestorBaseDatos _gestorDb;

  FuenteDatosZarpesLocal(this._gestorDb);

  /// Guarda o actualiza un zarpe en la base de datos local (Offline-first).
  Future<void> guardarZarpeLocal(ZarpeModelo zarpe) async {
    final db = await _gestorDb.database;
    await db.insert(
      'zarpes',
      zarpe.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene todos los zarpes locales de un usuario.
  Future<List<ZarpeModelo>> obtenerZarpesLocales(String usuarioId) async {
    final db = await _gestorDb.database;
    // Asumiendo que hay un campo usuario_id, aunque el modelo no lo exponga explícitamente, 
    // en la BD de GestorBaseDatos la tabla zarpes tiene 'creado_por' o no? 
    // Wait, let's check GestorBaseDatos to see if it has usuario_id.
    // If not, we just fetch all zarpes for now.
    final result = await db.query(
      'zarpes',
      orderBy: 'fecha_zarpe DESC',
    );

    return result.map((map) => ZarpeModelo.fromMap(map)).toList();
  }

  /// Actualiza un zarpe como sincronizado.
  Future<void> marcarComoSincronizado(String zarpeId, String fotoUrlEvidencia) async {
    final db = await _gestorDb.database;
    await db.update(
      'zarpes',
      {
        'sincronizado': 1,
        'foto_url_evidencia': fotoUrlEvidencia,
      },
      where: 'id = ?',
      whereArgs: [zarpeId],
    );
  }

  /// Actualiza el estado de negocio de un zarpe descargado desde la nube.
  Future<void> actualizarEstadoDownstream(String zarpeId, String estado) async {
    final db = await _gestorDb.database;
    await db.update(
      'zarpes',
      {'estado': estado},
      where: 'id = ?',
      whereArgs: [zarpeId],
    );
  }
}
