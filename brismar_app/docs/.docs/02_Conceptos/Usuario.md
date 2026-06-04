# 👤 Usuario

> Entidad de dominio que representa al operador autenticado en la aplicación BRISMAR.
> Usado en: [[MODULO_AUTENTICACION]]

---

## Estructura de la Entidad
La clase `Usuario` modela el perfil de sesión. Está definida en `lib/modulos/autenticacion/dominio/entidades/usuario.dart`.

### Atributos:
- **`id`** (`String`): Identificador único del usuario (UUID generado por [[Supabase]]).
- **`nombreUsuario`** (`String`): Correo electrónico del usuario (ej: `operador@brismar.com.pe`).
- **`nombreReal`** (`String`): Nombre completo de la persona (ej: `Daniel`).
- **`rol`** (`String`): Nivel de acceso en el sistema (`bahia` o `administrador`).

---

## Roles y Permisos de Negocio

La aplicación se personaliza según el rol guardado en [[Supabase]]:
- **`bahia`**: Operador de campo que registra el ingreso de embarcaciones, los kilos de pesca, precios, y los gastos de muelle en la bahía.
- **`administrador`**: Personal de oficina que tiene acceso completo al registro, visualización de métricas avanzadas y generación de reportes consolidados.

---

## Lógica de Normalización
Al iniciar sesión, el [[MODULO_AUTENTICACION]] (en `AuthRepositorioImp`) realiza una auto-normalización del correo. Si el usuario ingresa solo `usuario`, se le añade automáticamente el dominio de la empresa:
```dart
final correoNormalized = usuario.contains('@') ? usuario : '$usuario@brismar.com.pe';
```

---

## Almacenamiento
La sesión se mantiene activa persistiendo el `id` de forma segura en [[SecureStorage]] bajo la llave `auth_token`.

#brismar #entidad #usuario
