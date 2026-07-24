import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';
import '../modelos/zarpe_modelo.dart';

/// Implementación concreta de SQLite para la persistencia local de Zarpes.
///
/// **Alcance:** Un dispositivo físico corresponde a un único operador.
/// La tabla `zarpes` en SQLite no incluye `usuario_id` porque el aislamiento
/// de datos entre usuarios se garantiza por Supabase (RLS) al sincronizar,
/// no en la base de datos local.
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

  /// Obtiene todos los zarpes almacenados localmente en el dispositivo,
  /// ordenados del más reciente al más antiguo.
  ///
  /// No filtra por usuario porque la tabla local no tiene `usuario_id`.
  /// El aislamiento por usuario es responsabilidad de Supabase RLS.
  Future<List<ZarpeModelo>> obtenerZarpesLocales() async {
    final db = await _gestorDb.database;
    final result = await db.query('zarpes', orderBy: 'fecha_zarpe DESC');
    return result.map((map) => ZarpeModelo.fromMap(map)).toList();
  }

  /// Actualiza un zarpe como sincronizado.
  Future<void> marcarComoSincronizado(
    String zarpeId,
    String fotoUrlEvidencia,
  ) async {
    final db = await _gestorDb.database;
    await db.update(
      'zarpes',
      {'sincronizado': 1, 'foto_url_evidencia': fotoUrlEvidencia},
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
