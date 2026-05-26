import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Clase auxiliar para la gestión de la base de datos local SQLite.
/// Implementa el patrón Singleton.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Obtiene la instancia activa de la base de datos local.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('brismar_local.db');
    return _database!;
  }

  /// Inicializa la base de datos en la ruta del dispositivo.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Estructura inicial de las tablas en SQLite local.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registro_embarcaciones (
        id TEXT PRIMARY KEY,
        nombre_embarcacion TEXT NOT NULL,
        producto TEXT NOT NULL,
        placa_carro TEXT,
        kilos REAL NOT NULL,
        precio_por_kilo REAL NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        muelle_inicio TEXT NOT NULL,
        gasto_facturacion REAL DEFAULT 0,
        gasto_personal REAL DEFAULT 0,
        gasto_apoyo REAL DEFAULT 0,
        gasto_agua REAL DEFAULT 0,
        gasto_clorox REAL DEFAULT 0,
        gasto_flete REAL DEFAULT 0,
        gasto_hielo REAL DEFAULT 0,
        gasto_otros REAL DEFAULT 0,
        sincronizado INTEGER DEFAULT 0
      )
    ''');
  }

  /// Cierra la base de datos cuando ya no se requiere.
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
