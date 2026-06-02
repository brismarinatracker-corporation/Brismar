# 🔄 Riverpod

> Sistema reactivo para la gestión de estado de BRISMAR, que conecta las pantallas de presentación con los casos de uso del dominio.
> Usado en: [[MODULO_AUTENTICACION]] · [[MODULO_REGISTRO]]

---

## Árbol de Proveedores y Controladores (State Management)

### 🔐 Proveedores de Autenticación
Ubicados en `lib/modulos/autenticacion/presentacion/controladores/auth_controlador.dart`:
- **`proveedorAuthRepositorio`** (`Provider<AuthRepositorio>`): Crea la instancia concreta de `AuthRepositorioImp` pasándole el cliente remoto y el helper local.
- **`proveedorAuthController`** (`StateNotifierProvider<AuthNotifier, EstadoAutenticacion>`): Controla la sesión del usuario.
  - **Estados** (`EstadoAutenticacion`): `Inicial`, `Cargando`, `Autenticado(usuario)`, `NoAutenticado`, `Error(mensaje)`.
  - **Acciones**: `iniciarSesion()`, `cerrarSesion()`, y la auto-verificación `verificarSesionActiva()`.

### 📋 Proveedores de Registro de Pesca
Ubicados en `lib/modulos/registro/presentacion/controladores/registro_controlador.dart`:
- **`proveedorRegistroRepositorio`** (`Provider<RegistroRepositorio>`): Inicializa la implementación que amarra SQLite y Supabase.
- **`proveedorGuardarRegistro`**, **`proveedorObtenerHistorial`**, **`proveedorSincronizarPendientes`** (`Provider<CasoUso>`): Instancian los casos de uso específicos del dominio.
- **`proveedorHistorialController`** (`StateNotifierProvider<HistorialNotifier, AsyncValue<List<RegistroEntidad>>>`):
  - Controla la lista de registros mostrados en la pantalla `RegistroPantalla`.
  - Carga el historial desde el caso de uso y permite registrar nuevas descargas actualizando la UI de inmediato.
- **`proveedorSyncController`** (`StateNotifierProvider<SyncNotifier, AsyncValue<void>>`):
  - Controla la sincronización offline hacia [[Supabase]].

---

## ⚡ Escucha de Conectividad Automática (Sincronización en Segundo Plano)
La clase `SyncNotifier` utiliza el plugin `connectivity_plus` para monitorear la red móvil y Wifi de forma continua:
```dart
Connectivity().onConnectivityChanged.listen((results) {
  final hasConnection = results.any((result) =>
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet);

  if (hasConnection) {
    ejecutarSincronizacion();
  }
});
```
Cuando el celular recupera conexión:
1. `SyncNotifier` detecta el cambio.
2. Invoca el caso de uso `SincronizarPendientesCasoUso`.
3. Sube las filas pendientes de [[SQLite]] a [[Supabase]].
4. Notifica a `proveedorHistorialController` para recargar y refrescar los indicadores visuales de sincronización.

#brismar #tecnologia #riverpod #estado
