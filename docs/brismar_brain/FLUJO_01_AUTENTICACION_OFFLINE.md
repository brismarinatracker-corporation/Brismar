# Flujo 01: Autenticación Offline (Alta Mar)

Este nodo describe cómo la aplicación móvil autentica a un usuario (Pescador o Capitán) cuando no hay conexión a internet (en alta mar).

## Diagrama de Procesos (Carriles / Swimlanes)

El siguiente diagrama detalla la interacción entre el usuario (Pescador), la lógica de la App Móvil y el Servidor Central (Supabase) bajo el estilo de carriles de procesos:

```mermaid
graph TB
    subgraph Pescador ["Pescador (Interfaz de Usuario)"]
        A[Abrir Aplicación] --> B[Ingresar Credenciales]
        G[Acceder al Dashboard / Registro]
    end

    subgraph AppMobile ["Aplicación Móvil (Lógica & Seguridad)"]
        B --> C{¿Conectado a Internet?}
        C -- Sí --> D[Autenticar vía API Remota]
        C -- No --> H[Solicitar Validación Local]
        D --> E{¿Respuesta exitosa?}
        E -- Sí --> F[Serializar y guardar datos + hash BCrypt]
        E -- No --> ErrorRemote[Mostrar error de red/credenciales]
        H --> I[Buscar hash y datos guardados en Bóveda]
        I --> J{¿Existen?}
        J -- Sí --> K[Comparar contraseña ingresada con hash]
        J -- No --> ErrorOffline[Mostrar error: Requiere primer login online]
        K --> L{¿Coincide?}
        L -- Sí --> G
        L -- No --> ErrorPass[Contraseña incorrecta]
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
