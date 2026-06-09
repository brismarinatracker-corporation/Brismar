# 🔄 Flujo de Trabajo y Reglas Git (BRISMAR)

## 1. El Bloqueo de la Rama `main`

- **NUNCA HAGAS MERGE A `MAIN`.**
- La rama `main` es el entorno de Producción (Play Store / Servidores en vivo).
- Las IAs y los colaboradores deben ramificar siempre desde `develop` (Ej. `feature/issue-3`).
- El "Merge Manager" (Jhonatan) es el único con poder de fusionar `develop` hacia `main` cuando se decida lanzar una nueva versión funcional.

## 2. Gestión de Tareas (GitHub Issues)

- La fuente de la verdad ya no son los archivos de texto `.md` locales, sino las **Issues nativas de GitHub**.
- Las IAs equipadas con MCP (Model Context Protocol) de GitHub DEBEN leer la lista de Issues abiertos en el repositorio remoto antes de proponer código o inventarse tareas.
- En los mensajes de los commits y los Pull Requests, siempre usar la notación `Closes #IssueID` para que GitHub cierre la Issue automáticamente al fusionar en `develop`.

## 3. Estandarización de Idioma y Detalle en Git

- **Idioma Español Obligatorio:** Todo el contenido dentro de Git debe ser escrito en **español**. Esto incluye de manera estricta:
  - **Issues (Tareas):** Tanto los títulos como las descripciones deben estar detallados en español.
  - **Pull Requests (PRs):** La descripción, justificación y pruebas de los PRs deben redactarse en español.
  - **Mensajes de Commit:** Los mensajes de confirmación de git deben ser escritos en español.
- **Detalle Extremo e Interior:** No se permiten títulos genéricos ni descripciones cortas o vacías. Se debe documentar el interior y el funcionamiento lógico de los cambios:
  - En los **commits**, describe detalladamente el qué, el cómo y el por qué del cambio en la lógica interna, no solo el nombre del archivo o función modificada.
  - En los **PRs e Issues**, detalla exhaustivamente las implicaciones lógicas, la arquitectura y los flujos internos modificados.

## 4. Sincronización y Comunicación entre Agentes

- Si trabajas sobre un código complejo que afecta a otros (Ej. la base de datos Supabase), deja comentarios descriptivos o actualiza estos archivos en la bóveda de conocimiento (`brismar_brain/`).
- Documentación externa (PDFs de facturas pesados, diseños, etc.) reside en **Google Drive** corporativo de Brismar. Las IAs deben pedir acceso al enlace de Drive si requieren contexto externo masivo que no cabe en texto plano.

---

## 🔗 Enlaces Relacionados (Cerebro Obsidian)

- Conoce la estructura del código y Supabase, lee: [[ARQUITECTURA_Y_REGLAS]]
- Revisa el registro histórico de las decisiones aquí: [[HISTORIAL_Y_CONTEXTO]]
