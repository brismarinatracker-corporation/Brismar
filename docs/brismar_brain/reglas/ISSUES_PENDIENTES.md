# Registro de Issues y Deuda Técnica — BRISMAR
> Última actualización: **2026-06-29**

Este documento registra las tareas críticas de arquitectura y negocio que deben ser resueltas o consultadas antes de la versión de producción, identificadas durante las auditorías de diseño.

---

## ✅ Issues Resueltos

### Issue #000: Drift vs SQLite (Conflicto de persistencia local)
- **Descripción:** Coexistían dependencias de `drift` (dead code) con `sqflite`, causando errores de compilación.
- **Resolución:** Eliminadas todas las dependencias de `drift`. Migrada la base de datos local a `sqflite` puro (v7). Añadida columna `sincronizado` en tabla `zarpes` para desacoplar estado de negocio del estado de sincronización.
- **Estado:** ✅ Resuelto el 2026-06-29.

### Issue #005: Seguridad en Edge Function `admin_usuarios`
- **Descripción:** La Edge Function no validaba el JWT ni el rol del usuario que llamaba.
- **Resolución:** Añadida validación de JWT y verificación de rol `administrador` antes de cualquier operación.
- **Estado:** ✅ Resuelto el 2026-06-29.

### Issue #006: Dashboard Web Admin sin KPIs reales
- **Descripción:** El Dashboard no cargaba datos; solo era layout estático.
- **Resolución:** Implementados `FuenteDatosDashboard` y `ControladorDashboard` con 5 queries paralelas a Supabase. Añadida `PantallaDashboard` con tarjetas de KPI.
- **Estado:** ✅ Resuelto el 2026-06-29.

### Issue #007: Rutas del enrutador Web Admin desactualizadas
- **Descripción:** No existía la ruta `/dashboard` y el `build_runner` no había regenerado `enrutador.g.dart`.
- **Resolución:** Añadida `RutaDashboard` al enrutador, regenerado el archivo `.g.dart` y corregida la redirección post-login.
- **Estado:** ✅ Resuelto el 2026-06-29.

---

## 📝 Issues Abiertos

### Issue #001: Almacenamiento Local de Fotos (Zarpes)
- **Descripción:** El Flujo 08 (Zarpe de Cámara) requiere capturar fotos offline. No se debe guardar el binario pesado de la imagen directamente en SQLite para evitar corrupción de la base de datos.
- **Acción Pendiente:** Modificar la capa de datos locales para guardar únicamente la "ruta absoluta" del archivo local (`path`). El Sincronizador de Fondo deberá leer esa ruta, subir la foto a `Supabase Storage`, obtener la URL pública, y finalmente insertar el registro en la base de datos central.
- **Estado:** 🟡 Pendiente de Implementación.

### Issue #002: Sincronización de Borradores (Cuadres)
- **Descripción:** El Flujo 07 indica que los cuadres sin venta se guardan como "Borradores". El Flujo 04 realiza sincronización en lote.
- **Duda de Negocio:** ¿Deben enviarse los borradores a la nube para que sean visibles en la Web administrativa (con un flag de "estado: borrador"), o la App debe retenerlos y no enviarlos hasta que estén completos?
- **Acción Pendiente:** Consultar con el equipo operativo la regla de negocio exacta e implementar el filtro en la lógica del `SincronizarPendientesCasoUso`.
- **Estado:** 🔴 Pendiente de Consulta con Operaciones.

### Issue #003: Exportación con Plantilla Excel Oficial (Web-App)
- **Descripción:** La exportación actual en la Web genera un Excel genérico básico. Se requiere que inyecte los datos directamente en `PLANTILLA_CUADRE_BRISMAR.xlsx`.
- **Acción Pendiente:**
  1. Subir `PLANTILLA_CUADRE_BRISMAR.xlsx` como un asset del proyecto.
  2. Modificar `ControladorCuadresWeb` para usar el paquete `excel` y rellenar las celdas exactas según la plantilla.
  3. Asegurar que los campos reales enviados desde la App Móvil coincidan con las columnas del reporte final.
- **Estado:** 🟡 Pendiente de Implementación para el siguiente hito.

### Issue #004: Vista "Zarpes Recibidos" en App Lambayeque
- **Descripción:** La app móvil no tiene una pantalla dedicada para que el personal de Lambayeque confirme la recepción de un zarpe.
- **Acción Pendiente:** Crear `PantallaZarpesRecibidos` en `brismar_app` para el rol `lambayeque`, con lista filtrada por `estado = RECIBIDO_LAMBAYEQUE` y botón de confirmación.
- **Estado:** 🟡 Pendiente de Implementación.

### Issue #008: Foto de Perfil de Usuario
- **Descripción:** El módulo de gestión de usuarios en la Web Admin no permite subir o cambiar la foto de perfil del usuario.
- **Acción Pendiente:** Integrar `Supabase Storage` con el bucket `avatares` para subir la foto y guardar la URL en el campo `avatar_url` de la tabla `usuarios`.
- **Estado:** 🟡 Pendiente de Implementación.
