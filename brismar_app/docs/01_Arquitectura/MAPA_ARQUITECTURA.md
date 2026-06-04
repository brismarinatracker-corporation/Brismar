# 🏗️ Mapa de Arquitectura

> 🔄 **Última actualización automática:** 02 de junio de 2026 a las 01:27
> Vuelve a [[CONTEXTO_PROYECTO]] · Ver [[DASHBOARD]]

---

## Las 3 capas (Clean Architecture)

```
PRESENTACIÓN  →  DOMINIO  ←  DATOS
  (lo que ves)    (las reglas)   (de dónde salen los datos)
```

### 🎨 Presentación (lo que el usuario ve)
- Pantallas y componentes de UI
- Controladores con [[Riverpod]]
- Solo habla con el **Dominio**

### 📐 Dominio (las reglas del negocio)
- [[Usuario]]
- [[RegistroEntidad]]
- Contratos abstractos
- Casos de uso
- **NUNCA toca datos directamente**

### 💾 Datos (de dónde vienen)
- [[Supabase]] — datos remotos (internet)
- [[SQLite]] — datos locales (sin internet)

---

## Carpetas del proyecto (actual)

```
  ├── lib/
  ├── modulos/
    ├── autenticacion/
      ├── datos/
        ├── fuentes_datos/
        ├── repositorios/
      ├── dominio/
        ├── entidades/
        ├── repositorios/
      ├── presentacion/
        ├── controladores/
        ├── pantallas/
    ├── registro/
      ├── datos/
        ├── fuentes_datos/
        ├── modelos/
        ├── repositorios/
      ├── dominio/
        ├── casos_uso/
        ├── entidades/
        ├── repositorios/
      ├── presentacion/
        ├── componentes/
        ├── controladores/
        ├── pantallas/
  ├── nucleo/
    ├── base_datos/
    ├── red/
    ├── rutas/
    ├── seguridad/
    ├── utilidades/
```

---

## Módulos detectados

### [[MODULO_AUTENTICACION]] (6 archivos)

| Capa | Archivos |
|---|---|
| datos | 2 |
| dominio | 2 |
| presentacion | 2 |

### [[MODULO_REGISTRO]] (15 archivos)

| Capa | Archivos |
|---|---|
| datos | 4 |
| dominio | 5 |
| presentacion | 6 |

---

## Núcleo (infraestructura compartida)

| Carpeta | Archivos | Tecnología |
|---|---|---|
| base_datos | 1 | - |
| red | 1 | - |
| rutas | 1 | - |
| seguridad | 1 | - |
| utilidades | 1 | - |

---

## Patrones detectados

| Patrón | Dónde |
|---|---|
| Singleton | `nucleo/base_datos/database_helper.dart` |
| Singleton | `nucleo/seguridad/secure_storage_helper.dart` |
| Repository (contrato) | `modulos/autenticacion/dominio/repositorios/auth_repositorio.dart` |
| Repository (contrato) | `modulos/registro/dominio/repositorios/registro_repositorio.dart` |
| Use Case | `modulos/registro/dominio/casos_uso/guardar_registro_caso_uso.dart` |
| Use Case | `modulos/registro/dominio/casos_uso/obtener_historial_caso_uso.dart` |
| Use Case | `modulos/registro/dominio/casos_uso/sincronizar_pendientes_caso_uso.dart` |
| StateNotifier | `modulos/autenticacion/presentacion/controladores/auth_controlador.dart` |
| StateNotifier | `modulos/registro/presentacion/controladores/registro_controlador.dart` |

---

#brismar #arquitectura #autogenerado
