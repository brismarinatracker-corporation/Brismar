# 🌊 Riverpod (Gestión de Estado)

Herramienta para gestionar estados reactivos y proveer inyección de dependencias en Flutter sin usar `StatefulWidget`.

## ¿Dónde se usa?
Principalmente en la capa de **Presentación** (Controladores).

Ejemplos:
- `bris_tracker/lib/modulos/autenticacion/presentacion/controladores/controlador_autenticacion.dart`
- `bris_tracker/lib/modulos/registro_pesca/presentacion/controladores/controlador_zarpes.dart`

## ¿Cómo funciona aquí?
Declaramos _providers_ globales que instancian los repositorios y casos de uso, por ejemplo:

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(remoteDataSource: ref.watch(authRemoteDataSourceProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(repository: ref.watch(authRepositoryProvider));
});
```
La UI simplemente hace `ref.watch(authControllerProvider)` y si el estado cambia (ej. de "cargando" a "autenticado"), la pantalla se redibuja mágicamente. Es el pegamento que conecta la UI con el [[MODULO_AUTENTICACION]].

---
#brismar #estado #riverpod #presentacion #nodo
