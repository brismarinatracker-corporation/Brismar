# Mapa de Riesgos e Ingeniería de Fiabilidad (BRISMAR APP)

Brismar opera en entornos hostiles (alta mar, muelles sin conexión estable, dispositivos móviles expuestos a daños, pérdidas o robos). Este documento agrupa los peores escenarios técnicos y operacionales y describe cómo la arquitectura de software los mitiga.

---

## 1. Riesgo Físico: Robo o Pérdida de Dispositivo

* **Severidad:** Crítica | **Probabilidad:** Alta
* **Descripción:** Un celular corporativo con la aplicación activa es robado en el muelle. El dispositivo contiene hashes de contraseñas, tokens de sesión activos y datos de pesaje histórico.
* **Mitigación:**
  * **Cifrado Local:** La base de datos local SQLite y los datos de preferencias (`SharedPreferences`) están cifrados mediante **SQLCipher** utilizando la llave maestra del dispositivo. Es imposible leer la data extrayendo el almacenamiento físico sin la clave.
  * **Revocación Remota:** El administrador web puede marcar el dispositivo como "comprometido" desde el panel de Supabase. RLS (Row Level Security) bloqueará de inmediato cualquier intento de sincronización de la API usando ese token de sesión.

## 2. Riesgo de Datos: Conflicto de Concurrencia (Sincronización Offline)

* **Severidad:** Alta | **Probabilidad:** Media
* **Descripción:** Dos operarios registran información offline para un mismo viaje de pesca de forma simultánea. Al recuperar señal, ambos envían sus registros concurrentemente provocando colisiones o sobreescritura de transacciones.
* **Mitigación:**
  * **Event Sourcing (Cola Secuencial):** SQLite encolar los eventos de creación/edición secuencialmente usando UUIDs autogenerados para evitar colisiones de llaves primarias.
  * **Estrategia de Resolución:** Supabase aplica políticas RLS combinadas con triggers de base de datos que manejan estrategias de reconciliación "Last-Write-Wins" y auditoría detallada de cambios anteriores.

## 3. Riesgo de Credenciales: Fuga de Claves Maestras

* **Severidad:** Crítica | **Probabilidad:** Baja
* **Descripción:** Fuga pública de tokens de Supabase o credenciales de la base de datos a repositorios de código abierto (GitHub).
* **Mitigación:**
  * **Inyección en Compilación:** Exclusión del archivo `CREDENCIALES_MAESTRAS.env` en `.gitignore`.
  * **Uso de `--dart-define`:** Los pipelines de CI/CD de GitHub Actions inyectan las llaves de producción dinámicamente como variables en la compilación CanvasKit/Móvil, impidiendo que los secretos estén escritos físicamente en el código Dart.

## 4. Riesgo Financiero: Fórmulas Excel Inconsistentes o Rotas

* **Severidad:** Alta | **Probabilidad:** Alta
* **Descripción:** Los archivos Excel exportados a los clientes son modificados accidentalmente por el administrador o la planta pesquera, rompiendo cálculos matemáticos críticos (tara, flete prorrateado o reparto 50/50).
* **Mitigación:**
  * **Fórmulas Nativas Dinámicas:** La exportación a Excel ([servicio_exportacion.dart](file:///home/jhonataningesis/Documentos/Brismar/BRISMAR_APP/bris_web/lib/modulos/cuadres/servicios/servicio_exportacion.dart)) inyecta de forma obligatoria fórmulas nativas de Excel (como `=SUM(...)` o `=K25/F10`) en lugar de strings de texto o números estáticos precalculados. Si el usuario modifica los kilos, el archivo recalculará las utilidades de forma dinámica.

## 5. Riesgo de Infraestructura: Pérdida de Conectividad Prolongada (Muelle)

* **Severidad:** Media | **Probabilidad:** Muy Alta
* **Descripción:** Un dispositivo pasa más de 10 días seguidos sin acceso a internet en una embarcación o zona aislada, acumulando miles de registros pesados en la cola SQLite que podrían saturar el almacenamiento del teléfono.
* **Mitigación:**
  * **Paginación y Purga:** El motor local de SQLite está configurado para purgar registros con estado `SYNCED` que superen los 15 días de antigüedad una vez confirmada su carga completa en Supabase.
  * **Optimización de Payload:** Las fotos o firmas asociadas a las guías de remisión no se almacenan como blobs binarios en SQLite; se guardan como archivos temporales del sistema y se suben directamente al Bucket de Supabase Storage una vez detectada una conexión robusta (limitando la cola de base de datos a metadatos ligeros).

## 6. Riesgo Operativo: Modificación Maliciosa Post-Zarpe

* **Severidad:** Alta | **Probabilidad:** Media
* **Descripción:** Un bahía intenta modificar las compras o fletes prorrateados de una cámara frigorífica que ya zarpó o que ya fue liquidada para alterar las utilidades compartidas.
* **Mitigación:**
  * **Bloqueo de Estado:** Al establecer la cámara en estado `CERRADO`, la aplicación móvil bloquea todas las vistas de edición.
  * **Protección por Base de Datos:** Triggers en PostgreSQL (Supabase) restringen cualquier operación de tipo `UPDATE` o `DELETE` sobre registros asociados a cuadres cerrados, retornando un código de error de base de datos a menos que la transacción provenga de un usuario Administrador corporativo autenticado.

## 7. Riesgo de Fuga de Lógica Financiera

* **Severidad:** Media | **Probabilidad:** Alta
* **Descripción:** Exposición de márgenes corporativos a operarios en el muelle, revelando las lógicas de utilidades y los esquemas 50/50.
* **Mitigación:**
  * **Ocultamiento de Lógica:** Mitigado ocultando la lógica de reparto 50/50 en la aplicación móvil de los operarios.
