# 📜 Historial de Contexto (Log de Decisiones Brismar)

*Nota: Este archivo preserva la historia de decisiones previas a la migración a GitHub Issues Nativos, para que las IAs entiendan cómo evolucionó el proyecto y qué features ya están implementadas.*

## VERSIÓN FUNCIONAL PREVIA: v1.0.x
*(Antes de automatizar el changelog con GitHub Releases)*

### Decisiones Arquitectónicas (Issue #2)
- **Estandarización al Español:** Se decidió traducir profunda y arquitectónicamente todas las capas del proyecto móvil al español. El objetivo es uniformidad semántica para el equipo local. Por ende, los repositorios, casos de uso, modelos y fuentes de datos deben declararse en español.

### Autenticación Offline (Issue #1)
- **Implementación Completada:** Se implementó un sistema de Autenticación Offline. 
- **Mecanismo:** Los hashes (SHA-256) se validan en una bóveda segura local sin necesidad de internet. Esta decisión es inamovible debido a las restricciones de conexión en las embarcaciones pesqueras. 

### Problemas Pendientes (Para resolver en Issues de GitHub)
1. **Riesgo de Robo Físico (Ex-Issue #3):** Evaluar encriptación de toda la SQLite local (SQLCipher).
2. **Conflicto de Concurrencia (Ex-Issue #4):** Implementar y definir estrategias para manejar alertas de concurrencia tipo "Last-Write-Wins" cuando múltiples dispositivos sincronicen información con Supabase al recuperar señal de internet.
