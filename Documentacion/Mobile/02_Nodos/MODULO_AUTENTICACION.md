# 🔐 Módulo Autenticación

El módulo encargado de gestionar el acceso a la aplicación móvil (bris_tracker), manejar tokens y establecer la sesión de [[Usuario]].

## Ubicación del Código
📁 `bris_tracker/lib/modulos/autenticacion/`

## Funcionalidad y Componentes (Clean Architecture)

### 1. Presentación (UI y Estado)
- **`controlador_autenticacion.dart`**: Usa [[Riverpod]] (`StateNotifier`) para mantener el estado de la sesión (Autenticado, Cargando, Error).
- **`login_pantalla.dart`**: Interfaz de usuario para ingresar credenciales (correo/contraseña).
- **`configurar_pin_pantalla.dart` / `acceso_rapido_pantalla.dart`**: Flujos posteriores al login inicial para agilizar la entrada.

### 2. Dominio (Reglas)
- **`repositorio_autenticacion.dart`**: Contrato (interfaz) que define qué debe hacer la capa de datos (`iniciarSesion`, `cerrarSesion`, `configurarPin`, etc.).
- **`usuario.dart`**: Entidad de negocio que mapea el perfil básico del trabajador.

### 3. Datos (Implementación)
- **`repositorio_autenticacion_impl.dart`**: Implementa el contrato del dominio.
- **`fuente_datos_autenticacion_remota.dart`**: Se comunica con [[Supabase]] para autenticación real (verificación de credenciales en internet).
- **`fuente_datos_biometria.dart`**: Usa APIs nativas (Android/iOS) para acceder con huella dactilar.

## Relaciones Clave
Este módulo interactúa constantemente con:
- [[Supabase]] para obtener tokens JWT.
- [[GoRouter]] para redirigir al `/dashboard` si el login es exitoso o regresar al `/login` si expira.

---
#brismar #autenticacion #mobile #nodo
