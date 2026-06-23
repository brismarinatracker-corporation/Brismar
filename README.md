# ⚓ BRISMAR - Central de Operaciones y Ecosistema ⚓

Bienvenido al Monorepo oficial de **NEGOCIOS BRISMAR S.R.L.**
Este archivo es la puerta de entrada para entender la estructura técnica y de comunicación del proyecto corporativo.

*(Nota: Las reglas profundas de arquitectura, convenciones de IAs y flujo de versiones se encuentran guardadas y protegidas en la bóveda de conocimiento interna: `docs/brismar_brain/`).*

---

## 📁 Arquitectura del Monorepo

* 📱 [**brismar_app**](./brismar_app/) — Código fuente de la aplicación móvil (Flutter). Implementa una robusta arquitectura *Offline-First* enfocada en seguridad. (Actualmente: **Fase 1 Autenticación COMPLETADA**, transitando a Fase 2 Registro). Revisa el detalle en `ESTADO_PROYECTO.md`. (Encargados: **Jhonatan y Belén**).
* ⚙️ [**brismar_web**](./brismar_web/) — Código fuente del backend y dashboard administrativo (migrado a Supabase PostgreSQL como base de datos única). (Encargado: **Yisus**).
* 🗄️ [**supabase**](./supabase/) — Definiciones de tablas y migraciones de la base de datos PostgreSQL compartida.

---

## 🌍 Ecosistema Externo de BRISMAR
Para sacar el máximo provecho a la cuenta corporativa unificada de Gmail de Brismar, usamos las siguientes herramientas centralizadas. Toda IA o desarrollador debe usar estos canales:

### 1. 📂 Google Drive Corporativo (5TB)
Todo documento pesado, PDF, diseños, requerimientos legales o facturas deben subirse aquí. **(NO se suben PDFs ni imágenes pesadas a GitHub)**.
- **Enlace:** `[Insertar Enlace al Drive de Brismar aquí]`
- *(Tip IA: Usa tu herramienta MCP de Google Drive para buscar en esta carpeta si necesitas contexto técnico que no está en el código).*

### 2. 💬 Servidor de Discord Oficial
Para evitar la pérdida de contexto en WhatsApp y permitir la integración con IAs, toda la comunicación técnica ocurre en Discord.
- **Enlace:** `[Insertar Invitación de Discord aquí]`
- **Canal `#dev-mobile`**: Jhonatan y Belén discuten la App.
- **Canal `#dev-web`**: Yisus reporta el progreso de la Web.
- **Canal `#bots-ai`**: Conecta aquí tus asistentes de IA (Midjourney, bots de notificaciones de GitHub) para reportes de errores en tiempo real.

### 3. 🧪 Google Colab / Notebooks
Para el análisis de datos masivos de pesca, reportes contables o scripts de Python que consuman la BD de Supabase, usen Google Colab enlazado a la misma cuenta de Drive de Brismar.

### 4. 📊 Políticas de Datos y Canales Operativos
- **Supabase PostgreSQL** es la fuente única de verdad para la App y la Web.
- **WhatsApp** queda erradicado como canal operativo principal para evitar pérdidas de contexto y desorden en datos de fletes, gastos o pesca.
- **Excel** se mantiene como formato de salida compatible para reportes, entrega contable, análisis administrativo y respaldos operativos, buscando reducir la digitación manual mas no eliminar su uso tradicional en oficina.

---

## 🐙 Flujo de Trabajo y Automatización (GitHub Native)

Hemos eliminado los archivos de texto `.md` manuales para gestionar versiones. Todo el proyecto ahora está 100% automatizado mediante las funciones nativas de GitHub:

1. **Gestión de Tareas (Issues):** Todo bug o función nueva debe crearse en la pestaña **"Issues"** de GitHub. Asigna el issue a Jhonatan, Belén o Yisus según corresponda.
2. **Control de Ramas:**
   - Nadie empuja código a `main`. Todo se ramifica desde `develop`.
   - Cuando termines tu tarea (Ej. `feature/login`), abres un Pull Request hacia `develop` mencionando "Closes #NumeroDeIssue".
3. **Pases a Producción (Releases):**
   - Cuando el equipo decide que la versión en `develop` está lista, Jhonatan (como Merge Manager) fusiona `develop` en `main`.
   - Al fusionar en `main`, usa la pestaña **"Releases"** de GitHub para crear la versión (Ej. v1.0.2). GitHub auto-generará el *Changelog* leyendo los títulos de los PRs fusionados. ¡Magia y cero trabajo manual!

---
*Este manifiesto consolida todo el conocimiento técnico de Brismar. ¡A programar!* 🚀