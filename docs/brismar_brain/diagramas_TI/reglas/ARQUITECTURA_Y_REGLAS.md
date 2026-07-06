# 🏗️ Arquitectura y Reglas del Proyecto (BRISMAR)

Este documento contiene las directrices técnicas y arquitectónicas inmutables para el Monorepositorio de Brismar. Toda Inteligencia Artificial que escriba código aquí DEBE seguir estas reglas.

## 1. Patrones de Diseño Obligatorios (App Móvil - Flutter)

- **Clean Architecture:** El código está estrictamente separado en 3 capas (Datos, Dominio, Presentación).
- **Idioma del Código:** TODO el código (nombres de variables, clases, métodos) debe estar en Español para estandarización. Ejemplo: `FuenteDatos` en lugar de `Datasource`.
- **Inyección de Dependencias:** Uso de **Riverpod** para la gestión de estado.
- **Manejo de Errores:** Manejo explícito de excepciones con tipado fuerte. No se permiten simples `print(e)`.

## 2. Persistencia y Bóveda Segura (Offline-First)

- **SQLite Local (App Móvil):** La app está diseñada para funcionar sin internet ("Offline-first") en alta mar. Todos los registros críticos deben guardarse primero localmente.
- **Estado de Cifrado (SQLite normal):** Actualmente la base de datos SQLite se ejecuta sin cifrado completo.
- **Pendiente Crítico (SQLCipher):** Migrar a SQLCipher o un esquema de cifrado de base de datos equivalente antes de considerarse una versión segura para producción.
- **Validación de Hash (BCrypt):** Para autenticación offline, las contraseñas se almacenan localmente en formato hash utilizando BCrypt. JAMÁS guardar contraseñas en texto plano.

## 3. Entorno de Datos (Supabase como Fuente Única de Verdad)

- **Convivencia (App y Web):** Supabase PostgreSQL será la fuente única de verdad para todo el ecosistema. Tanto `brismar_app` (App) como `brismar_web` (Web) leen y escriben del mismo esquema de datos. NO realizar migraciones destructivas (borrar columnas o alterar tipos de datos) sin validar compatibilidad en ambas plataformas.
- **Gestión de Secretos:** TODAS las URL y Anon Keys deben leerse desde el entorno. En la máquina local del desarrollador están almacenadas en `CREDENCIALES_MAESTRAS.env` (que nunca se sube a GitHub).

---

## 🔗 Enlaces Relacionados (Cerebro Obsidian)

- Conoce cómo se desarrolla y las reglas de GitHub en: [[FLUJO_DE_TRABAJO]]
- Para entender por qué tomamos estas decisiones offline, lee: [[HISTORIAL_Y_CONTEXTO]]
