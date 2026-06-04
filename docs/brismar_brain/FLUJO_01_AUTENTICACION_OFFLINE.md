# Flujo 01: Autenticación Offline (Alta Mar)

Este nodo describe cómo la aplicación móvil autentica a un usuario (Personal de Bahía) cuando no hay conexión a internet (en alta mar).

## Diagrama de Procesos (Carriles / Swimlanes)

El siguiente diagrama detalla la interacción entre el usuario (Personal de Bahía), la lógica de la App Móvil y el Servidor Central (Supabase) bajo el estilo de carriles de procesos, incluyendo bucles de reintento por credenciales incorrectas y validación de primer acceso local:

```mermaid
graph TB
    subgraph Bahia ["Personal de Bahía (Usuario)"]
        A[Abrir Aplicación] --> B[Ingresar Correo y Contraseña]
        B --> B_Loop[Reingresar Credenciales en caso de Error]
        G[Acceder al Dashboard / Registro]
    end

    subgraph AppMobile ["Aplicación Móvil (Lógica & Seguridad)"]
        B --> C{¿Conectado a Internet?}
        B_Loop --> C
        C -- Sí --> D[Autenticar vía API Remota]
        C -- No --> H[Solicitar Validación Local]
        D --> E{¿Respuesta exitosa?}
        E -- Sí --> F[Serializar y guardar datos + hash BCrypt en SQLite]
        E -- No (Error) --> ErrorRemote[Mostrar error y reintentar]
        ErrorRemote --> B_Loop
        H --> I[Buscar hash y datos guardados en SQLite]
        I --> J{¿Existen?}
        J -- Sí --> K[Comparar contraseña ingresada con hash]
        J -- No (Primera Vez) --> ErrorOffline[Mostrar error: Requiere primer acceso Online]
        K --> L{¿Coincide?}
        L -- Sí --> G
        L -- No --> ErrorPass[Contraseña incorrecta y reintentar]
        ErrorPass --> B_Loop
        F --> G
    end

    subgraph Supabase ["Servidor Central (Supabase)"]
        D --> AuthEndpoint["Endpoint de Autenticación RLS"]
    end
```

## Riesgos Asociados

El proceso depende estrictamente de que el dispositivo físico esté seguro. Ver `[[MAPA_DE_RIESGOS]]` para estrategias en caso de pérdida o robo del teléfono en el barco.

---

## 🔗 Enlaces Relacionados

- ¿Por qué decidimos hacerlo así? Revisa `[[03_HISTORIAL_Y_CONTEXTO]]`.
- Reglas de encriptación y base de datos local: `[[01_ARQUITECTURA_Y_REGLAS]]`.
