# Flujo 08: Zarpe de Cámara (Evidencia de Salida con Foto)

Este módulo especifica el proceso para registrar el zarpe (salida) de la cámara de transporte desde el muelle de partida. Su propósito es contar con evidencia visual (fotografía) de que la unidad de transporte ha iniciado el traslado del producto.

---

## 🎯 Objetivo
Registrar la salida de la cámara de transporte (vehículo) asociando una fotografía como evidencia obligatoria, capturando la marca de tiempo, placa del vehículo, chofer y el muelle de partida.

---

## 🗺️ Flujo del Proceso

```mermaid
flowchart TD
    Start([Inicio de Registro de Zarpe]) --> SelectCamera[Seleccionar Placa de Cámara]
    SelectCamera --> VerifyDriver[Confirmar Datos de Chofer]
    VerifyDriver --> CapturePhoto[Capturar Foto de Evidencia]
    CapturePhoto --> ConfirmZarpe{¿Confirmar Datos?}
    
    ConfirmZarpe -->|Sí| SaveLocal[Guardar Registro Localmente]
    ConfirmZarpe -->|No| SelectCamera
    
    SaveLocal --> CheckNet{¿Hay Internet?}
    CheckNet -->|Sí| UploadStorage[Subir Foto a Supabase Storage]
    UploadStorage --> SaveDb[Persistir en Supabase DB]
    CheckNet -->|No| SaveOffline[Encolar para Sincronización en Fondo]
    
    SaveDb --> End([Zarpe Registrado Exitosamente])
    SaveOffline --> End
```

---

## 📝 Especificación Técnica

### 1. Datos a Registrar
- **ID de Zarpe**: UUID v4 auto-generado.
- **Placa de la Cámara**: Clave externa a la tabla de transporte/cámara.
- **Chofer**: Nombre del chofer a cargo.
- **Muelle de Partida**: Ubicación del muelle de salida.
- **Foto de Evidencia**: Archivo de imagen (JPG/PNG).
- **Fecha y Hora de Zarpe**: Marca de tiempo del registro local (`timestamp`).
- **Estado**: Pendiente / Sincronizado.

### 2. Comportamiento Offline-First
- **Captura de Foto**: La foto tomada se almacena temporalmente en el almacenamiento local del dispositivo (usando `path_provider`).
- **Registro en SQLite**: Se guarda la ruta local de la foto junto con los metadatos en una nueva tabla local `zarpes`.
- **Sincronización en Segundo Plano**: El gestor de sincronización (`sincronizar_pendientes_caso_uso.dart`) subirá la foto al Bucket de Supabase Storage (`camaras-zarpes`) y luego insertará el registro en la tabla `zarpes` de PostgreSQL con la URL pública de la imagen.
