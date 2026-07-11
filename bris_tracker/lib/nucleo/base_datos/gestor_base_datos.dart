import 'package:sqflite_sqlcipher/sqflite.dart';
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
      version: 10,
      password: 'BRISMAR_SECURE_KEY_2026',
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Estructura inicial de las tablas en SQLite local.
  Future<void> _createDB(Database db, int version) async {
    await _createTablaCuadres(db);
    await _createTablaCompras(db);
    await _createTablaGastos(db);
    await _createTablaVentas(db);
    await _createTablaZarpes(db);
    await _createTablaCamaras(db);
  }

  /// Crea la tabla 'cuadres' en SQLite local.
  Future<void> _createTablaCuadres(Database db) async {
    await db.execute('''
      CREATE TABLE cuadres (
        id TEXT PRIMARY KEY,
        usuario_id TEXT NOT NULL,
        placa TEXT NOT NULL,
        fecha_zarpe TEXT,
        fecha_cuadre TEXT,
        estado TEXT DEFAULT 'borrador',
        url_pdf_cloud TEXT,
        url_excel_cloud TEXT,
        sincronizado INTEGER DEFAULT 0,
        foto_zarpe_url TEXT,
        peso_total REAL,
        cajas_llenas INTEGER,
        cajas_vacias INTEGER,
        tipo_producto INTEGER,
        planta_destino TEXT,
        pesador TEXT,
        tipo TEXT,
        cuadrilla TEXT
      )
    ''');
  }

  /// Crea la tabla 'compras' en SQLite local.
  Future<void> _createTablaCompras(Database db) async {
    await db.execute('''
      CREATE TABLE compras (
        id TEXT PRIMARY KEY,
        cuadre_id TEXT NOT NULL,
        embarcacion TEXT NOT NULL,
        producto TEXT NOT NULL,
        kilos REAL DEFAULT 0,
        precio_unitario REAL DEFAULT 0,
        adelanto REAL DEFAULT 0,
        total REAL DEFAULT 0,
        FOREIGN KEY (cuadre_id) REFERENCES cuadres (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Crea la tabla 'gastos' en SQLite local.
  Future<void> _createTablaGastos(Database db) async {
    await db.execute('''
      CREATE TABLE gastos (
        id TEXT PRIMARY KEY,
        cuadre_id TEXT NOT NULL,
        tipo TEXT NOT NULL,
        concepto TEXT NOT NULL,
        cantidad REAL DEFAULT 0,
        costo_unitario REAL DEFAULT 0,
        total REAL DEFAULT 0,
        FOREIGN KEY (cuadre_id) REFERENCES cuadres (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Crea la tabla 'ventas' en SQLite local.
  Future<void> _createTablaVentas(Database db) async {
    await db.execute('''
      CREATE TABLE ventas (
        id TEXT PRIMARY KEY,
        cuadre_id TEXT NOT NULL,
        lugar TEXT NOT NULL,
        producto TEXT NOT NULL,
        kilos REAL DEFAULT 0,
        precio_unitario REAL DEFAULT 0,
        total REAL DEFAULT 0,
        FOREIGN KEY (cuadre_id) REFERENCES cuadres (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Crea la tabla 'zarpes' en SQLite local.
  Future<void> _createTablaZarpes(Database db) async {
    await db.execute('''
      CREATE TABLE zarpes (
        id TEXT PRIMARY KEY,
        placa_camara TEXT NOT NULL,
        chofer TEXT NOT NULL,
        muelle_partida TEXT NOT NULL,
        foto_url_evidencia TEXT,
        foto_local_path TEXT,
        fecha_zarpe TEXT NOT NULL,
        estado TEXT DEFAULT 'DESPACHADO_PIURA',
        sincronizado INTEGER DEFAULT 0
      )
    ''');
  }

  /// Crea la tabla 'camaras' en SQLite local (para autocompletado de placas).
  Future<void> _createTablaCamaras(Database db) async {
    await db.execute('''
      CREATE TABLE camaras (
        id TEXT PRIMARY KEY,
        placa TEXT NOT NULL UNIQUE,
        sincronizado INTEGER DEFAULT 1
      )
    ''');
  }

  /// Migraciones de la base de datos local.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await _upgradeA4(db, newVersion);
    }
    if (oldVersion < 5) {
      await _upgradeA5(db);
    }
    if (oldVersion < 6) {
      await _upgradeA6(db);
    }
    if (oldVersion < 7) {
      await _upgradeA7(db);
    }
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE compras ADD COLUMN adelanto REAL DEFAULT 0');
    }
    if (oldVersion < 9) {
      await _upgradeA9(db);
    }
    if (oldVersion < 10) {
      await _createTablaCamaras(db);
    }
  }

  /// Migración: Eliminar tabla vieja y crear estructura nueva.
  Future<void> _upgradeA4(Database db, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS registro_embarcaciones');
    await _createDB(db, newVersion);
  }

  /// Migración: Agregar columnas para el zarpe de cámara.
  Future<void> _upgradeA5(Database db) async {
    await db.execute('ALTER TABLE cuadres ADD COLUMN foto_zarpe_url TEXT');
    await db.execute('ALTER TABLE cuadres ADD COLUMN peso_total REAL');
    await db.execute('ALTER TABLE cuadres ADD COLUMN cajas_llenas INTEGER');
    await db.execute('ALTER TABLE cuadres ADD COLUMN cajas_vacias INTEGER');
    await db.execute('ALTER TABLE cuadres ADD COLUMN tipo_producto INTEGER');
    await db.execute('ALTER TABLE cuadres ADD COLUMN planta_destino TEXT');
  }

  /// Migración: Agregar columna pesador y tabla de zarpes.
  Future<void> _upgradeA6(Database db) async {
    await db.execute('ALTER TABLE cuadres ADD COLUMN pesador TEXT');
    await db.execute('''
      CREATE TABLE zarpes (
        id TEXT PRIMARY KEY,
        placa_camara TEXT NOT NULL,
        chofer TEXT NOT NULL,
        muelle_partida TEXT NOT NULL,
        foto_url_evidencia TEXT,
        foto_local_path TEXT,
        fecha_zarpe TEXT NOT NULL,
        estado TEXT DEFAULT 'DESPACHADO_PIURA'
      )
    ''');
  }

  /// Migración: Separar estado de negocio de sincronización en zarpes.
  Future<void> _upgradeA7(Database db) async {
    await db.execute('ALTER TABLE zarpes ADD COLUMN sincronizado INTEGER DEFAULT 0');
  }

  Future<void> _upgradeA9(Database db) async {
    await db.execute('ALTER TABLE cuadres ADD COLUMN tipo TEXT');
    await db.execute('ALTER TABLE cuadres ADD COLUMN cuadrilla TEXT');
  }

  /// Cierra la base de datos cuando ya no se requiere.
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
