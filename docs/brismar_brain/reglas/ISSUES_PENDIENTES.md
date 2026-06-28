# Registro de Issues y Deuda Técnica (Pendientes)

Este documento registra las tareas críticas de arquitectura y negocio que deben ser resueltas o consultadas antes de la versión de producción, identificadas durante las auditorías de diseño.

## 📝 Lista de Issues Abiertos

### Issue #001: Almacenamiento Local de Fotos (Zarpes)
- **Descripción:** El Flujo 08 (Zarpe de Cámara) requiere capturar fotos offline. No se debe guardar el binario pesado de la imagen directamente en SQLite para evitar corrupción de la base de datos.
- **Acción Pendiente:** Modificar la capa de datos locales para guardar únicamente la "ruta absoluta" del archivo local (`path`). El Sincronizador de Fondo deberá leer esa ruta, subir la foto a `Supabase Storage`, obtener la URL pública, y finalmente insertar el registro en la base de datos central.
- **Estado:** 🟡 Pendiente de Implementación.

### Issue #002: Sincronización de Borradores (Cuadres)
- **Descripción:** El Flujo 07 indica que los cuadres sin venta se guardan como "Borradores". El Flujo 04 realiza sincronización en lote. 
- **Duda de Negocio:** ¿Deben enviarse los borradores a la nube para que sean visibles en la Web administrativa (con un flag de "estado: borrador"), o la App debe retenerlos y no enviarlos hasta que estén completos?
- **Acción Pendiente:** Consultar con el equipo operativo la regla de negocio exacta e implementar el filtro (o el flag de estado) en la lógica del `SincronizarPendientesCasoUso`.
- **Estado:** 🔴 Pendiente de Consulta con Operaciones.

### Issue #003: Exportación de Plantilla Excel y Conexión de Campos (Web-App)
- **Descripción:** La exportación actual en la Web genera un Excel genérico básico. Se requiere que inyecte los datos directamente en `PLANTILLA_CUADRE_BRISMAR.xlsx`.
- **Acción Pendiente:** 
  1. Subir `PLANTILLA_CUADRE_BRISMAR.xlsx` como un asset del proyecto.
  2. Modificar `ControladorCuadres` (Web) para usar el paquete `excel` y rellenar las celdas exactas según la plantilla.
  3. Asegurar que los campos reales enviados desde la App Móvil (tonelajes, hielo, muelle) coincidan y se muestren tanto en la tabla de "Tránsito" como en el reporte final.
- **Estado:** 🟡 Pendiente de Implementación para el siguiente hito.
