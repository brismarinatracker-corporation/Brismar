# ⚡ Guía de Optimización de Rendimiento de Imágenes y Almacenamiento

Este documento detalla los estándares aplicados en **BRISMAR Enterprise Suite** para mantener un consumo mínimo de ancho de banda, una excelente experiencia de usuario (tiempos mínimos de espera) y un uso optimizado del almacenamiento en Supabase.

---

## 📱 1. Optimización en la Captura y Selección (Cliente)

Para evitar que los dispositivos móviles y navegadores web suban imágenes a resolución completa (las cuales pueden pesar entre 3MB y 8MB en sensores modernos), configuramos límites estrictos en el `image_picker`:

- **Fotos de Evidencia (Zarpes y Cuadres):**
  - **Calidad:** 70% (`imageQuality: 70`)
  - **Dimensiones máximas:** 1024x1024 píxeles (`maxWidth: 1024`, `maxHeight: 1024`)
  - **Ubicación:** `App/bris_tracker/lib/modulos/registro_pesca/presentacion/pantallas/formulario_zarpe_pantalla.dart`

- **Avatares de Usuario (Perfil):**
  - **Calidad:** 70% (`imageQuality: 70`)
  - **Dimensiones máximas:** 400x400 píxeles (`maxWidth: 400`, `maxHeight: 400`)
  - **Ubicación:** `App/bris_web/lib/modulos/usuarios/presentacion/widgets/dialogo_formulario_usuario.dart`

> 💡 **Nota técnica:** Esta redimensión previa en el cliente reduce el tamaño promedio de los archivos a **~150KB**, disminuyendo el tiempo de subida en un **95%** en zonas portuarias con cobertura limitada.

---

## ☁️ 2. Políticas de Almacenamiento y Caché (Supabase Storage)

Para evitar descargas redundantes, cada vez que una aplicación solicita una imagen, configuramos directivas de caché HTTP utilizando los encabezados de Supabase Storage:

- **Bucket `camaras-zarpes` (Evidencias de pesca):**
  - **Caché:** 1 año (`cacheControl: '31536000'`)
  - **Ubicación:** `FuenteDatosZarpesRemota` y `FuenteDatosCuadresRemota` en el tracker.

- **Bucket `avatars` (Perfiles de usuarios):**
  - **Caché:** 1 hora (`cacheControl: '3600'`)
  - **Ubicación:** `FuenteDatosUsuariosAdmin` en `bris_web`.

---

## 🌐 3. Transformación de Imágenes Bajo Demanda (Supabase Image Transformations)

En la interfaz web de administración (`bris_web`), **nunca debemos cargar la foto original de resolución completa en listas o paneles principales**. En su lugar, utilizamos el servidor de renderizado de Supabase para generar versiones más pequeñas al vuelo:

### Utilidad Central
Utilizamos `OptimizadorImagenes.optimizarSupabaseUrl(originalUrl, {width, quality})` ubicado en `App/bris_web/lib/nucleo/utils/optimizador_imagenes.dart`.

### Aplicación
1. **Radar de Tránsito (Tarjetas):** Redimensionamos las fotos de camiones a **400px** de ancho.
2. **Visualizador de Formulario (Paso 1):** Cargamos la foto activa a **600px** de ancho. Cuando el usuario hace clic, el lightbox muestra la imagen original.
3. **Avatares en Sidebar y Listas:** Redimensionamos las fotos de perfil a **100px** de ancho.

---

## 🛠️ 4. Mantenimiento y Buenas Prácticas para Desarrolladores

Si implementas un nuevo flujo con carga de imágenes, **debes seguir obligatoriamente estas tres reglas**:

1. **Inyección de límites en ImagePicker:** Añade siempre `maxWidth` / `maxHeight` según el caso de uso.
2. **Caché en Storage:** Pasa siempre un objeto `FileOptions` con la propiedad `cacheControl` configurada.
3. **Evita descargas gigantes en Web:** Envuelve cualquier URL de imagen de Supabase Storage en `OptimizadorImagenes.optimizarSupabaseUrl(...)` cuando la muestres dentro de una lista o widget pequeño.
