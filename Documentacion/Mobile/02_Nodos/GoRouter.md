# 🛣️ Enrutamiento Declarativo (GoRouter)

Sistema centralizado de navegación en Flutter. Convierte cambios de URL y empujes de rutas en una estructura predecible.

## Archivo Central
📁 `bris_tracker/lib/nucleo/rutas/enrutador.dart`

## Funcionamiento
Usamos el paquete `go_router`. El archivo define algo como:

```dart
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPantalla(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardCuadresPantalla(),
    ),
  ],
);
```

### Funciones de Seguridad (Redirección)
El enrutador está vinculado al estado del [[MODULO_AUTENTICACION]]. Si un usuario sin sesión intenta ir a `/dashboard`, `GoRouter` lo redirige (intercepta) obligatoriamente al `/login`.

---
#brismar #rutas #gorouter #infraestructura #nodo
