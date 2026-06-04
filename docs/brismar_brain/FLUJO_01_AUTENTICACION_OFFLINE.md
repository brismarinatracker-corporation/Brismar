# Flujo 01: Autenticación Offline y Acceso Simplificado (Alta Mar)

Este nodo describe el comportamiento del inicio de sesión de la aplicación móvil de Brismar para el **Personal de Bahía**. Para evitar la fricción de ingresar correo y contraseña constantemente, se implementa un **Flujo Híbrido de Doble Estado**.

## Diagrama de Procesos (Carriles / Swimlanes)

El siguiente diagrama de carriles de procesos detalla cómo la App decide entre el **Login Inicial Completo** (la primera vez o tras cerrar sesión) y el **Acceso Simplificado** (PIN, Huella Digital o Acceso Directo):

```mermaid
graph TB
    subgraph Bahia ["Personal de Bahía (Usuario)"]
        A[Abrir Aplicación]
        InputFull[Ingresar Correo y Contraseña]
        SetupQuick[Configurar PIN y/o Huella Digital]
        InputPIN[Digitar PIN en Pantalla de Dígitos]
        ProvideBio[Colocar Huella Digital]
        Dashboard[Acceder al Dashboard]
    end

    subgraph AppMobile ["Aplicación Móvil (App & SQLite)"]
        A --> CheckSession{¿Existe Sesión Activa?}
        CheckSession -- No --> InputFull
        InputFull --> CheckNetwork{¿Tiene Internet?}
        
        %% Flujo Online
        CheckNetwork -- Sí --> OnlineAuth[Solicitar Auth Online]
        OnlineAuth --> CheckCredentials{¿Credenciales Válidas?}
        CheckCredentials -- Sí --> SetupQuick
        CheckCredentials -- No --> InputFull
        
        %% Flujo Offline
        CheckNetwork -- No --> OfflineAuth[Buscar Hash en SQLite Local]
        OfflineAuth --> CheckHash{¿Coincide Hash BCrypt?}
        CheckHash -- Sí --> SetupQuick
        CheckHash -- No (Error) --> InputFull
        CheckHash -- No (Sin Registro) --> FailNoCache[Error: Requiere Login Online]
        
        SetupQuick --> SaveSession[Guardar Token, Hash y Preferencias]
        SaveSession --> Dashboard
        
        %% Acceso Simplificado
        CheckSession -- Sí --> CheckQuickPref{Preferencia Activa}
        CheckQuickPref -- Directo --> Dashboard
        CheckQuickPref -- PIN --> InputPIN
        CheckQuickPref -- Biometría --> ProvideBio
        
        InputPIN --> CheckPIN{¿PIN Correcto?}
        CheckPIN -- Sí --> Dashboard
        CheckPIN -- No --> InputPIN
        
        ProvideBio --> CheckBio{¿Huella Correcta?}
        CheckBio -- Sí --> Dashboard
        CheckBio -- No --> ProvideBio
    end

    subgraph Supabase ["Servidor Central (Supabase)"]
        OnlineAuth --> SupabaseVerify[Validar Credenciales y Token]
        SupabaseVerify --> CheckCredentials
    end
```

## Especificaciones de Seguridad y Usabilidad

1. **Login Inicial Completo:**
   - Obligatorio en el primer inicio o si el usuario cierra su sesión de manera explícita (lo que elimina el token del almacenamiento seguro).
   - Valida la contraseña mediante hashes **BCrypt** de forma local si está offline, o directamente contra la API de **Supabase** si hay internet.
2. **Acceso Simplificado (PIN / Biometría):**
   - Si la sesión local (token) está activa y no ha expirado, el usuario no requiere ingresar su correo y contraseña.
   - El Personal de Bahía puede elegir activar el **PIN de 4 dígitos** o la **Biometría (Huella/Face ID)** desde el primer inicio de sesión exitoso.
   - Si no se define ninguno, la App arranca directamente en el Dashboard (Acceso Directo).
3. **Persistencia:**
   - La información de sesión y preferencias de acceso rápido se almacenan de manera encriptada y persistente en el dispositivo.

---

## 🔗 Enlaces Relacionados

- ¿Por qué decidimos hacerlo así? Revisa `[[03_HISTORIAL_Y_CONTEXTO]]`.
- Reglas de encriptación y base de datos local: `[[01_ARQUITECTURA_Y_REGLAS]]`.
