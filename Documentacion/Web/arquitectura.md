# Arquitectura de BrisWeb

Este documento describe la arquitectura basada en capas del proyecto, siguiendo principios de Clean Architecture.

## Diagrama de Capas (Mermaid)

```mermaid
graph TD
    subgraph UI [Capa de Presentación - Flutter]
        P[Pantallas] --> W[Widgets]
        P --> C[Controladores - Riverpod]
        W --> C
    end

    subgraph Dominio [Capa de Dominio]
        M[Modelos Tipados]
        E[Enums de Dominio]
    end

    subgraph Datos [Capa de Datos]
        F[Fuente de Datos] --> M
        R[Repositorios] --> M
    end

    subgraph Infraestructura [Infraestructura]
        S[Supabase SDK]
    end

    C --> Dominio
    C --> Datos
    Datos --> S
```

## Reglas de Arquitectura
1. **Nunca invocar a Supabase directamente desde la UI (Pantallas/Widgets).** 
2. Toda comunicación con Supabase se realiza a través de Fuentes de Datos (Read-only) o Repositorios (Read/Write).
3. Los controladores (`Notifier` de Riverpod) actúan como intermediarios entre la UI y la capa de datos.
4. **Modelos Fuertemente Tipados:** La UI consume clases (ej. `ZarpeModelo`, `CuadreWebModelo`), nunca `Map<String, dynamic>`.
