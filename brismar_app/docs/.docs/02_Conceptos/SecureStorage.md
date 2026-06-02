# 🔒 SecureStorage

> Sistema de almacenamiento seguro y encriptado que resguarda las credenciales de sesión activas en el dispositivo móvil.
> Usado en: [[MODULO_AUTENTICACION]]

---

## Configuración Técnica
- **Archivo**: `lib/nucleo/seguridad/secure_storage_helper.dart`
- **Clase**: `SecureStorageHelper` (Patrón Singleton via `SecureStorageHelper.instance`).
- **Librería**: `flutter_secure_storage` (usa KeyStore en Android y Keychain en iOS).

---

## Llaves de Almacenamiento (Key-Value)
- **`auth_token`**: Almacena el identificador único del usuario (`id` o UUID de [[Usuario]] devuelto por [[Supabase]]) cuando la sesión está activa.

---

## Ciclo de Vida de la Sesión en Código

### 1. Iniciar Sesión (`guardarToken`)
Cuando el repositorio valida las credenciales y descarga el objeto [[Usuario]], invoca:
```dart
await _secureStorage.guardarToken(user.id);
```

### 2. Auto-login al abrir la App (`obtenerToken`)
En la inicialización del `AuthNotifier` de [[Riverpod]], se ejecuta `verificarSesionActiva()`:
```dart
final token = await _repositorio.obtenerUsuarioActual();
```
Si el token en `SecureStorage` no es nulo, la app inicia directamente en `/registro` sin pedir credenciales.

### 3. Cerrar Sesión (`eliminarToken`)
Al presionar el botón de desconexión en el encabezado de la interfaz, se llama a:
```dart
await _secureStorage.eliminarToken();
```
Esto limpia la memoria segura previniendo accesos no autorizados.

#brismar #tecnologia #securestorage #seguridad
