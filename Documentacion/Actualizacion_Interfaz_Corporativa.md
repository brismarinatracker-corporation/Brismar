# Actualización de Interfaz Corporativa - Bris Group

El día de hoy se realizaron los siguientes cambios de diseño y branding corporativo en los dos aplicativos del ecosistema (Web y Móvil), alineando toda la imagen gráfica con la nueva identidad de **Bris Group**.

## 1. Aplicativo Móvil (`bris_tracker`)

* **Launcher Icon (Ícono de la aplicación):** Se reemplazó el ícono por defecto de Flutter por el logotipo oficial de la empresa. Ahora la aplicación en el celular muestra la nueva identidad desde la pantalla de inicio del sistema operativo.
* **Pantallas de Autenticación (Login & Acceso Rápido con PIN):**
  * Se sustituyó el logo anterior por el diseño actual de *Bris Group*.
  * Se configuró un recorte inteligente (`Transform.scale(1.8)`) envuelto en una caja blanca con bordes redondeados (`ClipRRect` y `BorderRadius.circular(12)`) para resaltar la imagen de forma profesional frente a fondos oscuros y adaptándose sin espacios en blanco excesivos.

## 2. Aplicativo Web (`bris_web`)

* **Dashboard / Menú Lateral:**
  * Se cambió el ícono de ancla por el logotipo oficial de *Bris Group* encapsulado en un recuadro blanco pulido con zoom interno.
  * Se actualizó el título principal del sidebar, reemplazando "Brismar" por **"BRIS GROUP"**.
* **Pantalla Principal de Login (`pantalla_login.dart`):**
  * **Panel Izquierdo Premium:** El color verde sólido del panel izquierdo fue mejorado con un `CarruselFondoLogin`.
  * **Rotación Automática:** Se integró un temporizador (Timer) que cambia automáticamente entre tres fotografías de pesca en alta calidad cada 4 segundos.
  * **Transiciones y Superposición:** Se aplicó un `AnimatedSwitcher` con `FadeTransition` para que los saltos entre fotos sean extremadamente fluidos (fundidos cruzados). Las fotos tienen una máscara superpuesta color verde bosque semitransparente (opacidad de 0.85) que fusiona la imagen de los pescadores con el *brand* del sistema.
  * **Branding de Textos:** El texto original "NEGOCIOS BRISMAR S.R.L." fue modificado a **"BRIS GROUP"**, manteniendo los claims originales sobre los que reposa el logo y las directrices de trazabilidad.
  * **Limpieza Visual:** Se eliminó por completo la sección inferior de "¿Problemas para ingresar? Contacta a soporte" para darle una estética más directa e ininterrumpida al panel derecho.

## 3. Optimización y Respaldo

* **Formatos y Limpieza:** Se ejecutó `dart format` en ambos repositorios internos (`bris_tracker/lib` y `bris_web/lib`) para garantizar el estándar de codificación.
* **Sincronización:** Todos los cambios fueron consolidados en un commit y sincronizados con las tres ramas maestras (`DEV-BELEN`, `develop` y `main`) en el repositorio remoto.
