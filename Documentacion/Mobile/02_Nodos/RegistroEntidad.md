# 📦 Entidad: Registro / Zarpe / Cuadre

Es un modelo unificador de transacciones que ocurren físicamente en las operaciones marítimas y de gestión.

## Archivos Relevantes
📁 `bris_tracker/lib/modulos/registro_pesca/dominio/entidades/zarpe_entidad.dart`
📁 `bris_tracker/lib/modulos/registro_pesca/dominio/entidades/cuadre_entidad.dart`

## Características Principales

Son objetos de dominio puros (sin código JSON ni imports de librerías externas o frameworks) que representan la verdad matemática o lógica:

- `id`: Identificador único (suele ser UUID en el frontend si es offline-first, para no chocar al subir).
- `fecha`: `DateTime` en la que ocurrió el evento.
- `estadoSincronizacion`: Bandera fundamental. Si está `true`, los datos están asegurados en la nube. Si está `false`, viven localmente.
- **Variables Específicas**: (Volumen de captura, tipo de embarcación, mermas de insumos).

Cuando el usuario usa el [[MODULO_REGISTRO]], interactúa con entidades como esta en la memoria del teléfono.

---
#brismar #dominio #entidad #registro #nodo
