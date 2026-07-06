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

### Issue #014: Pantalla negra / Pérdida de foto por reciclaje de Actividad en Android (ZTE V60)
- **Descripción:** Al abrir la cámara en dispositivos con poca RAM, el sistema operativo destruye la actividad principal de Flutter. Al regresar, la app se reinicia, causando una pantalla negra/reinicio y perdiendo la foto tomada.
- **Resolución:** Se implementó `retrieveLostData()` de `image_picker` en `FormularioZarpePantalla` para recuperar y restaurar automáticamente la foto tomada al reiniciar la actividad.
- **Estado:** ✅ Resuelto el 2026-06-30.

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

### Issue #009: Tara Fija Oficial (3kg) y Preparación para Tara Dinámica
- **Descripción:** El CEO ha confirmado que por ahora la única tara oficial y permitida es de **3kg**. No obstante, el código debe estar preparado para escalar a múltiples tipos de cajas en el futuro sin refactorizar la lógica central.
- **Acción Pendiente:** Asegurar que los cálculos de peso neto en la App utilicen una constante de configuración (ej. `TARA_OFICIAL = 3.0`) en lugar de números mágicos. No implementar menú de selección de cajas todavía.
- **Estado:** 🟡 Pendiente de Implementación en UI/Lógica.

### Issue #010: Registro de Adelantos a Proveedores (Cash-Flow)
- **Descripción:** El Bahía da dinero en efectivo de su "caja chica" a los pescadores artesanales (embarcaciones) como fidelización. Este dinero reduce el "Poder de Compra" del lote (compra) y debe restarse antes del prorrateo de utilidades.
- **Acción Pendiente:** Añadir columna `adelanto` a la tabla `compras` en SQLite (`gestor_base_datos.dart`) y Supabase, o crear una tabla `adelantos_proveedor` vinculada al `compra_id`. Este monto se resta de la Utilidad Bruta.
- **Estado:** 🔴 Pendiente de Migración SQLite/Supabase.

### Issue #011: Registro de "Cortesía a Estibadores" (En Revisión)
- **Descripción:** Frecuentemente se regala pescado en muelle. Para que el stock físico cuadre con el stock del sistema, se debe registrar esta salida sin afectar las finanzas. (Regla pendiente de confirmación oficial por el CEO).
- **Acción Pendiente:** Planificar la posibilidad de registrar una Venta o Salida de stock etiquetada como "Cortesía/Estiba" con `precio_unitario = 0.00`.
- **Estado:** 🟡 Pendiente de Confirmación de Negocio.

### Issue #012: Estado de Bloqueo de Cámara Cargada
- **Descripción:** Un cuadre cerrado no debe permitir ediciones posteriores para evitar "doble contabilidad" o fraude.
- **Acción Pendiente:** Implementar un estado `CERRADO_BLOQUEADO` en `cuadres_zarpe`. Si una cámara alcanza las 500 cajas (o se marca como cerrada), las políticas RLS y la App deben rechazar cualquier INSERT/UPDATE relacionado, requiriendo autorización de `administrador`.
- **Estado:** 🟡 Pendiente de Políticas RLS.

### Issue #013: Log de Auditoría para "Precio Pactado"
- **Descripción:** El precio de compra/venta es dinámico y se negocia. Si un operador lo cambia, el administrador debe saber quién y cuándo lo hizo.
- **Acción Pendiente:** Crear tabla `audit_log_precios` y un trigger en `lotes_pesca` que registre el precio antiguo, el nuevo y el ID del usuario.
- **Estado:** 🟡 Pendiente de Trigger en Supabase.
