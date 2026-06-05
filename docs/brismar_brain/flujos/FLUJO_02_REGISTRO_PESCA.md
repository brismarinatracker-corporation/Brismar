# Flujo 02: Registro de Pesca en Alta Mar

Este es el proceso "Core" de Brismar. Cómo se registra una captura desde la aplicación móvil sin depender de la nube.

## Diagrama de Procesos (Carriles / Swimlanes)

El siguiente diagrama detalla la interacción multi-actor para el registro de pesca y la posterior sincronización con la central y la web:

```mermaid
graph TB
    subgraph Pescador ["Pescador / Capitán (Alta Mar)"]
        A[Iniciar Registro de Pesca] --> B[Ingresar Kilos, Especie y Hora]
        E[Navegar de regreso a Bahía]
    end

    subgraph Dispositivo ["Dispositivo Móvil (SQLite & Background Worker)"]
        B --> C[Almacenar en Base de Datos SQLite]
        C --> D[Establecer sync_pending = true]
        D --> E
        E --> F{¿Conexión Detectada?}
        F -- Sí --> G[Background Worker Inicia Envío]
        F -- No --> E
        G --> H[Leer registros con sync_pending = true]
        H --> I[Enviar lote de datos]
        I --> J{¿Confirmación recibida?}
        J -- Sí --> K[Actualizar sync_pending = false]
        J -- No --> L[Programar reintento]
    end

    subgraph Supabase ["Servidor Central (Supabase / Nube)"]
        I --> RecibirDatos[Procesar e Insertar en DB Central]
        RecibirDatos --> Confirmar[Enviar Respuesta de Éxito]
    end

    subgraph WebDashboard ["Dashboard Web (Tierra / Bahía)"]
        Confirmar --> MostrarWeb[Visualizar captura en tiempo real]
    end
```

## Puntos Críticos

La sincronización debe manejar conflictos si dos usuarios editan el mismo viaje. Revisar `[[MAPA_DE_RIESGOS]]` (Concurrencia).

---

## 🔗 Enlaces Relacionados

- Flujo de revisión por parte del Desarrollador: [[FLUJO_DE_TRABAJO]].
