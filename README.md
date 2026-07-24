# ⚓ BRISMAR Enterprise Suite — v3.0.0 (Release Oficial) ⚓

[![CI/CD Web](https://github.com/jhonataningesis/BRISMAR_APP/actions/workflows/bris_web_ci.yml/badge.svg)](https://github.com/jhonataningesis/BRISMAR_APP/actions/workflows/bris_web_ci.yml)
[![CI/CD Mobile](https://github.com/jhonataningesis/BRISMAR_APP/actions/workflows/compilar_app.yml/badge.svg)](https://github.com/jhonataningesis/BRISMAR_APP/actions/workflows/compilar_app.yml)
[![Quality Gate](https://img.shields.io/badge/flutter_analyze-0_errors-brightgreen.svg)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/unit_tests-15%2F15_passed-success.svg)](https://flutter.dev)

Bienvenido a la versión **v3.0.0 (Producción)** de **BRISMAR Enterprise Suite**, la plataforma integral de trazabilidad, gestión logística y liquidación contable para el sector pesquero peruano e internacional.

---

## 📁 Estructura del Monorepo

* 📱 [**bris_tracker**](./bris_tracker/) — Aplicación móvil (Flutter) para registradores de bahía y muelle. Operatividad **Offline-First** con cifrado **AES-256 (SQLCipher)**, autenticación biométrica, PIN diario y auto-sincronización con la nube.
* 🌐 [**bris_web**](./bris_web/) — Torre de control y dashboard administrativo (Flutter Web SPA) para gestión de compras, gastos de muelle/administrativos, recepción en planta, radar de tránsito y exportación de liquidaciones a Excel.
* 🗄️ [**supabase**](./supabase/) — Esquema y migraciones de base de datos PostgreSQL compartida con Row Level Security (RLS) y autenticación JWT.
* 📄 **Documentos de Evaluación:**
  * 📋 [Walkthrough de Refactorización](.system_generated/walkthrough.md)
  * 🏛️ [Informe de Auditoría Legal y Valoración Comercial](.system_generated/evaluacion_comercial_cumplimiento_brismar.md)
  * 💼 [Propuesta Comercial y Modelo de Negocio](.system_generated/propuesta_comercial_y_modelo_negocio_brismar.md)

---

## 🏗️ Arquitectura y Tecnologías

| Componente | Tecnología | Estándar / Patrón |
| :--- | :--- | :--- |
| **Mobile App** | Flutter 3.x, Dart 3.x | Clean Layered Architecture, Riverpod 2.x (`AsyncNotifier`), SQLCipher AES-256 |
| **Web Admin** | Flutter Web SPA | Clean Architecture, Riverpod 2.x, Excel Service |
| **Seguridad** | `FlutterSecureStorage` | Hardware-backed KeyStore (Android) / Keychain (iOS) |
| **Backend & Cloud** | Supabase Cloud, PostgreSQL | Row Level Security (RLS), JWT Authentication |
| **CI/CD** | GitHub Actions | Workflows automatizados de análisis estático, testing y compilación release |

---

## 🚀 Instalación y Compilación Local

### Requisitos Previos
- Flutter SDK `^3.11.1`
- Dart SDK `^3.11.1`
- Android Studio / Xcode (para móvil)

### 1. Clonar el repositorio
```bash
git clone https://github.com/jhonataningesis/BRISMAR_APP.git
cd BRISMAR_APP
```

### 2. Ejecutar la App Móvil (`bris_tracker`)
```bash
cd bris_tracker
flutter pub get
flutter run
```

### 3. Compilar la Web Admin (`bris_web`)
```bash
cd bris_web
flutter pub get
flutter build web --release
```

### 4. Ejecutar Pruebas Unitarias e Integración
```bash
cd bris_tracker
flutter test
```

---

## 🔒 Cumplimiento Normativo y Seguridad

* **Ley N° 29733 (LPDP Perú):** Cifrado de datos personales y fotos de evidencia en reposo y tránsito.
* **Ley N° 30096 (Delitos Informáticos):** Autenticación segura por bóveda de hardware y biometría.
* **Trazabilidad PRODUCE / SANIPES / SUNAT:** Registro estructurado de pesaje, especie, pesador, chofer, muelle y placas.

---

## 👨‍💻 Autoría y Equipo de Desarrollo

* **Jhonatan Sanchez** (Lead Architect & Core Engineering)
* **SuyonRiccy** (Full-Stack Developer & UI Specialist)
* **Belén** (QA & Product Verification)

© 2026 NEGOCIOS BRISMAR S.R.L. — Todos los derechos reservados.
