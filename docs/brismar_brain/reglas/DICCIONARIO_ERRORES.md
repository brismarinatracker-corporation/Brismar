# Diccionario Global de Errores - BRISMAR APP

Este documento define la estructura estandarizada de manejo de errores, códigos de error y respuestas para **BRISMAR APP**. Su diseño está inspirado en esquemas de producción modernos (como los de Stripe, AWS y las guías de arquitectura limpia de Google/Reddit) adaptados para el entorno desafiante de alta mar (funcionamiento Offline/Online).

---

## 1. Estructura de Códigos de Error

Cada error de la aplicación debe expresarse bajo el formato:
`[CATEGORÍA]-[CORRELATIVO]` (Ejemplo: `AUTH-001`)

### Categorías Definidas:
| Prefijo | Área del Sistema | Descripción |
| :--- | :--- | :--- |
| **AUTH** | Autenticación y Acceso | Inicio de sesión, expiración de tokens, registro inicial, etc. |
| **NET** | Conectividad y Sincronización | Fallos de red, sincronización de base de datos local/remota, timeouts. |
| **DB** | Almacenamiento Local | Problemas con SQLite local, FlutterSecureStorage, corrupción de datos. |
| **VAL** | Validación de Datos | Formularios incorrectos, formatos de entrada inválidos, PIN no conforme. |
| **BIO** | Hardware Biométrico | Sensores de huellas, rostro, denegaciones del sistema operativo. |
| **SRV** | Servidor (Supabase) | Errores específicos devueltos por PostgreSQL, funciones Edge, RPC. |
| **GEN** | Errores Genéricos | Excepciones no controladas, fallas del hilo principal. |

---

## 2. Diccionario de Códigos de Error

### Área: Autenticación y Autorización (`AUTH`)

| Código | Mensaje al Usuario | Descripción Técnica | Acción Recomendada / Mitigación |
| :--- | :--- | :--- | :--- |
| `AUTH-001` | Usuario o contraseña incorrectos. | Error al verificar credenciales contra Supabase Auth o hash local. | Verificar que el correo y contraseña ingresados sean correctos. |
| `AUTH-002` | El código PIN ingresado es incorrecto. | Comparación local del PIN (cifrado con BCrypt) falló. | Intentar de nuevo. Tras 5 intentos fallidos, se forzará relogueo online. |
| `AUTH-003` | Tu sesión ha expirado (12h de gracia). | El periodo de gracia desde la última verificación completa ha vencido. | Autenticarse mediante PIN o Biometría en la pantalla de acceso rápido. |
| `AUTH-004` | Acceso denegado. Rol de usuario no autorizado. | El rol retornado por la BD (`bahia`, `tripulante`, etc.) no tiene permisos. | Contactar con la mesa de soporte para verificar privilegios del usuario. |
| `AUTH-005` | No existen credenciales almacenadas para inicio offline. | Se intentó loguear offline pero es la primera vez que se usa el dispositivo. | Se requiere conexión a internet (en puerto) para realizar el primer login. |

---

### Área: Conectividad y Sincronización (`NET`)

| Código | Mensaje al Usuario | Descripción Técnica | Acción Recomendada / Mitigación |
| :--- | :--- | :--- | :--- |
| `NET-001` | Sin conexión a internet. Cambiando a modo offline. | `VerificadorConexion` detecta ausencia de conexión activa. | La app sigue operativa de forma local. Los datos se sincronizarán al volver. |
| `NET-002` | Tiempo de espera de conexión agotado (Timeout). | La petición HTTP/Websocket al servidor excedió el tiempo límite. | Reintentar la operación. Si persiste, el sistema pasará a modo offline temporal. |
| `NET-003` | Error en la sincronización de datos con el servidor. | Falló el volcado de datos locales (SQLite) a Supabase remoto. | Los datos se mantienen a salvo localmente. El lote se encola para reintento. |
| `NET-004` | Conflicto de versión de datos al sincronizar. | El registro modificado localmente fue actualizado previamente en el servidor. | Aplicar estrategia de resolución de conflictos (Last-Write-Wins o mezcla). |

---

### Área: Almacenamiento Local (`DB`)

