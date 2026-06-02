# ☁️ Supabase

> Backend en la nube (BaaS) de BRISMAR para sincronización de datos remotos y autenticación de usuarios.
> Usado en: [[MODULO_AUTENTICACION]] · [[MODULO_REGISTRO]]

---

## Configuración Técnica
- **Archivo de configuración**: `lib/nucleo/red/supabase_client.dart`
- **Clase**: `SupabaseConfig`
- Contiene variables estáticas para `url` (actualmente `https://tu-proyecto-supabase.supabase.co`) y `anonKey`.
- **Inicialización**: Se ejecuta en `main.dart` mediante `SupabaseConfig.inicializar()`.

---

## Integración con Fuentes de Datos (Remote Datasources)

### 1. Autenticación (`AuthRemotoDatasource`)
- Habla directamente con `Supabase.instance.client.auth` para validar credenciales.
- Si la URL está configurada como plantilla por defecto, la app entra en **modo simulación** local para permitir pruebas rápidas con el usuario `usuario` y la clave `1234`.

### 2. Base de Datos (`RegistroRemotoDatasource`)
- **Tabla remota**: `registro_embarcaciones` en PostgreSQL.
- **Inserción en lote (Bulk Upsert)**: `subirRegistros(List<RegistroModelo> registros)` usa la API `.upsert()` de Supabase. Esto asegura que si se reintenta subir registros debido a microcortes de red, no se dupliquen registros en la nube (upsert identifica filas duplicadas mediante el campo `id`).
- **Descarga de Historial**: `obtenerHistorialRemoto()` consulta los registros ordenándolos por `fecha DESC, hora DESC`.

---

## Esquema de Base de Datos Remota (PostgreSQL)

La tabla remota `registro_embarcaciones` cuenta con la misma estructura de columnas que [[SQLite]], excepto la columna `sincronizado`, ya que por definición, todo registro en Supabase ya está sincronizado.

#brismar #tecnologia #supabase #backend
