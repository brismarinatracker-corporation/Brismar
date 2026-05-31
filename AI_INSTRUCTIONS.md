# 🤖 INSTRUCCIONES PARA AGENTES DE IA (AI_INSTRUCTIONS.md)

Este documento contiene las reglas, metodologías y estándares de desarrollo obligatorios para cualquier Inteligencia Artificial que lea, modifique o interactúe con el código de este repositorio.

---

## 📌 1. Flujo de Trabajo y GitHub

*   **Revisar Issues y Tableros:** Antes de tocar cualquier línea de código, la IA debe consultar las Issues de GitHub y el tablero Kanban del proyecto para entender las tareas pendientes, prioridad y requerimientos actuales.
*   **Gestión de Ramas:**
    *   `main`: Rama de producción. Solo contiene código estable y versiones tageadas (`vX.Y.Z`). **Prohibido realizar commits directos.**
    *   `develop`: Rama de integración y desarrollo general.
    *   `developer-jjgs`: Rama de desarrollo personal para Jhonatan Sanchez.
*   **Reportes y Trazabilidad:** Al realizar cambios, la IA debe documentar el progreso en un archivo markdown de seguimiento (`task.md` y `walkthrough.md`) y reportar claramente el estado para actualizar las Issues de GitHub.
*   **Versionamiento Semántico (SemVer):** Cada release en `main` debe seguir el formato `vX.Y.Z` (Mayor.Menor.Parche).

---

## 🏗️ 2. Arquitectura Limpia y SOLID

Trabajamos con una estricta separación de capas (Clean Architecture) para que todo sea modular y fácil de encontrar.

*   **Estructura del Proyecto (`brismar_mobile/lib/`):**
    *   `nucleo/`: Código compartido y utilidades transversales (rutas, red, base de datos local).
    *   `modulos/`: Dividido por características (ej. `autenticacion`, `registro`). Cada módulo debe tener:
        *   `datos/`: DataSources (API, DB) y contratos implementados (Repositories).
        *   `dominio/`: Entidades de negocio, Casos de Uso y contratos (interfaces).
        *   `presentacion/`: UI (Widgets, Screens) y gestión de estado (Riverpod StateNotifiers/Providers).
*   **Responsabilidad Única (SRP):** Cada clase, función y archivo debe tener una sola razón para cambiar.
    *   **Límite de Clases/Archivos:** Máximo aproximado de **100 líneas por clase/archivo** para asegurar alta cohesión.
    *   **Límite de Funciones/Métodos:** Máximo de **20 líneas de código por función**. Si supera este límite, la lógica debe modularizarse en funciones auxiliares.
*   **Principio de Abierto/Cerrado (OCP):** El código debe estar abierto para su extensión pero cerrado para su modificación. Diseña utilizando polimorfismo, interfaces y abstracciones.

---

## 💻 3. Reglas Técnicas de Código (Flutter & Dart)

*   **Patrones de Diseño:** Implementar patrones según el contexto (`Repository`, `Factory`, `Singleton`, `State`).
*   **Flutter & State Management:** Usar **Riverpod** para el manejo de estado de forma reactiva y limpia.
*   **Acceso a Datos (Flutter):**
    *   Es obligatorio usar el patrón **Repository** para encapsular el acceso a datos. La UI nunca debe acceder directamente a la base de datos o APIs.
    *   Usar **Supabase** directamente desde el repositorio optimizando las queries para traer solo los campos necesarios.
*   **Manejo de Errores:**
    *   **Prohibido usar `print(e)` o dejar bloques `catch` vacíos.**
    *   Es obligatorio usar manejo de excepciones estructurado (`try-catch`), capturando excepciones específicas y retornando/mostrando mensajes de error claros y entendibles para el usuario.
*   **Documentación de Código:**
    *   Generar comentarios en formato **DartDoc** (`///`) para cada método público, clase y propiedad expuesta, explicando su propósito, parámetros y valor de retorno.
    *   Todo el código, comentarios y documentación deben estar en **español entendible y profesional**.

---

## ⚡ 4. Optimización de Tokens y Eficiencia de IA

Para reducir el consumo de tokens y maximizar la precisión en el desarrollo:

*   **Uso de Graphify / Herramientas de Mapeo:** Utilizar herramientas visuales o comandos de terminal (como `grep`, `find` u outputs de estructuras) para entender la arquitectura antes de leer archivos completos.
*   **Lectura Selectiva:** No leer archivos masivos de manera innecesaria. Apuntar específicamente a los archivos relacionados con la tarea utilizando búsquedas semánticas o ripgrep.
*   **Respuestas Concisas:** No repetir explicaciones teóricas ni código redundante en las respuestas. Ir directo a la solución e indicar los cambios en formato diff o instrucciones específicas.
