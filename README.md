# ⚓ BRISMAR - Central de Operaciones y Ecosistema ⚓

Bienvenido al Monorepo oficial de **NEGOCIOS BRISMAR S.R.L.**
Este archivo es la puerta de entrada para entender la estructura técnica y de comunicación del proyecto corporativo.

*(Nota: Las reglas profundas de arquitectura, convenciones de IAs y flujo de versiones se encuentran guardadas y protegidas en la bóveda de conocimiento interna: `docs/brismar_brain/`).*

---

## 📁 Arquitectura del Monorepo

* 📱 [**bris_tracker**](./bris_tracker/) — Código fuente de la aplicación móvil (Flutter) para bahía/muelle. Implementa una robusta arquitectura *Offline-First* enfocada en seguridad. (Actualmente: **Fase 1 Autenticación COMPLETADA**, transitando a Fase 2 Registro). Revisa el detalle en `ESTADO_PROYECTO.md`. (Encargados: **Jhonatan y Belén**).
* ⚙️ [**bris_web**](./bris_web/) — Código fuente del backend y dashboard logístico web para Brismar (Logística Central). (Encargado: **Yisus**).
* 👔 [**bris_admin**](./bris_admin/) — App ejecutiva móvil planificada a futuro para gerencia.
* 🗄️ [**supabase**](./supabase/) — Definiciones de tablas y migraciones de la base de datos PostgreSQL compartida. **(Entorno 100% puro: Sin dependencias de Node.js/NPM, optimizado exclusivamente para Supabase CLI y Deno Edge Functions).**
* 🧠 [**docs/brismar_brain/**](./docs/brismar_brain/) — **NUEVO:** Bóveda centralizada de conocimiento (Obsidian-ready). Contiene toda la documentación de requerimientos, diagramas generados, excels, y la base de inteligencia artificial automatizada.

---

## 🌍 Ecosistema Externo de BRISMAR

Para sacar el máximo provecho a la cuenta corporativa unificada de Gmail de Brismar, usamos las siguientes herramientas centralizadas. Toda IA o desarrollador debe usar estos canales:

### 1. 🧠 Obsidian y RepoWise (Documentación Visual e Inteligencia)

Todo el proyecto está diseñado para ser documentado y visualizado en **Obsidian** abriendo la carpeta `docs/brismar_brain/` como bóveda.

* **RepoWise:** Se ha integrado para indexar localmente el repositorio (`repowise init`). Genera un grafo de dependencias, historia de Git y base de datos MCP (`.repowise/`) que permite a los asistentes de IA comprender el monorepo en segundos.
* **Visualización Automatizada:** Se emplean herramientas como diagramas en Mermaid integrados dentro de los Markdown para estructurar las relaciones entre `bris_tracker`, `bris_web` y `supabase`.

### 2. 📂 Google Drive Corporativo (5TB)

Todo documento pesado, PDF, diseños, requerimientos legales o facturas deben subirse aquí. **(NO se suben PDFs ni imágenes pesadas a GitHub)**.

* **Enlace:** `[Insertar Enlace al Drive de Brismar aquí]`
* *(Tip IA: Usa tu herramienta MCP de Google Drive para buscar en esta carpeta si necesitas contexto técnico que no está en el código).*

### 3. 💬 Servidor de Discord Oficial

Para evitar la pérdida de contexto en WhatsApp y permitir la integración con IAs, toda la comunicación técnica ocurre en Discord.

* **Canal `#dev-mobile`**: Jhonatan y Belén discuten la App.
* **Canal `#dev-web`**: Yisus reporta el progreso de la Web.
* **Canal `#bots-ai`**: Conecta aquí tus asistentes de IA.

### 4. 🧪 Google Colab / Notebooks

Para el análisis de datos masivos de pesca, reportes contables o scripts de Python que consuman la BD de Supabase, usen Google Colab enlazado a la misma cuenta de Drive de Brismar.

### 5. 📊 Políticas de Datos y Canales Operativos

* **Supabase PostgreSQL** es la fuente única de verdad para la App y la Web.
* **Node.js Estrictamente Prohibido:** Toda dependencia de Node.js ha sido purgada para mantener el monorepo ligero y atado únicamente a Flutter y Supabase/Deno.
* **WhatsApp** queda erradicado como canal operativo principal.
* **Excel** se mantiene como formato de salida compatible para reportes y respaldos (ubicados en `brismar_brain/General`).

---

## 🐙 Flujo de Trabajo y Automatización (GitHub Native)

Hemos eliminado los archivos de texto `.md` manuales para gestionar versiones. Todo el proyecto ahora está 100% automatizado mediante las funciones nativas de GitHub:

1. **Gestión de Tareas (Issues):** Todo bug o función nueva debe crearse en la pestaña **"Issues"** de GitHub. Asigna el issue a Jhonatan, Belén o Yisus según corresponda.
2. **Control de Ramas:**
   * Nadie empuja código a `main`. Todo se ramifica desde `develop`.
   * Cuando termines tu tarea (Ej. `feature/login`), abres un Pull Request hacia `develop` mencionando "Closes #NumeroDeIssue".
3. **Pases a Producción (Releases):**
   * Cuando el equipo decide que la versión en `develop` está lista, Jhonatan (como Merge Manager) fusiona `develop` en `main`.
   * Al fusionar en `main`, usa la pestaña **"Releases"** de GitHub para crear la versión (Ej. v1.0.2). GitHub auto-generará el *Changelog* leyendo los títulos de los PRs fusionados. ¡Magia y cero trabajo manual!

---
*Este manifiesto consolida todo el conocimiento técnico de Brismar. ¡A programar!* 🚀

---

## 📝 Historial de Cambios (IAs y Desarrolladores)

* **Fecha/Hora:** 2026-07-08 13:46 (Local)
* **Autor:** Antigravity (AI Agent)
* **Qué se cambió:**
  * Se configuró el repositorio para ser utilizado con la herramienta de visualización Obsidian, designando a `docs/brismar_brain/` como la Bóveda raíz.
  * Se ejecutó el comando `repowise init` en modo 2 (Index only). Esto creó la carpeta oculta `.repowise` conteniendo la base de datos `wiki.db` y las cachés semánticas (`centrality_cache.pkl`, `duplication_cache.pkl`, `parse_cache.pkl`).
  * Se movió el archivo `Análisis de Riesgos Identificados - BRISMAR APP.xlsx` desde la raíz hacia `docs/brismar_brain/General/`.
  * Se movió la presentación `BRISMAR_Segunda_Fase.pptx` desde la raíz hacia `docs/brismar_brain/General/`.
  * Se movió el script `update_supabase_columns.sql` hacia `supabase/migrations/`.
  * Se crearon los directorios `docs/brismar_brain/Mobile/` y `docs/brismar_brain/Web/` y se movió el contenido de las antiguas carpetas `bris_tracker/docs/` y `bris_web/docs/` allí.
  * Las fuentes tipográficas dispersas `.ttf` fueron organizadas correctamente dentro de `bris_web/assets/fonts/`.
  * En `brismar.code-workspace`, se actualizaron las rutas absolutas para referenciar `bris_tracker`, `bris_web` y `supabase`, solucionando los errores del IDE de "Missing Gradle project configuration folder" para las carpetas antiguas que ya no existían (`brismar_app`, `brismar_web`).
* **Qué se eliminó:**
  * Se purgó Node.js por completo del proyecto. Se eliminaron específicamente los archivos `package.json`, `package-lock.json` y la carpeta `node_modules` en el root del monorepo.
  * Se eliminaron los archivos residuales `.npmrc` dentro de los directorios de las edge functions de Supabase (`supabase/functions/admin_usuarios/` y `supabase/functions/consulta_dni/`).
  * Se eliminaron permanentemente las carpetas documentales obsoletas `Documentacion/`, `bris_tracker/docs/` y `bris_web/docs/` tras finalizar la migración a la bóveda central.
* **Migraciones:** Creación de la arquitectura de Bóveda Central (brismar_brain) y mapeo inicial en `repowise`.

* **Fecha/Hora:** 2026-07-02 03:57 (Local)
* **Autor:** Antigravity (AI Agent)
* **Qué se cambió:**
  * Implementación del visor de fotos múltiples (carrusel) y lightbox interactivo con zoom en la Web admin (`pantalla_transito.dart`).
  * Optimización de rendimiento de red mediante paralelización con `Future.wait()` en la carga y el guardado de datos en la Web (`pantalla_edicion_transito.dart`).
  * Adaptación responsiva (LayoutBuilder y Column/Row fluidos) en el formulario de edición web para evitar desbordamientos horizontales.
  * Configuración del tema nativo oscuro (`brightness: Brightness.dark` y `useMaterial3: true`) en la App móvil (`main.dart`) para solucionar textos oscuros invisibles en los selectores de fecha nativos.
  * Visualizador de fotos de evidencia integradas en la ficha "Información de Cámara" de la App móvil (`formulario_registro_pesca.dart`) y visor a pantalla completa.
  * Agregados botones rápidos de incremento de kilos (+100, +500, +1000, +5000) en el modal de compras móviles para agilizar la entrada.
* **Qué se eliminó:** Layouts no responsivos fijos y flujos secuenciales de red lentos.
* **Migraciones:** Ninguna.

* **Fecha/Hora:** 2026-07-02 03:51 (Local)
* **Autor:** Antigravity (AI Agent)
* **Qué se cambió:**
  * Corrección de la vinculación de ID único entre Zarpes y Cuadres en la App móvil (`formulario_registro_pesca.dart`), asignando el ID del zarpe seleccionado al `_cuadreId`.
  * Eliminación de la clase/pantalla huérfana no utilizada `formulario_cuadre_tabs.dart`.
* **Qué se eliminó:** 1084 líneas de código muerto en la App móvil (`formulario_cuadre_tabs.dart`).
* **Migraciones:** Ninguna.

* **Fecha/Hora:** 2026-07-02 03:46 (Local)
* **Autor:** Antigravity (AI Agent)
* **Qué se cambió:**
  * Corrección en el radar de tránsito de la Web (`pantalla_transito.dart`) para mapear `estado_transito` expuesto por la vista SQL de Supabase.
  * Implementación de formularios de diálogo interactivos para añadir y eliminar lanchas/gastos en el editor de viajes de la Web (`pantalla_edicion_transito.dart`).
  * Sincronización completa con Supabase de compras (lanchas) y gastos asociados al guardar cambios en la Web, recalculando y persistiendo el `peso_total` en `cuadres`.
  * Filtro local en la App móvil (`formulario_registro_pesca.dart`) para excluir zarpes marcados como recibidos (`RECIBIDO_LAMBAYEQUE`).
  * Actualización de la documentación técnica de flujos en `FLUJO_08_ZARPE_CAMARA.md`.
* **Qué se eliminó:** Lógica estática/demostrativa en el editor web y selección de zarpes cerrados en la App móvil.
* **Migraciones:** Ninguna.

* **Fecha/Hora:** 2026-07-02 03:42 (Local)
* **Autor:** Antigravity (AI Agent)
* **Qué se cambió:**
  * Resolución de conflictos de fusión entre `develop` (local) y `origin/develop` (remoto).
  * Fusión de `panel_calculo_vivo.dart` para mantener la modularización SRP implementada por Jhonatan.
  * Fusión de `formulario_registro_pesca.dart` integrando la localización en español (`Locale('es', 'ES')`) en la función modular `_seleccionarFecha` y preservando el diseño móvil responsivo de Jhonatan.
  * Corrección de regresión en `acceso_rapido_pantalla_test.dart` adaptando la aserción de carga para buscar `CargaOrbital` en lugar de `CircularProgressIndicator`.
* **Qué se eliminó:** Conflictos de Git y aserciones de prueba obsoletas.
* **Migraciones:** Ninguna.

* **Fecha/Hora:** 2026-07-03 16:15 (Local)
* **Autor:** Antigravity (AI Agent)
* **Qué se cambió:**
  * Sincronización absoluta de todas las ramas a nivel corporativo.
  * Migración exitosa de la interfaz gráfica web (Nautical Premium UI) a `bris_web`.
  * Generación de entorno seguro con 2 únicas ramas de desarrollo paralelas (`DEV-JJGS` y `DEV-BELEN`).
  * Actualización de versiones de proyecto (App: 1.3.4+9, Web: 1.1.4+6).
* **Qué se eliminó:** `brismar_app`, `brismar_executive_app`, `brismar_mobile`, archivos de prueba (`scratch`), `.idea`, directorios obsoletos y ramas conflictivas (web, pruebita, etc.).
* **Migraciones:** Consolidación de un solo proyecto móvil (`bris_tracker`) y un solo proyecto web (`bris_web`) listos para despliegue por GitHub Actions.
