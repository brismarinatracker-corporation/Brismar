# FLUJO 06: GESTIÓN DE INCIDENCIAS TI

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#0F224A', 'primaryBorderColor': '#00E5FF', 'lineColor': '#00E5FF', 'fontFamily': 'Inter'}}}%%
flowchart TD
    %% Lanes
    subgraph App Móvil (Personal)
        A1[Usuario experimenta problema]
        A2[Abre sección de Soporte / Botón Flotante]
        A3[Redacta incidencia]
        A4[Adjunta captura opcional]
        A5[Envía ticket]
    end

    subgraph Edge Functions / Supabase
        S1{¿Hay conexión a internet?}
        S2[(Cola Local Offline)]
        S3[Sincroniza cuando hay red]
        S4[Inserta en tabla incidencias_ti]
    end

    subgraph Web Admin (Soporte)
        W1[Alerta en Dashboard de Soporte]
        W2[Lee descripción y metadatos del equipo]
        W3[Marca ticket como 'En Revisión']
        W4[Resuelve problema]
        W5[Cierra incidencia]
    end

    %% Flujo
    A1 --> A2 --> A3 --> A4 --> A5
    A5 --> S1
    S1 -- No --> S2
    S2 --> S3
    S1 -- Sí --> S4
    S3 --> S4
    S4 --> W1
    W1 --> W2 --> W3 --> W4 --> W5

    %% Estilos BPMN
    classDef startEvent fill:#2ECC71,stroke:#27AE60,stroke-width:2px,color:#fff,shape:circle;
    classDef endEvent fill:#E74C3C,stroke:#C0392B,stroke-width:4px,color:#fff,shape:circle;
    classDef task fill:#0F224A,stroke:#00E5FF,stroke-width:2px,color:#fff;
    classDef gateway fill:#F39C12,stroke:#D68910,stroke-width:2px,color:#fff,shape:diamond;
    classDef storage fill:#34495E,stroke:#95A5A6,stroke-width:2px,color:#fff,shape:cylinder;

    class A1 startEvent;
    class W5 endEvent;
    class A2,A3,A4,A5,S3,S4,W1,W2,W3,W4 task;
    class S1 gateway;
    class S2 storage;
```
