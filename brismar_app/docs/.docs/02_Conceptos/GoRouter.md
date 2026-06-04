# 🧭 GoRouter

> Enrutador declarativo para la navegación entre pantallas en BRISMAR.
> Usado en: [[MODULO_AUTENTICACION]] · [[MODULO_REGISTRO]]

---

## Configuración Técnica
- **Archivo**: `lib/nucleo/rutas/enrutador.dart`
- **Variable**: `enrutador` (`GoRouter`)
- **Punto de Entrada**: Asignado en `main.dart` mediante `MaterialApp.router(routerConfig: enrutador)`.

---

## Mapa de Rutas de la Aplicación

| Ruta | Pantalla Asociada | Comportamiento / Acceso |
|---|---|---|
| `/login` | `LoginPantalla` | Pantalla inicial de inicio de sesión. Muestra formulario de credenciales. |
| `/registro` | `RegistroPantalla` | Panel principal del operador. Formulario de descarga, gastos, totales e historial. |

---

## Flujo de Navegación y Transición
La navegación se dispara desde el controlador reactivo de [[Riverpod]]:
1. **Inicio de sesión exitoso**: `AuthNotifier` cambia de `EstadoAutenticacionInicial` o `EstadoAutenticacionNoAutenticado` a `EstadoAutenticacionAutenticado`. En la UI de login, al detectar el cambio, se dispara:
   ```dart
   context.go('/registro');
   ```
2. **Cierre de sesión**: Al presionar cerrar sesión en la cabecera (`UserHeader`), `AuthNotifier` borra las credenciales en [[SecureStorage]] y se dispara la vuelta al login:
   ```dart
   context.go('/login');
   ```

#brismar #tecnologia #gorouter #navegacion
