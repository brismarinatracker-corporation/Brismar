# FLUJO 09: CREACIÓN Y GESTIÓN DE USUARIOS WEB

```mermaid
%%{init: {'theme': 'dark', 'themeVariables': { 'primaryColor': '#0F224A', 'primaryBorderColor': '#00E5FF', 'lineColor': '#00E5FF', 'fontFamily': 'Inter'}}}%%
flowchart TD
    %% Lanes
    subgraph Web Admin (Administrador)
        W1[Accede al módulo 'Usuarios']
        W2[Presiona 'Nuevo Usuario']
        W3[Ingresa DNI]
        W4[Presiona Buscar en API RENIEC]
        W5[Autocompleta Nombres y Apellidos]
        W6[Ingresa Correo Corporativo y Clave]
        W7[Selecciona Rol y Sede]
        W8[Presiona 'Registrar']
    end

    subgraph Supabase Auth / Database
        S1[Supabase.auth.signUp]
        S2{¿Error en Registro?}
        S3[Inserta perfil en tabla 'usuarios']
        S4[Asigna roles RLS]
    end

    subgraph DNI Service
        API[API DNI Externa]
    end

    %% Flujo
    W1 --> W2 --> W3 --> W4
    W4 --> API
    API -- Retorna Datos --> W5
    W5 --> W6 --> W7 --> W8
    W8 --> S1
    S1 --> S2
    
    S2 -- Sí (ej. Correo Duplicado) --> W8_Error[Muestra Banner Rojo de Error Localizado]
    S2 -- No --> S3
    
    S3 --> S4
    S4 --> Fin[Refresca Lista de Usuarios Web]

    %% Estilos BPMN
    classDef startEvent fill:#2ECC71,stroke:#27AE60,stroke-width:2px,color:#fff,shape:circle;
    classDef endEvent fill:#E74C3C,stroke:#C0392B,stroke-width:4px,color:#fff,shape:circle;
    classDef task fill:#0F224A,stroke:#00E5FF,stroke-width:2px,color:#fff;
    classDef gateway fill:#F39C12,stroke:#D68910,stroke-width:2px,color:#fff,shape:diamond;
    classDef storage fill:#34495E,stroke:#95A5A6,stroke-width:2px,color:#fff,shape:cylinder;
    classDef api fill:#8E44AD,stroke:#9B59B6,stroke-width:2px,color:#fff,shape:rect;

    class W1 startEvent;
    class Fin endEvent;
    class W2,W3,W4,W5,W6,W7,W8,S1,S3,S4,W8_Error task;
    class S2 gateway;
    class API api;
```
