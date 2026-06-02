# 💾 SQLite

> Motor de base de datos local y relacional integrado en el teléfono para soportar la arquitectura offline-first de BRISMAR.
> Usado en: [[MODULO_REGISTRO]]

---

## Inicialización y Singleton
- **Archivo**: `lib/nucleo/base_datos/database_helper.dart`
- **Clase**: `DatabaseHelper` (Implementa el patrón Singleton mediante `DatabaseHelper.instance`).
- **Base de datos física**: Guarda el archivo `brismar_local.db` en el directorio de documentos del teléfono.
- **Versión**: `1`

---

## Estructura de la Tabla: `registro_embarcaciones`
La tabla se crea mediante la siguiente instrucción SQL en la inicialización:
```sql
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
  sincronizado INTEGER DEFAULT 0 -- 0: Pendiente, 1: Sincronizado
)
```

---

## Consultas de Datos (`RegistroLocalDatasource`)
La clase `RegistroLocalDatasource` realiza operaciones directas sobre esta tabla:
1. **`guardarRegistro(RegistroModelo modelo)`**: Inserta o sobrescribe un registro usando `ConflictAlgorithm.replace`.
2. **`obtenerHistorialLocal()`**: Devuelve todos los registros ordenados de forma descendente por `fecha DESC, hora DESC`.
3. **`obtenerPendientesSincronizar()`**: Consulta registros donde `sincronizado = 0` para subirlos a [[Supabase]].
4. **`marcarComoSincronizados(List<String> ids)`**: Realiza una transacción de escritura por lotes para marcar múltiples registros con `sincronizado = 1`.

#brismar #tecnologia #sqlite #local
