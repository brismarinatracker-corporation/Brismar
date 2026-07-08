# 🗄️ Base de Datos Local (SQLite)

Permite el funcionamiento "offline-first" de BRISMAR APP. Cuando el operario está en alta mar sin internet, la información se almacena aquí.

## Archivos Principales
📁 `bris_tracker/lib/nucleo/base_datos/gestor_base_datos.dart`
📁 `bris_tracker/lib/nucleo/base_datos/tablas.dart`

## Funcionalidad Central
- **Patrón Singleton**: Garantiza que exista una única conexión abierta al archivo `brismar.db` de SQLite en todo momento.
- **Tablas Definidas**: Crea y mantiene las tablas `cuadres` y `zarpes`.

Ejemplo de esquema en `tablas.dart`:
```sql
CREATE TABLE zarpes (
  id TEXT PRIMARY KEY,
  fecha TEXT,
  sincronizado INTEGER DEFAULT 0,
  -- demás campos
)
```

## Relación con Módulos
El [[MODULO_REGISTRO]] consulta a `gestor_base_datos.dart` a través de su Fuente de Datos Local (`fuente_datos_cuadres_local.dart`) para extraer los registros con `sincronizado = 0` y enviarlos a [[Supabase]] cuando vuelva la red.

---
#brismar #datos #sqlite #local #offline #nodo
