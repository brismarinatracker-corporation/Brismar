# Mapa de Riesgos e Ingeniería de Fiabilidad

Brismar opera en entornos hostiles (alta mar, sin conexión, dispositivos expuestos a daños o robos). Este documento agrupa los peores escenarios y cómo la arquitectura los mitiga.

## 1. Riesgo Físico: Robo del Dispositivo

- **Descripción:** Un celular con la aplicación instalada es robado. Contiene datos de pesca y hashes de contraseñas de capitanes.
- **Mitigación:** La base de datos SQLite y las preferencias están cifradas con SQLCipher (`[[01_ARQUITECTURA_Y_REGLAS]]`). No se puede acceder sin la Master Key del dispositivo. Además, se permite revocar acceso remoto desde `[[SISTEMA_CENTRAL_SUPABASE]]`.

## 2. Riesgo de Datos: Conflicto de Concurrencia

- **Descripción:** Dos dispositivos en el mismo barco registran offline datos contradictorios sobre el mismo viaje de pesca. Cuando llegan a puerto, intentan subir los datos.
- **Mitigación:** Implementación de estrategias "Last-Write-Wins" o unificación de datos a nivel de Supabase. (Ver `[[FLUJO_02_REGISTRO_PESCA_ALTA_MAR]]`).

## 3. Riesgo de Credenciales: Pérdida de Token

- **Descripción:** Las credenciales maestras se fugan al público.
- **Mitigación:** Uso estricto de variables de entorno `.env` ignoradas en el control de versiones, como dictan las reglas del equipo (`[[02_FLUJO_DE_TRABAJO]]`).

---

## 🔗 Enlaces Relacionados

- Documentación de fallos pasados y decisiones previas: `[[03_HISTORIAL_Y_CONTEXTO]]`.
