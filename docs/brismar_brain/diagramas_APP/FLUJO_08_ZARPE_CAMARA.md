# FLUJO 08: ZARPE CÁMARA EVIDENCIA FOTOGRÁFICA

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#0F224A', 'primaryBorderColor': '#00E5FF', 'lineColor': '#00E5FF', 'fontFamily': 'Inter'}}}%%
flowchart TD
    %% Lanes
    subgraph App Móvil (Usuario Bahía)
        A1[Selecciona 'Nuevo Zarpe']
        A2[Ingresa datos placa, chofer, muelle]
        A3[Captura/Selecciona hasta 3 fotos]
        A4[Valida imágenes y comprime]
        A5[Presiona 'Guardar']
    end

    subgraph Supabase (Backend/Storage)
        S1[(Storage: camaras-zarpes)]
        S2[(Database: zarpes)]
        S3[Valida RLS y Token]
    end

    subgraph Modos de Conexión
        C1{¿Conectado?}
        C2[Guarda foto en caché local y DB SQLite]
        C3[Sube foto 1 a 1 a Storage]
        C4[Guarda URLs públicas]
        C5[Inserta registro en Postgres]
    end

    %% Flujo
    A1 --> A2 --> A3 --> A4 --> A5
    A5 --> C1
    
    C1 -- Offline --> C2
    C2 --> |Background Sync al volver red| C3

    C1 -- Online --> C3
    
    C3 --> S1
    S1 --> S3
    S3 -- Aprobado --> C4
    C4 --> C5
    C5 --> S2

    %% Estilos BPMN
    classDef startEvent fill:#2ECC71,stroke:#27AE60,stroke-width:2px,color:#fff,shape:circle;
    classDef endEvent fill:#E74C3C,stroke:#C0392B,stroke-width:4px,color:#fff,shape:circle;
    classDef task fill:#0F224A,stroke:#00E5FF,stroke-width:2px,color:#fff;
    classDef gateway fill:#F39C12,stroke:#D68910,stroke-width:2px,color:#fff,shape:diamond;
    classDef storage fill:#34495E,stroke:#95A5A6,stroke-width:2px,color:#fff,shape:cylinder;

    class A1 startEvent;
    class S2 endEvent;
    class A2,A3,A4,A5,C2,C3,C4,C5,S3 task;
    class C1 gateway;
    class S1,S2 storage;
```
