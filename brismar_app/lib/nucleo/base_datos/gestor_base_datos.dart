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
      version: 7,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Estructura inicial de las tablas en SQLite local.
  Future<void> _createDB(Database db, int version) async {
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
        pesador TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE compras (
        id TEXT PRIMARY KEY,
        cuadre_id TEXT NOT NULL,
        embarcacion TEXT NOT NULL,
        producto TEXT NOT NULL,
        kilos REAL DEFAULT 0,
        precio_unitario REAL DEFAULT 0,
        total REAL DEFAULT 0,
        FOREIGN KEY (cuadre_id) REFERENCES cuadres (id) ON DELETE CASCADE
      )
    ''');

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

  /// Migraciones incrementales.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Eliminar tabla vieja y crear estructura nueva
      await db.execute('DROP TABLE IF EXISTS registro_embarcaciones');
      await _createDB(db, newVersion);
    }
    if (oldVersion < 5) {
      // Agregar columnas para el zarpe de cámara
      await db.execute('ALTER TABLE cuadres ADD COLUMN foto_zarpe_url TEXT');
      await db.execute('ALTER TABLE cuadres ADD COLUMN peso_total REAL');
      await db.execute('ALTER TABLE cuadres ADD COLUMN cajas_llenas INTEGER');
      await db.execute('ALTER TABLE cuadres ADD COLUMN cajas_vacias INTEGER');
      await db.execute('ALTER TABLE cuadres ADD COLUMN tipo_producto INTEGER');
      await db.execute('ALTER TABLE cuadres ADD COLUMN planta_destino TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE cuadres ADD COLUMN pesador TEXT');
      // Agregar tabla de zarpes
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
    if (oldVersion < 7) {
      // Separar estado de negocio del estado de sincronización en zarpes.
      // 'sincronizado = 0' = pendiente de subir, 'sincronizado = 1' = ya en Supabase.
      await db.execute('ALTER TABLE zarpes ADD COLUMN sincronizado INTEGER DEFAULT 0');
    }
  }

  /// Cierra la base de datos cuando ya no se requiere.
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
