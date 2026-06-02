# 🤝 Guía de Desarrollo Colaborativo — BRISMAR APP

Esta guía establece el flujo de trabajo estándar, las reglas de codificación y las políticas de Git que **toda la comunidad de colaboradores** debe seguir estrictamente para mantener el proyecto ordenado, escalable y libre de errores.

---

## 1. Flujo de Trabajo con Git (Git Workflow)

Para proponer cambios en el proyecto (por ejemplo, modificar el flujo de inicio de sesión):

```
1. Crear Issue en GitHub
       │
       ▼
2. Crear rama desde 'develop'
       │
       ▼
3. Instalar Hooks locales
       │
       ▼
4. Escribir código y hacer Commit
       │
       ▼
5. Subir rama y abrir PR a 'develop'
       │
       ▼
6. Pasar GitHub Actions y Code Review
       │
       ▼
7. Merge a 'develop' y cierre de Issue
```

### Paso 1: Crear un Issue
Antes de escribir una sola línea de código, se debe registrar un **Issue en GitHub** describiendo la tarea (Bug o Feature). Esto evita la duplicidad de esfuerzos.

### Paso 2: Crear la Rama de Trabajo
Toda rama debe crearse a partir de `develop` (nunca directo a `main`). 
- Nombres de ramas permitidos:
  - `feat/nombre-de-tarea` (para nuevas funcionalidades, ej: `feat/login-remoto`)
  - `fix/nombre-del-bug` (para corrección de errores, ej: `fix/error-calculo-gastos`)
  - `chore/nombre-de-tarea` (para tareas de mantenimiento, ej: `chore/actualizar-dependencias`)

### Paso 3: Instalar Hooks locales
Antes de realizar commits, ejecuta en la raíz del proyecto:
```bash
bash scripts/install-hooks.sh
```
Esto asegura que el hook de pre-commit de Git valide localmente que no estés agregando archivos innecesarios al stage.

### Paso 4: Convención de Commits (Conventional Commits)
Los commits deben redactarse en **español** utilizando los siguientes prefijos:
- `feat: ...` (Ej: `feat: implementar controlador de autenticación`)
- `fix: ...` (Ej: `fix: corregir desbordamiento en pantalla de registro`)
- `docs: ...` (Ej: `docs: documentar modelo de usuario`)
- `refactor: ...` (Ej: `refactor: simplificar obtención de rango de fechas`)
- `test: ...` (Ej: `test: agregar pruebas unitarias para login`)

### Paso 5: Abrir un Pull Request (PR)
Cuando la tarea esté completa, sube la rama y abre un PR apuntando a `develop`.
- El título y descripción del PR deben estar en **español**.
- Asocia el PR al Issue usando palabras clave (Ej: `Cierra #12`).
- El workflow de GitHub Actions ejecutará automáticamente los chequeos de archivos prohibidos y linter.

---

## 2. Estructura de Código y Nomenclatura (Clean Code & Estándares)

### Regla de Idioma: 100% Español 🇪🇸
Todo el código de desarrollo (con la única excepción de palabras clave del lenguaje o dependencias) debe escribirse en español:
- Nombres de carpetas y archivos (Ej: `modelo_usuario.js`, `fuente_datos_registro_remota.dart`).
- Clases, variables, métodos y parámetros (Ej: `calcularGastosTotal()`, `precioPorKilo`).
- Comentarios y documentación.

### Estructura de Carpetas

#### Frontend (Flutter)
Usa **Clean Architecture** estructurada por módulos (componentes) bajo `lib/modulos/`:
```
lib/
├── main.dart
├── nucleo/               # Infraestructura y utilidades compartidas
└── modulos/              # Lógica separada por áreas funcionales
    └── autenticacion/
        ├── datos/        # Modelos, repositorios impl, datasources
        ├── dominio/      # Entidades, casos de uso, contratos/interfaces
        └── presentacion/ # Pantallas, widgets y controladores (Riverpod)
```

#### Backend (Node.js Express)
Usa arquitectura orientada a componentes estructurada bajo `backend/src/modulos/`:
```
backend/
├── app.js
├── server.js
└── src/
    ├── config/           # Configuraciones compartidas (DB)
    └── modulos/          # Componentes independientes
        └── usuarios/
            ├── modelo_usuario.js      # Definición Sequelize
            ├── controlador_usuario.js # Lógica de endpoint
            └── rutas_usuario.js       # Rutas Express
```

---

## 3. Escalabilidad, Estabilidad y Patrones de Diseño

1. **Patrón Repositorio (Repository Pattern)**:
   - Todo acceso a datos (Local o Remoto) debe abstraerse detrás de una interfaz/contrato (en el dominio). La presentación nunca habla directo con la base de datos o el cliente HTTP.
2. **Principio de Responsabilidad Única (SRP)**:
   - **Límite de líneas**: Ninguna función o método público debe superar las **20 líneas de código**. Si una función crece más, debe subdividirse en subtareas de responsabilidad única.
3. **Manejo de Errores Robustos**:
   - Prohibido dejar bloques `catch` vacíos o usar impresiones simples en consola (`print(e)` o `console.log(e)` en producción). 
   - Debe capturarse la excepción, retornar respuestas formateadas en el Backend o disparar estados de error legibles en la UI en el Frontend.
4. **Documentación DartDoc/Javadoc**:
   - Todo método y clase pública debe tener comentarios que expliquen detalladamente sus parámetros, comportamiento y retorno:
     ```javascript
     /**
      * Valida las credenciales e inicia sesión.
      * 
      * @param {object} req - Objeto de petición Express.
      * @param {object} res - Objeto de respuesta Express.
      */
     ```
