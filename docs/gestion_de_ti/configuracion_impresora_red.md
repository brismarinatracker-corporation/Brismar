# Configuración de Impresora en Red

## Contexto
**Rol:** Gestión de TI (Jhonatan)
**Problema Anterior:** Las computadoras no podían imprimir mediante la red WiFi o Ethernet. La impresión estaba limitada o no configurada para un acceso compartido y remoto en la oficina.
**Solución Implementada:** Se configuró una impresora en red para que 4 computadoras puedan imprimir sin problemas, ya sea conectadas por WiFi o por cable Ethernet.

## Acciones Realizadas

Como encargado de Gestión de TI, se llevaron a cabo los siguientes pasos en el entorno de trabajo de Brismar:

1. **Conexión de la Impresora a la Red:**
   - Se conectó la impresora a la red local (router/switch) para que esté visible en toda la subred, permitiendo tanto conexiones inalámbricas (WiFi) como cableadas (Ethernet).

2. **Configuración en las 4 Computadoras:**
   - En cada una de las 4 PCs se realizó exactamente el mismo procedimiento de configuración para estandarizar el acceso.
   - Se buscaron y agregaron los dispositivos de impresión en red a través del sistema operativo.
   - Se instalaron los controladores (drivers) correspondientes en caso de ser necesario.

3. **Establecer como Predeterminada:**
   - En cada una de las 4 computadoras, se configuró esta nueva impresora de red como la **impresora predeterminada**. Esto garantiza que, al momento de que cualquier usuario mande a imprimir un documento, se envíe automáticamente a esta impresora sin necesidad de seleccionarla manualmente.

## Resultados
- **Accesibilidad:** Ahora cualquier usuario desde las 4 PCs puede imprimir de manera inalámbrica (WiFi) o por cable (Ethernet) sin importar su ubicación dentro de la oficina.
- **Eficiencia:** Al estar predeterminada, se reducen los errores de impresión y se agiliza el flujo de trabajo del equipo de Brismar.

---

## Diagrama de Flujo y Arquitectura de Red

A continuación se muestra un diagrama que explica cómo quedó configurada la red de impresión:

```mermaid
flowchart TD
    subgraph Red Local Brismar
        Router[Router / Switch (Red Local)]
    end

    subgraph Computadoras
        PC1[Computadora 1]
        PC2[Computadora 2]
        PC3[Computadora 3]
        PC4[Computadora 4]
    end

    subgraph Impresión
        Impresora[Impresora en Red]
    end

    %% Conexiones hacia el router
    PC1 -- WiFi / Ethernet --> Router
    PC2 -- WiFi / Ethernet --> Router
    PC3 -- WiFi / Ethernet --> Router
    PC4 -- WiFi / Ethernet --> Router

    %% Conexión del router a la impresora
    Router -- Red Local --> Impresora

    %% Configuración específica
    classDef config fill:#e1f5fe,stroke:#03a9f4,stroke-width:2px;
    class PC1,PC2,PC3,PC4 config;
    
    %% Nota de configuración
    NotaConfig>Configuradas con la impresora como PREDETERMINADA]
    PC4 -.-> NotaConfig
    PC1 -.-> NotaConfig
```
