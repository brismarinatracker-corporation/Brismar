# Flujo 05: Protocolo de Revocación y Autodestrucción por Robo del Dispositivo

Este documento detalla el protocolo de seguridad y contingencia técnica que se ejecuta cuando un dispositivo móvil con la aplicación de Brismar es reportado como robado o extraviado en la bahía de operaciones.

---

## 🗺️ Diagrama de Procesos (Carriles / Swimlanes)

El siguiente diagrama ilustra la cadena de eventos desde el reporte del robo en tierra hasta el bloqueo absoluto y borrado de la base de datos cifrada en el celular:

```mermaid
graph TB
    subgraph Admin ["Administrador de Oficina (Tierra)"]
        Report[Recibir Reporte de Robo/Pérdida de Celular] --> RevokeAuth[Ingresar a Consola Supabase y Revocar Sesión del Usuario]
    end

    subgraph Supabase ["Servidor Central (Supabase / Nube)"]
        RevokeAuth --> InvalidateToken[Marcar Token de Usuario como Inválido / Revocado]
        
        ApiRequest{¿Intento de Conexión del Dispositivo?}
        
        InvalidateToken --> ApiRequest
        ApiRequest -->|Sí| RejectAuth[Responder con Código HTTP 401 Unauthorized / Sesión Revocada]
    end

    subgraph AppMobile ["Aplicación Móvil (Dispositivo Robado)"]
        RejectAuth --> TriggerLockout[Gatillo: Alerta de Seguridad Activada]
        
        TriggerLockout --> CloseDB[Cerrar Conexión Activa de Base de Datos SQLite]
        CloseDB --> WipeKeys[Borrar Master Key de SQLCipher del Secure Storage]
        WipeKeys --> WipeCache[Borrar datos offline JSON y Hash de Contraseña BCrypt]
        WipeCache --> BrickApp[Bloquear UI permanentemente con Pantalla de Alerta]
        
        BrickApp --> EndState[Dispositivo Inutilizable para Robo de Información]
    end

    subgraph SQLCipher ["Base de Datos Local Cifrada (SQLCipher)"]
        WipeKeys -.->|Sin Master Key| DataInaccessible[Archivos de SQLite en Disco se vuelven Ilegibles / Encriptación Raw]
    end
```

---

## 📊 Especificación Técnica del Protocolo de Seguridad

### 1. Revocación en el Servidor (Supabase)

Cuando el administrador en tierra confirma el robo del dispositivo, ejecuta la desactivación desde la consola central:

* Invalida el JWT activo del usuario.
* En la base de datos, marca la columna `activo = false` en la tabla `usuarios` (bloqueando de inmediato cualquier validación offline en futuros accesos).
* Cualquier llamada a la API (sincronización o consulta) que realice la app usando ese token recibirá inmediatamente un error HTTP **`401 Unauthorized`** con el mensaje de sesión inválida.

### 2. Autodestrucción Local de Datos (Device Wipe - Online)

En el momento en que la aplicación móvil recibe el código `401` o el flag de usuario bloqueado:

1. **Cierre de SQLCipher:** Cierra inmediatamente la conexión activa a la base de datos local SQLite utilizando `GestorBaseDatos.instance.close()` para evitar lecturas en memoria.
2. **Destrucción de Claves de Cifrado:** Llama al `secureStorage.deleteAll()` ([gestor_almacenamiento_seguro.dart](file:///home/jhonataningesis/Documentos/Brismar/BRISMAR_APP/brismar_app/lib/nucleo/seguridad/gestor_almacenamiento_seguro.dart)), borrando:
   * La clave maestra de encriptación de SQLCipher.
   * El token JWT y refresh token de Supabase.
   * El hash de contraseña local (`offline_password_hash`).
   * Los datos del usuario offline (`offline_user_data`).
3. **Inutilización Física de la BD:** Sin la clave maestra almacenada en el Secure Storage del hardware, el archivo `.db` en el almacenamiento del dispositivo se convierte en ruido binario aleatorio inservible. Ningún software de extracción forense de datos podrá leer los kilos de pesca o gastos históricos del viaje.
4. **Bloqueo de UI (Bricking):** La aplicación reemplaza la navegación y muestra en pantalla de forma permanente una vista de color rojo con el mensaje:
   > **"DISPOSITIVO BLOQUEADO POR SEGURIDAD. Contacte al administrador en el muelle."**
   * Esta pantalla bloquea el botón físico de volver atrás y no se quita incluso si el teléfono se reinicia o se abre offline.

### 3. Protocolo de Bloqueo Offline (Defensa contra Fuerza Bruta)

Si el dispositivo es desconectado de internet (modo avión) para evitar la revocación remota y se intenta descifrar el PIN por fuerza bruta:

* **Límite de Intentos Offline (MVP):** La aplicación móvil mantiene un contador local de intentos fallidos de PIN. Tras **5 intentos fallidos consecutivos sin conexión**, la app bloquea de inmediato el acceso rápido local (PIN/Biometría), borra las credenciales temporales y exige de forma obligatoria realizar un inicio de sesión online con correo y contraseña.
* **Auto-Detonación (Fase de Seguridad Avanzada - Pendiente):** En la fase de producción segura y con el cifrado de SQLCipher activo, tras 5 intentos fallidos se activará un protocolo de borrado total de la Bóveda Segura de hardware, cierre de base de datos SQLite y bloqueo físico permanente de la UI (autodestrucción).
* **Falso Positivo:** Si el acceso rápido se bloquea por error del usuario legítimo en el MVP, este podrá volver a ingresar simplemente restableciendo la sesión de forma online con sus credenciales completas. En la fase de seguridad avanzada, al eliminarse la llave de cifrado maestro local, la base de datos no podrá recuperarse y requerirá regeneración total desde Supabase tras habilitación del administrador.

---

## 🏗️ Arquitectura de Cierre de Seguridad en Código

```mermaid
classDiagram
    class InterceptorSupabase {
        +onError(error) void
        +onResponse(response) void
    }
    class GestorAlmacenamientoSeguro {
        +eliminarToken() Future
        +eliminarTodo() Future
    }
    class GestorBaseDatos {
        +close() Future
        +destruirBaseDatosLocal() Future
    }
    class PantallaBloqueoSeguridad {
        +build(context) Widget
    }

    InterceptorSupabase ..> GestorAlmacenamientoSeguro : detecta 401 y ejecuta delete
    InterceptorSupabase ..> GestorBaseDatos : cierra y purga
    InterceptorSupabase ..> PantallaBloqueoSeguridad : redirige y ancla UI
```

---

## 🔗 Enlaces Relacionados

* Cifrado de Base de Datos y Bóveda Segura: [[ARQUITECTURA_Y_REGLAS]].
* Manejo de variables de entorno y credenciales: [[FLUJO_DE_TRABAJO]].
* Gestores de seguridad locales: [gestor_almacenamiento_seguro.dart](file:///home/jhonataningesis/Documentos/Brismar/BRISMAR_APP/brismar_app/lib/nucleo/seguridad/gestor_almacenamiento_seguro.dart) y [servicio_cifrado.dart](file:///home/jhonataningesis/Documentos/Brismar/BRISMAR_APP/brismar_app/lib/nucleo/seguridad/servicio_cifrado.dart).
