# Flujo 01: Autenticación Completa Online/Offline y Acceso Simplificado

Este documento describe detalladamente la lógica, la experiencia de usuario y las especificaciones técnicas del flujo de inicio de sesión de la aplicación móvil de Brismar para el **Personal de Bahía**.

Para evitar la fricción de ingresar correo y contraseña constantemente, se implementa un **Flujo Híbrido de Doble Estado**.

---

## 🗺️ Diagrama de Procesos (Carriles / Swimlanes)

El siguiente diagrama detalla la lógica de decisión y validación de la aplicación:

```mermaid
graph TB
    subgraph Bahia ["Personal de Bahía (Usuario)"]
        A[Abrir Aplicación]
        InputFull[Ingresar Correo y Contraseña]
        SetupPIN[Configurar PIN - Obligatorio]
        SetupBio[Configurar Huella - Opcional]
        InputPIN[Digitar PIN en Pantalla Numérica]
        ProvideBio[Colocar Huella Digital]
        ClickForgotPIN[Presionar 'Olvidé mi PIN']
        Dashboard[Acceder al Dashboard]
    end

    subgraph AppMobile ["Aplicación Móvil (App & Bóveda Segura)"]
        A --> CheckSession{¿Existe Token Local?}
        
        %% RUTA A: LOGIN INICIAL COMPLETO (No existe Token)
        CheckSession -- No --> InputFull
        InputFull --> CheckNetwork{¿Tiene Internet?}
        
        %% Validaciones de Login Inicial
        CheckNetwork -- Sí --> OnlineAuth[Solicitar Auth Online]
        CheckNetwork -- No --> OfflineAuth[Buscar Hash en Bóveda Segura]
        
        OfflineAuth --> CheckHash{¿Coincide Hash BCrypt?}
        CheckHash -- Sí --> SetupPIN
        CheckHash -- No (Error) --> InputFull
        CheckHash -- No (Sin Registro) --> FailNoCache[Error: Requiere Login Online]
        
        %% Configuración de Acceso Rápido tras Login Exitoso
        SetupPIN --> SetupBio
        SetupBio --> SaveSession[Guardar Token, Hash, PIN/Bio y Timestamp de Verificación]
        SaveSession --> Dashboard
        
        %% RUTA B: ACCESO RÁPIDO DIARIO (Sí existe Token)
        CheckSession -- Sí --> CheckGrace{¿Última verificación < 12 horas?}
        CheckGrace -- Sí --> Dashboard
        CheckGrace -- No --> CheckQuickPref{Preferencia de Acceso}
        
        %% Flujo de Re-verificación
        CheckQuickPref -- PIN --> InputPIN
        CheckQuickPref -- Biometría --> ProvideBio
        
        %% Validaciones de PIN / Biometría
        InputPIN --> CheckPIN{¿PIN Correcto?}
        CheckPIN -- Sí --> UpdateTimestamp[Actualizar Timestamp de Verificación]
        CheckPIN -- No --> InputPIN
        
        ProvideBio --> CheckBio{¿Huella Correcta?}
        CheckBio -- Sí --> UpdateTimestamp
        CheckBio -- No --> ProvideBio
        
        %% Rutas de Escape / Recuperación
        InputPIN --> ClickForgotPIN
        ProvideBio --> ClickForgotPIN
        ClickForgotPIN --> ClearSession[Limpiar Sesión y Forzar Login Completo]
        ClearSession --> InputFull
        UpdateTimestamp --> Dashboard
    end

    subgraph Supabase ["Servidor Central (Supabase)"]
        OnlineAuth --> SupabaseVerify[Validar Credenciales y Token]
        SupabaseVerify --> CheckCredentials{¿Credenciales Válidas?}
        CheckCredentials -- Sí --> SetupPIN
        CheckCredentials -- No --> InputFull
    end
```

---

## 🔐 Especificaciones de Seguridad y Usabilidad

### Fase 1: Inicio de Sesión Inicial (Completo)

* **Cuándo ocurre**: La primera vez que se usa la app en el dispositivo, o tras un cierre de sesión manual que destruye el token local.
* **Proceso**:
  1. El usuario ingresa su **Correo y Contraseña** (es el único proceso de red que no requiere token, ya que es el que lo genera).
  2. Al presionar "Iniciar Sesión", la app evalúa si cuenta con conexión a internet.
  3. **Con Internet (Online)**: Envía la petición a Supabase, valida las credenciales y genera el token de autorización JWT.
  4. **Sin Internet (Offline)**: Compara los datos ingresados contra el hash **BCrypt** almacenado en la **Bóveda Segura** del dispositivo. Si no existe registro previo offline de ese usuario, se rechaza la autenticación indicando que requiere conectarse a internet.
  5. **Configuración de Acceso Rápido**: Tras el login exitoso, se le exige al usuario definir un **PIN numérico (Obligatorio)** y se le ofrece configurar la **Huella Digital (Opcional)**.
  6. **Persistencia**: Se encriptan y guardan en la Bóveda Segura (`Flutter Secure Storage`):
     * El token local de autorización.
     * El hash de contraseña para ingresos offline.
     * Las preferencias de acceso (PIN y huella).
     * El timestamp exacto de la verificación actual.

