import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../../../nucleo/base_datos/gestor_base_datos.dart';
import '../../../../nucleo/errores/diccionario_errores.dart';
import '../modelos/cuadre_modelo.dart';

/// Fuente de datos local para la persistencia de cuadres en SQLite.
class FuenteDatosCuadresLocal {
  final GestorBaseDatos _gestorBD;

  /// Constructor de [FuenteDatosCuadresLocal].
  FuenteDatosCuadresLocal(this._gestorBD);

  /// Guarda un cuadre completo de forma transaccional localmente.
  Future<void> guardarCuadreCompleto(CuadreModelo cuadre) async {
    try {
      final db = await _gestorBD.database;

      await db.transaction((txn) async {
        await txn.insert(
          'cuadres',
          cuadre.toSqlite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await _limpiarTablasRelacionadas(txn, cuadre.id);
        await _insertarRelaciones(txn, cuadre);
      });
    } catch (e) {
      throw const ExcepcionBaseDatos(
        mensaje: 'Error guardando cuadre en SQLite',
      );
    }
  }

  /// Limpia las relaciones existentes asociadas a un cuadre.
  Future<void> _limpiarTablasRelacionadas(
    Transaction txn,
    String cuadreId,
  ) async {
    await txn.delete('compras', where: 'cuadre_id = ?', whereArgs: [cuadreId]);
    await txn.delete('gastos', where: 'cuadre_id = ?', whereArgs: [cuadreId]);
    await txn.delete('ventas', where: 'cuadre_id = ?', whereArgs: [cuadreId]);
  }

  /// Inserta las relaciones de compras, gastos y ventas asociadas a un cuadre.
  Future<void> _insertarRelaciones(Transaction txn, CuadreModelo cuadre) async {
    for (var compra in cuadre.compras) {
      final cModelo = compra is CompraModelo
          ? compra
          : CompraModelo.fromEntidad(compra);
      await txn.insert('compras', cModelo.toSqlite());
    }

    for (var gasto in cuadre.gastos) {
      final gModelo = gasto is GastoModelo
          ? gasto
          : GastoModelo.fromEntidad(gasto);
      await txn.insert('gastos', gModelo.toSqlite());
    }

    for (var venta in cuadre.ventas) {
      final vModelo = venta is VentaModelo
          ? venta
          : VentaModelo.fromEntidad(venta);
      await txn.insert('ventas', vModelo.toSqlite());
    }
  }

  /// Obtiene todos los cuadres locales para un usuario en específico.
  Future<List<CuadreModelo>> obtenerCuadres(String usuarioId) async {
    try {
      final db = await _gestorBD.database;
      final cuadresMaps = await db.query(
        'cuadres',
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
        orderBy: 'fecha_zarpe DESC',
      );

      List<CuadreModelo> cuadres = [];
      for (var map in cuadresMaps) {
        cuadres.add(await _cargarRelacionesCuadre(db, map));
      }
      return cuadres;
    } catch (e) {
      throw const ExcepcionBaseDatos(
        mensaje: 'Error leyendo cuadres de SQLite',
      );
    }
  }

  /// Carga y llena las listas de compras, gastos y ventas de un cuadre.
  Future<CuadreModelo> _cargarRelacionesCuadre(
    Database db,
    Map<String, dynamic> map,
  ) async {
    final id = map['id'] as String;

    final comprasMaps = await db.query(
      'compras',
      where: 'cuadre_id = ?',
      whereArgs: [id],
    );
    final gastosMaps = await db.query(
      'gastos',
      where: 'cuadre_id = ?',
      whereArgs: [id],
    );
    final ventasMaps = await db.query(
      'ventas',
      where: 'cuadre_id = ?',
      whereArgs: [id],
    );

    final compras = comprasMaps.map((c) => CompraModelo.fromSqlite(c)).toList();
    final gastos = gastosMaps.map((g) => GastoModelo.fromSqlite(g)).toList();
    final ventas = ventasMaps.map((v) => VentaModelo.fromSqlite(v)).toList();

    var cuadre = CuadreModelo.fromSqlite(map);
    return CuadreModelo(
      id: cuadre.id,
      usuarioId: cuadre.usuarioId,
      placa: cuadre.placa,
      fechaZarpe: cuadre.fechaZarpe,
      fechaCuadre: cuadre.fechaCuadre,
      estado: cuadre.estado,
      urlPdfCloud: cuadre.urlPdfCloud,
      urlExcelCloud: cuadre.urlExcelCloud,
      sincronizado: cuadre.sincronizado,
      fotoZarpeUrl: cuadre.fotoZarpeUrl,
      pesoTotal: cuadre.pesoTotal,
      cajasLlenas: cuadre.cajasLlenas,
      cajasVacias: cuadre.cajasVacias,
      tipoProducto: cuadre.tipoProducto,
      muellePartida: cuadre.muellePartida,
      pesador: cuadre.pesador,
      compras: compras,
      gastos: gastos,
      ventas: ventas,
    );
  }

  /// Actualiza los metadatos de sincronización de un cuadre local.
  Future<void> marcarComoSincronizado(
    String id,
    String? urlPdf,
    String? urlExcel,
    String? urlFotoZarpe,
  ) async {
    try {
      final db = await _gestorBD.database;
      await db.update(
        'cuadres',
        {
          'sincronizado': 1,
          'url_pdf_cloud': urlPdf,
          'url_excel_cloud': urlExcel,
          'foto_zarpe_url': urlFotoZarpe,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw const ExcepcionBaseDatos(
        mensaje: 'Error actualizando estado de sincronización',
      );
    }
  }
}
