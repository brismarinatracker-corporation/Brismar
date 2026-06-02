# 🔐 Módulo: Autenticación

> Maneja el login, logout y sesión del [[Usuario]].
> Vuelve a [[CONTEXTO_PROYECTO]] · Ver [[DASHBOARD]]

---

## ¿Qué hace?
1. El usuario escribe su correo y contraseña
2. Se valida contra [[Supabase]] (o modo simulación)
3. Si es correcto, guarda el token en [[SecureStorage]]
4. Navega a [[MODULO_REGISTRO]] vía [[GoRouter]]

---

## Archivos

| Capa | Archivo | Qué hace |
|---|---|---|
| Presentación | `login_pantalla.dart` | La pantalla del login |
| Presentación | `auth_controlador.dart` | Maneja estados con [[Riverpod]] |
| Dominio | `usuario.dart` | Entidad [[Usuario]] |
| Dominio | `auth_repositorio.dart` | Contrato (qué debe hacer) |
| Datos | `auth_repositorio_imp.dart` | Implementación real |
| Datos | `auth_remoto_datasource.dart` | Habla con [[Supabase]] |

---

## Estados de la pantalla

```
Inicial → Cargando → Autenticado ✅
                    → No Autenticado ❌
                    → Error ⚠️
```

---

## Credenciales de prueba 🧪

| Campo | Valor |
|---|---|
| Usuario | `usuario` |
| Contraseña | `1234` |

> Esto funciona porque [[Supabase]] está en modo simulación.

---

## Pendiente ❌
- [ ] Pantalla de registro de cuenta nueva
- [ ] Recuperar contraseña (funcional)
- [ ] Roles del [[Usuario]] en la interfaz

---

#brismar #modulo #autenticacion
