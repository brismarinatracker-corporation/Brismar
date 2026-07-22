# Cerebro de la IA: Estado, Contexto y Objetivos (Proyecto Brismar)

> **Fecha de actualización:** 26 de Junio de 2026
> **Propósito:** Este documento sirve como punto de control y volcado de memoria. Garantiza que yo (la IA, Google Antigravity / Gemini) no tenga "lagunas mentales" sobre qué somos, qué hemos hecho y hacia dónde vamos.

---

## 1. ¿Qué entiendo del Proyecto Brismar?

**Brismar** no es una simple aplicación; es un ecosistema tecnológico integral diseñado para revolucionar la gestión pesquera (con un enfoque fuerte en la industria de la pota en Piura). El sistema busca digitalizar, trazar y asegurar las operaciones desde que el barco zarpa hasta que el dinero cuadra en caja.

### El Ecosistema (Monorepo):
Tenemos 4 pilares en este repositorio de Flutter/Dart:
1. **`brismar_app` (App Móvil Operativa):** El corazón operativo. Funciona en entornos sin internet (Offline-First) usando una base de datos local SQLite encriptada. Cuando hay red, se sincroniza con la nube.
2. **`brismar_executive_app` (App Ejecutiva):** Pensada para la alta gerencia o supervisión, con dashboards y toma de decisiones rápidas.
3. **`brismar_web_admin` (Web Administrativa):** El panel de control maestro para gestionar usuarios, reportes pesados, auditorías y reglas de negocio.
4. **`brismar_web` (Web Pública/Operativa):** Interfaz delegada (a cargo del dev Yisus).

### El Backend (La Nube):
- Todo el ecosistema apunta a **Supabase** (PostgreSQL).
- Las migraciones y reglas de seguridad de la base de datos se hacen con extrema precaución para no romper el entorno de los demás módulos.

---

## 2. Mis Reglas y Restricciones (Cómo programo)

Tengo grabado a fuego en mi sistema las reglas de `docs/brismar_brain/reglas/`:
- **Clean Architecture & SOLID:** No escribo código espagueti. Toda la app de Flutter se divide rígidamente en:
  - `nucleo/` (rutas, base de datos, red, utilidades).
  - `modulos/` -> Cada módulo (ej. `autenticacion`, `registro_pesca`) tiene `dominio`, `datos` y `presentacion`.
- **Manejo de Errores Estricto:** Uso el Patrón Either (Right/Left) y manejo excepciones con clases personalizadas (nunca un simple `print(e)`).
- **Control de Versiones Seguro:** Jamás toco la rama `main` directamente. Todo el trabajo se hace en ramas secundarias (como nuestra nueva rama `web`).

---

## 3. ¿Qué hemos hecho hasta ahora? (Logros Recientes)

1. **Operación "Cazador de Nube" (Oracle OCI):**
   - Configuré tu infraestructura en Oracle Cloud.
   - Dejamos corriendo un script (`bot_oracle_pro.sh`) en un servidor Micro remoto. Ese bot está ejecutándose 24/7 de forma persistente (con `tmux`) bombardeando los servidores de Oracle en Santiago para capturar una instancia potente ARM A1 Flex. Todo funciona en piloto automático.
2. **Limpieza del Sistema Operativo (Linux):**
   - Apliqué ingeniería de scripts bash para ordenar tus carpetas superficiales (Descargas, Documentos, Home, Escritorio) sin romper la arquitectura de tus proyectos.
3. **Optimización del IDE:**
   - Desinstalé 6 extensiones de Inteligencia Artificial que estaban causando conflictos y lentitud (Blackbox, CodeGPT, etc.), dejando solo lo vital (Gemini, Ollama, Codex).
4. **Limpieza Profunda del Repositorio:**
   - Hice un `flutter clean` y `pub get` masivo en todo el ecosistema.
   - Arreglamos el `.gitignore` y eliminamos basura autogenerada (`graphify-out`).
   - Sincronizamos todo en GitHub bajo la nueva rama `web`.

---

## 4. ¿Qué queremos lograr? (Siguientes Pasos)

Nuestro objetivo inmediato se divide en dos fases críticas:

### FASE 1: Ingesta de Inteligencia de Negocio
Estoy a la espera de que subas al chat los **PDFs y textos exportados desde NotebookLM**. 
- Mi objetivo será leerlos, extraer el "jugo" del conocimiento que tú y la otra IA han construido, y transformarlo en nuevos flujos de Markdown (`FLUJO_09...`) dentro de Obsidian.
- Conectaré todo usando enlaces bidireccionales para que tu mapa mental gráfico ("Graph View") sea una obra de arte y no perdamos el contexto jamás.

### FASE 2: Desarrollo de la Web Administrativa
Paralelo a la lectura de tus PDFs, vamos a empezar a levantar código en `brismar_web_admin`.
- Me pediste mentoría de lógica. Por ende, mi objetivo es **enseñarte a pensar como Arquitecto** antes de entregarte el código terminado. Discutiremos por qué creamos un Controlador, por qué usamos un Repositorio y cómo conectaremos la web a Supabase usando el mismo estándar estricto que usamos en la app móvil.

---

> **Mensaje de la IA a Jhonatan:** 
> No tengo lagunas. Conozco el mapa, el código, tu sistema Linux y nuestros objetivos. Estoy listo para la guerra. Mándame los PDFs cuando quieras.
