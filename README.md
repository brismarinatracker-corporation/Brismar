# ⚓ BRISMAR APP — Sistema de Gestión de Bahía

> Sistema de gestión y control de registros de pesca para **Negocios Brismar S.R.L.**

## 📋 Descripción

Aplicación móvil (Flutter) para la administración eficiente de ingresos, gastos operativos y generación de reportes en la bahía. Conectada a **Supabase** como backend.

## 🚀 Características

| Módulo | Estado | Descripción |
|---|---|---|
| **Login** | ✅ Funcional | Autenticación con Supabase (modo simulación) |
| **Registro de Embarcaciones** | ✅ Funcional | Registro de pesca: kilos, precio, gastos, catanas |
| **Historial** | 🔄 Pendiente | Consulta de registros anteriores |
| **Sincronización** | 🔄 Pendiente | Sync offline → Supabase |
| **Reportes PDF** | 🔄 Pendiente | Generación de reportes diarios |
| **Perfil** | 🔄 Pendiente | Gestión de perfil de usuario |

## 🏗️ Arquitectura

```
brismar_mobile/lib/
├── main.dart                          # Entry point + ProviderScope
├── modulos/
│   ├── autenticacion/                 # Módulo de Login
│   │   ├── datos/                     # DataSources + Repositorios
│   │   ├── dominio/                   # Entidades + Contratos
│   │   └── presentacion/             # Pantallas + Controladores
│   └── registro/                      # Módulo de Registro
│       ├── datos/
│       ├── dominio/
│       └── presentacion/
└── nucleo/                            # Core compartido
    ├── base_datos/                    # SQLite Helper
    ├── red/                           # Supabase Client
    ├── rutas/                         # GoRouter
    ├── seguridad/                     # SecureStorage
    └── utilidades/                    # PDF Helper
```

**Stack:**
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Backend:** Supabase
- **Local DB:** SQLite
- **Arquitectura:** Clean Architecture (SOLID)

## 🔀 Estrategia de Ramas

```
main ─────────────── Siempre estable, solo releases
  └── develop ─────── Integración de cambios
       └── developer-jjgs ── Rama personal de JJGS
```

## 📌 Versionamiento

Usamos **Semantic Versioning** (SemVer):

```
v X.Y.Z
  │ │ └── PATCH: Bug fixes
  │ └──── MINOR: Nuevas features
  └────── MAJOR: Breaking changes
```

**Versión actual:** `v1.0.0`

## ⚙️ Setup

```bash
# 1. Clonar
git clone https://github.com/SuyonRiccy/BRISMAR_APP.git
cd BRISMAR_APP/brismar_mobile

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo
flutter run
```

### Credenciales de Testing (Modo Simulación)

| Usuario | Contraseña |
|---|---|
| `usuario` | `1234` |

## 👥 Equipo

| Miembro | Rol | Rama |
|---|---|---|
| Jhonatan Sanchez (JJGS) | Developer | `developer-jjgs` |
| SuyonRiccy | Developer | — |
| Jesús Huilla | Developer | — |

## 📄 Licencia

Proyecto privado de Negocios Brismar S.R.L.