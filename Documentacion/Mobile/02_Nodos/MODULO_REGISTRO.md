# 📝 Módulo Registro (Registro Pesca y Zarpe)

Es el corazón operativo de la aplicación móvil (bris_tracker), que permite a los operarios registrar datos críticos de las faenas y reportes financieros (cuadres), incluso si no tienen internet (offline-first).

## Ubicación del Código
📁 `bris_tracker/lib/modulos/registro_pesca/`

## Funcionalidad y Componentes (Clean Architecture)

### 1. Presentación (UI y Estado)
- **`controlador_zarpes.dart` & `controlador_cuadres.dart`**: Controladores de estado reactivo creados con [[Riverpod]].
- **`dashboard_cuadres.dart`**: Pantalla principal para visualizar métricas operativas de faena.
- **`formulario_registro_pesca.dart`**: Pantalla compleja para añadir volumen, especies y variables ambientales.
- **`panel_calculo_vivo.dart`**: Widget reactivo que muestra sumatorias o costos en tiempo real al ingresar datos.

### 2. Dominio (Reglas de Negocio)
- **`cuadre_entidad.dart`**: Modela un registro de cuadre financiero (Entidad base).
- **`zarpe_entidad.dart`**: Modela una salida al mar ([[RegistroEntidad]]).
- **Casos de Uso**: Contiene reglas sobre cómo validar, sincronizar y guardar registros independientemente del medio de almacenamiento.

### 3. Datos (Implementación)
- **`cuadre_repositorio_imp.dart`**: Coordina si la información se debe enviar a internet o guardarse localmente cuando falla la conexión.
- **`fuente_datos_cuadres_local.dart`**: Interactúa directamente con [[SQLite]] para guardar registros offline (en el disco del teléfono).
- **`fuente_datos_zarpes_remota.dart` & `fuente_datos_cuadres_remota.dart`**: Usan el cliente unificado de [[Supabase]] para guardar datos definitivamente en la nube de AWS.

## Relaciones Clave
Depende fuertemente de [[SQLite]] para su resiliencia sin conexión y es gestionado por usuarios validados del [[MODULO_AUTENTICACION]].

---
#brismar #registro #zarpe #cuadres #mobile #nodo
