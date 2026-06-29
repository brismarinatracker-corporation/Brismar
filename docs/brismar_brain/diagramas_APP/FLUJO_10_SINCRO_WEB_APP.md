# FLUJO 10: SINCRONIZACIÓN WEB ADMIN Y APP MÓVIL (CUADRES Y ZARPES)

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#0F224A', 'primaryBorderColor': '#00E5FF', 'lineColor': '#00E5FF', 'fontFamily': 'Inter'}}}%%
flowchart TD
    %% Lanes
    subgraph Web Admin (Supervisor)
        W1[Abre Dashboard Cuadres]
        W2[Observa tabla de descargas o zarpes]
        W3[Cambia estado de Zarpe de RECIBIDO a INGRESADO]
        W4[Presiona 'Actualizar']
    end

    subgraph Supabase Realtime
        S1[(Base de Datos: zarpes / cuadres)]
        S2[Dispara evento Postgres Changes]
        S3[Distribuye evento via WebSockets a clientes conectados]
    end

    subgraph App Móvil (Personal de Bahía)
        A1[Usuario tiene la App abierta]
        A2[Supabase Stream emite nueva data]
        A3[Controlador de Estado (Provider/GetX) recibe evento]
        A4[UI se repinta automáticamente]
        A5[El personal ve el Zarpe actualizado al instante]
    end

    %% Flujo
    W1 --> W2 --> W3 --> W4
    W4 --> S1
    S1 --> S2 --> S3
    
    S3 -- WebSocket --> A1
    A1 --> A2 --> A3 --> A4 --> A5

    %% Estilos BPMN
    classDef startEvent fill:#2ECC71,stroke:#27AE60,stroke-width:2px,color:#fff,shape:circle;
    classDef endEvent fill:#E74C3C,stroke:#C0392B,stroke-width:4px,color:#fff,shape:circle;
    classDef task fill:#0F224A,stroke:#00E5FF,stroke-width:2px,color:#fff;
    classDef gateway fill:#F39C12,stroke:#D68910,stroke-width:2px,color:#fff,shape:diamond;
    classDef storage fill:#34495E,stroke:#95A5A6,stroke-width:2px,color:#fff,shape:cylinder;
    classDef realTime fill:#D35400,stroke:#E67E22,stroke-width:2px,color:#fff,shape:parallelogram;

    class W1 startEvent;
    class A5 endEvent;
    class W2,W3,W4,A1,A3,A4 task;
    class S2,S3 realTime;
    class S1 storage;
    class A2 realTime;
```
