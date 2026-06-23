# 📱 Brismar App — Cliente Móvil (Flutter)

Este directorio contiene todo el código fuente de la aplicación móvil de **Brismar**, diseñada para la recolección y sincronización asíncrona de datos de pesca en alta mar por parte del **Personal de Bahía**. Actualmente se encuentra en estado de **MVP funcional offline-first** (parcialmente implementado).

> [!NOTE]
> **Estado de Persistencia y Seguridad:** Actualmente la app utiliza SQLite local sin cifrado completo de la base de datos. La migración a **SQLCipher** es un pendiente crítico requerido antes de considerarse lista para producción segura.

---

## 🏗️ Arquitectura y Principios de Diseño

La aplicación está construida sobre **Flutter** y sigue de manera estricta los principios de **Clean Architecture** estructurada en tres capas independientes:

1. **Presentación (UI & Controladores):** Pantallas y componentes modulares construidos con widgets reactivos. La gestión del estado y la inyección de dependencias se realizan a través de **Riverpod**.
2. **Dominio (Casos de Uso y Entidades):** Contiene las entidades puras de negocio y las interfaces abstractas de los repositorios. Es independiente de bases de datos externas o librerías.
3. **Datos (Modelos y Fuentes de Datos):** Implementación de los repositorios, llamadas a la API remota de Supabase, y persistencia local (SQLite / Secure Storage).

### Estandarización de Idioma
Todo el código fuente (clases, variables, métodos y comentarios) está estandarizado en **español** para facilitar la comprensión y el desarrollo del equipo local.

---

## 📂 Estructura de Directorios

```
brismar_app/
├── assets/             # Recursos estáticos (Logotipo e imágenes)
├── lib/
│   ├── main.dart       # Punto de entrada de la aplicación
│   ├── nucleo/         # Componentes transversales del sistema
│   │   ├── base_datos/ # Configuración y gestión de SQLite
│   │   ├── red/        # Cliente de Supabase y verificador de conexión
│   │   ├── rutas/      # Enrutador fuertemente tipado (GoRouter)
│   │   └── seguridad/  # Bóveda de almacenamiento seguro y cifrado (AES-256)
│   └── modulos/        # Módulos funcionales de la aplicación
│       ├── autenticacion/ # Flujo de inicio de sesión y control de acceso
│       └── registro/      # Módulo de ingreso y envío de capturas
└── test/               # Pruebas unitarias y de widgets
```

---

## 🔐 Flujo de Autenticación Híbrido (Doble Estado)

Para balancear la seguridad y la usabilidad del Personal de Bahía en alta mar, el inicio de sesión opera bajo dos esquemas:

### 1. Inicio de Sesión Inicial (Completo)
* Se requiere la primera vez que se instala la aplicación o tras un cierre de sesión manual o bloqueo por intentos fallidos.
* **Primer inicio en dispositivo nuevo: obligatorio online** para validar credenciales contra Supabase Auth.
* Solicita **Correo y Contraseña**.
* Valida en la nube vía **Supabase Auth** si hay conexión, o localmente usando el hash **BCrypt** almacenado si está offline (solo para usuarios autenticados previamente en ese dispositivo).
* Tras el login exitoso, la app obliga a configurar un **PIN de 4 dígitos (Obligatorio)** y ofrece de forma opcional la **Biometría (Huella/Face ID)** únicamente si el hardware del dispositivo es compatible y tiene registros activos.
* Almacena de forma segura la sesión real de Supabase (`access_token` y `refresh_token`), desestimando el uso del simple `user.id` como token de sesión.

### 2. Acceso Simplificado (Uso Diario)
* Si ya existe una sesión guardada localmente, la aplicación no solicita las credenciales completas de entrada.
* **Periodo de Gracia (12 Horas):** Si el usuario ya validó su identidad en las últimas 12 horas, ingresa **directamente al Dashboard** sin pantallas de bloqueo.
* **Re-verificación:** Transcurrido el periodo de gracia (o en la primera apertura de la jornada), solicita el **PIN de 4 dígitos** o la **Biometría** configurada.
* **Límite de Intentos Offline:** Si se registran **5 intentos fallidos consecutivos de PIN offline**, la app bloquea el acceso rápido local y exige de forma obligatoria realizar un inicio de sesión online con correo y contraseña. La autodestrucción total de la base de datos queda para la fase de seguridad avanzada (Flujo 05).

---

## 🚀 Configuración y Ejecución

1. **Variables de Entorno:**
   Asegúrate de contar con el archivo `.env` en la raíz de `brismar_app/` (copia el archivo `.env.example` y rellena las variables correspondientes a la URL de Supabase y la Anon Key).
2. **Obtener Dependencias:**
   ```bash
   flutter pub get
   ```
3. **Ejecutar Pruebas:**
   ```bash
   flutter test
   ```
4. **Ejecutar la Aplicación:**
   ```bash
   flutter run
   ```

*Nota: Para conocer en detalle los flujos de negocio, diagramas de procesos BPMN y matrices de riesgos, consulta la documentación general ubicada en la carpeta `docs/` en la raíz del repositorio.*
