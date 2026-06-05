# 📱 Brismar App — Cliente Móvil (Flutter)

Este directorio contiene todo el código fuente de la aplicación móvil de **Brismar**, diseñada para la recolección y sincronización asíncrona de datos de pesca en alta mar (offline-first) por parte del **Personal de Bahía**.

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
* Se requiere la primera vez que se instala la aplicación o si el usuario cierra su sesión de manera explícita.
* Solicita **Correo y Contraseña**.
* Valida en la nube vía **Supabase Auth** si hay conexión, o de forma local comparando hashes **BCrypt** contra la base SQLite si está offline.
* Al ser exitoso, permite al usuario configurar de forma opcional su **PIN de 4 dígitos** o la **Biometría (Huella/Face ID)**, y almacena el token de sesión de forma encriptada.

### 2. Acceso Simplificado (Uso Diario)
* Si ya existe un token de sesión almacenado en el dispositivo, la aplicación no solicita las credenciales completas.
* **Periodo de Gracia (12 Horas):** Si el usuario ya validó su identidad en las últimas 12 horas, ingresa **directamente al Dashboard** sin pantallas de bloqueo.
* **Re-verificación:** Transcurrido el periodo de gracia (o en la primera apertura de la jornada), solicita el **PIN de 4 dígitos** o la **Biometría** configurada para re-verificar identidad.

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
