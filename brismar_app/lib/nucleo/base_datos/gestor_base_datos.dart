import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Clase auxiliar para la gestión de la base de datos local SQLite.
/// Implementa el patrón Singleton.
class GestorBaseDatos {
  static final GestorBaseDatos instance = GestorBaseDatos._init();
  static Database? _database;

  GestorBaseDatos._init();

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
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Estructura inicial de las tablas en SQLite local.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registro_embarcaciones (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        nombre_embarcacion TEXT NOT NULL,
        producto TEXT NOT NULL,
        placa_carro TEXT,
        kilos REAL NOT NULL,
        precio_por_kilo REAL NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        muelle_inicio TEXT NOT NULL,
        cajas INTEGER DEFAULT 0,
        gasto_facturacion REAL DEFAULT 0,
        gasto_personal REAL DEFAULT 0,
        gasto_apoyo REAL DEFAULT 0,
        gasto_agua REAL DEFAULT 0,
        gasto_clorox REAL DEFAULT 0,
        gasto_flete REAL DEFAULT 0,
        gasto_hielo REAL DEFAULT 0,
        gasto_pesador REAL DEFAULT 0,
        gasto_otros REAL DEFAULT 0,
        observaciones TEXT,
        sincronizado INTEGER DEFAULT 0
      )
    ''');
  }

  /// Migraciones incrementales para instalaciones que ya tienen datos locales.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE registro_embarcaciones ADD COLUMN usuario_id TEXT',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE registro_embarcaciones ADD COLUMN cajas INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE registro_embarcaciones ADD COLUMN gasto_pesador REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE registro_embarcaciones ADD COLUMN observaciones TEXT',
      );
    }
  }

  /// Cierra la base de datos cuando ya no se requiere.
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