---

### Fase 2: Acceso Simplificado (Uso Diario)

* **Cuándo ocurre**: Cada vez que el usuario abre la app y ya cuenta con un token almacenado localmente.
* **Proceso**:
  1. La app pregunta si la última verificación de identidad ocurrió hace **menos de 12 horas**.
  2. **Menos de 12 horas**: El usuario entra directamente al **Dashboard** sin interrupciones.
  3. **Más de 12 horas**: Se bloquea la pantalla y se le pide re-verificar su identidad:
     * Por defecto se presenta el teclado numérico del **PIN** (obligatorio).
     * Si activó la biometría, el sistema invoca automáticamente el lector de **Huella Digital**.
  4. **Actualización de Tiempo**: Una vez que el usuario ingresa su PIN o Huella de forma exitosa, la aplicación **actualiza el timestamp de última verificación** en la Bóveda Segura, reiniciando el temporizador de 12 horas de gracia.

---

### 🛡️ Rutas de Escape y Casos de Recuperación

1. **Olvidé mi PIN**:
   * En la pantalla de ingreso del PIN, se muestra la opción *"Olvidé mi PIN"*.
   * Al presionarla, la aplicación **invalida el acceso rápido actual** y limpia el PIN anterior de la Bóveda Segura.
   * Se solicita al usuario autenticarse ingresando su **Correo y Contraseña** para validar su identidad de forma segura.
   * Una vez completado el inicio de sesión con credenciales, la app lo redirige obligatoriamente a la pantalla de **Configurar PIN**, donde registrará su nuevo código de acceso rápido para restablecer el flujo de uso diario.
2. **Olvidé mi Contraseña**:
   * En la pantalla de login con credenciales completas, habrá un botón de ayuda y recuperación. Dado que en alta mar no se pueden procesar envíos de correo automáticos, el botón mostrará información de contacto de soporte local y el muelle de ayuda en tierra para el reestablecimiento de credenciales por el administrador del sistema.

---

## 🏗️ Arquitectura de Clases y Relaciones de Código

Para comprender cómo se plasma el flujo de autenticación anterior a nivel de componentes y clases en el código de Flutter, se presenta el siguiente diagrama estructural:

```mermaid
classDiagram
    class LoginPantalla {
        +build(context) Widget
    }
    class FormularioLogin {
        -_userController : TextEditingController
        -_passController : TextEditingController
        -_hayConexion : bool
        -_passwordObscuro : bool
        -_intentarLogin() : void
        +build(context) Widget
    }
    class NotificadorAutenticacion {
        -_repositorio : RepositorioAutenticacion
        +verificarSesionActiva() : Future
        +iniciarSesion(usuario, password) : Future
        +cerrarSesion() : Future
    }
    class RepositorioAutenticacion {
        <<interface>>
        +iniciarSesion(usuario, password) : Future
        +cerrarSesion() : Future
        +obtenerUsuarioActual() : Future
    }
    class RepositorioAutenticacionImpl {
        -_remotoDatasource : FuenteDatosAutenticacionRemota
        -_secureStorage : GestorAlmacenamientoSeguro
        +iniciarSesion(usuario, password) : Future
        +cerrarSesion() : Future
        +obtenerUsuarioActual() : Future
    }
    class FuenteDatosAutenticacionRemota {
        +iniciarSesion(correo, password) : Future
        +cerrarSesion() : Future
    }
    class GestorAlmacenamientoSeguro {
        +guardarToken(token) : Future
        +guardarCredencialesOffline(hash, userData) : Future
        +obtenerToken() : Future
        +obtenerHashOffline() : Future
        +obtenerDatosUsuarioOffline() : Future
        +eliminarToken() : Future
    }
    class ServicioCifrado {
        +hashearPasswordBcrypt(password) : String
        +verificarPasswordBcrypt(password, hash) : bool
        +cifrarAes(texto, clave, iv) : String
        +descifrarAes(cifrado, clave, iv) : String
    }

    LoginPantalla ..> FormularioLogin : contiene
    FormularioLogin ..> NotificadorAutenticacion : consume (Riverpod)
    NotificadorAutenticacion --> RepositorioAutenticacion : usa
    RepositorioAutenticacion <|.. RepositorioAutenticacionImpl : implementa
    RepositorioAutenticacionImpl --> FuenteDatosAutenticacionRemota : usa
    RepositorioAutenticacionImpl --> GestorAlmacenamientoSeguro : usa
    RepositorioAutenticacionImpl ..> ServicioCifrado : usa para hashear/validar
```

---

## 🔗 Enlaces Relacionados

* ¿Por qué decidimos hacerlo así? Revisa [[HISTORIAL_Y_CONTEXTO]].
* Reglas de encriptación y base de datos local: [[ARQUITECTURA_Y_REGLAS]].