| Código | Mensaje al Usuario | Descripción Técnica | Acción Recomendada / Mitigación |
| :--- | :--- | :--- | :--- |
| `DB-001` | No se pudo inicializar la base de datos local. | Error crítico al abrir la base de datos SQLite. | Reintentar apertura de la app. Si persiste, verificar espacio en disco. |
| `DB-002` | Error al escribir datos locales. | Falló la ejecución de una consulta de escritura (INSERT/UPDATE) en SQLite. | Validar restricciones de clave y espacio en almacenamiento. |
| `DB-003` | Error de lectura en la memoria segura. | Fallo al leer llaves cifradas desde `FlutterSecureStorage`. | Solicitar relogueo completo para regenerar las llaves de cifrado locales. |
| `DB-004` | Corrupción de base de datos local detectada. | La firma de integridad de la base de datos SQLite no coincide. | Respaldar log de transacciones y forzar descarga limpia desde el servidor. |

---

### Área: Hardware Biométrico (`BIO`)

| Código | Mensaje al Usuario | Descripción Técnica | Acción Recomendada / Mitigación |
| :--- | :--- | :--- | :--- |
| `BIO-001` | Sensor biométrico no disponible en este dispositivo. | El sistema operativo indica que el hardware de biometría no existe. | Usar el PIN de seguridad o credenciales completas para acceder. |
| `BIO-002` | No tienes huellas o rostros registrados en el celular. | El dispositivo tiene sensor pero el usuario no ha configurado sus datos. | Ir a los Ajustes de Seguridad del Celular para registrar su huella. |
| `BIO-003` | Huella dactilar o rostro no reconocidos. | El lector falló al emparejar los datos biométricos. | Intentar de nuevo con cuidado. Alternativamente, usar el PIN de 4 dígitos. |
| `BIO-004` | El lector biométrico se encuentra bloqueado temporalmente. | Demasiados intentos fallidos en el lector biométrico. | Desbloquear el teléfono con el método del sistema (patrón) o usar PIN. |

---

### Área: Servidor y API de Supabase (`SRV`)

| Código | Mensaje al Usuario | Descripción Técnica | Acción Recomendada / Mitigación |
| :--- | :--- | :--- | :--- |
| `SRV-001` | El servidor de base de datos no responde. | Supabase está experimentando inactividad o mantenimiento. | La app activa cola de resiliencia local en SQLite. Reintentar en puerto. |
| `SRV-002` | Error en la consulta del servidor (Base de Datos). | Error SQL devuelto por PostgreSQL (violación de constraints, etc.). | Registrar traza del error en la cola local para análisis del administrador. |
| `SRV-003` | Error en función externa del servidor. | Fallo de ejecución en una Edge Function o RPC de Supabase. | Reintentar operación. |

---

### Área: Errores Genéricos (`GEN`)

| Código | Mensaje al Usuario | Descripción Técnica | Acción Recomendada / Mitigación |
| :--- | :--- | :--- | :--- |
| `GEN-001` | Ha ocurrido un error inesperado en la aplicación. | Excepción no controlada arrojada en tiempo de ejecución. | Mostrar traza amigable. Enviar reporte de error a la consola de soporte. |
| `GEN-002` | Espacio en almacenamiento insuficiente. | El sistema operativo no tiene espacio libre para escribir archivos locales. | Liberar espacio eliminando archivos innecesarios en el celular. |

---

## 3. Implementación en Código (Patrón Repositorio y Mapeo)

El mapeo de excepciones genéricas a este diccionario se gestiona centralizadamente en la clase `DiccionarioErrores` de la capa de núcleo:

1. **Definición de Clases**: 
   Cada capa debe capturar sus excepciones nativas (como `AuthException` de Supabase o `PlatformException` de local_auth) y convertirlas a excepciones de dominio.
   
2. **Mapeador Centralizado**:
   El mapeador en la UI o en los controladores traduce estas excepciones a un objeto `DetalleError` antes de pintarlo en la pantalla del usuario.

3. **Ejemplo de Uso en UI (SnackBar o Diálogos)**:
   ```dart
   // Al capturar un estado de error en la UI:
   ref.listen(proveedorControladorAutenticacion, (prev, next) {
     if (next is EstadoAutenticacionError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(next.mensaje), // Ej: "(AUTH-001) Usuario o contraseña incorrectos."
           backgroundColor: Colors.redAccent,
         ),
       );
     }
   });
   ```

---

## 4. Estrategia Offline y Resiliencia de Errores

Cuando la app está navegando en alta mar:
- Los errores de categoría `NET` no bloquean el flujo de trabajo crítico (registro de pesca, bitácora).
- Se interceptan silenciosamente y el motor de sincronización marca el lote de datos con un flag de reintento.
- Los errores críticos de tipo `DB` y `AUTH` sí se notifican de inmediato con su código para evitar pérdida de datos o accesos no autorizados.
