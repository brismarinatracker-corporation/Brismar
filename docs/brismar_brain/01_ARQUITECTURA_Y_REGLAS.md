# 🏗️ Arquitectura y Reglas del Proyecto (BRISMAR)

Este documento contiene las directrices técnicas y arquitectónicas inmutables para el Monorepositorio de Brismar. Toda Inteligencia Artificial que escriba código aquí DEBE seguir estas reglas.

## 1. Patrones de Diseño Obligatorios (App Móvil - Flutter)
- **Clean Architecture:** El código está estrictamente separado en 3 capas (Datos, Dominio, Presentación). 
- **Idioma del Código:** TODO el código (nombres de variables, clases, métodos) debe estar en Español para estandarización. Ejemplo: `FuenteDatos` en lugar de `Datasource`.
- **Inyección de Dependencias:** Uso de **Riverpod** para la gestión de estado.
- **Manejo de Errores:** Manejo explícito de excepciones con tipado fuerte. No se permiten simples `print(e)`.

## 2. Persistencia y Bóveda Segura (Offline-First)
- **SQLite Local (App Móvil):** La app está diseñada para funcionar sin internet ("Offline-first") en alta mar. Todos los registros críticos deben guardarse primero localmente.
- **SQLCipher / Encriptación:** Evaluar constantemente el riesgo de robo físico del dispositivo. Las bases de datos locales y preferencias deben estar encriptadas.
- **Validación de Hash (SHA-256):** Las contraseñas de los usuarios se guardan hasheadas localmente para permitir el login sin conexión a internet. JAMÁS enviar contraseñas en texto plano por la red o guardarlas sin hashear en local.

## 3. Entorno de Datos (Supabase)
- **Convivencia (App y Web):** `brismar_app` (App) y `brismar_web` (Web) consumen el mismo proyecto de Supabase. NO hacer migraciones destructivas (borrar columnas o cambiar tipos de datos) que puedan romper la otra plataforma.
- **Gestión de Secretos:** TODAS las URL y Anon Keys deben leerse desde el entorno. En la máquina local del desarrollador están almacenadas en `CREDENCIALES_MAESTRAS.env` (que nunca se sube a GitHub).
