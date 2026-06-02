# 📋 Módulo: Registro de Pesca

> Registra la pesca del día, calcula gastos y utilidad.
> Vuelve a [[CONTEXTO_PROYECTO]] · Ver [[DASHBOARD]]

---

## ¿Qué hace?
1. El [[Usuario]] llena: embarcación, producto, kilos, precio
2. Agrega los gastos: hielo, personal, flete, etc.
3. Se guarda en [[SQLite]] (funciona sin internet)
4. Se sincroniza con [[Supabase]] cuando hay conexión
5. Genera un PDF con el reporte (ver abajo)

---

## La entidad principal: [[RegistroEntidad]]

### Datos de la pesca
| Campo | Ejemplo |
|---|---|
| Embarcación | "Don Manuel" |
| Producto | "Pota" |
| Kilos | 1500 |
| Precio/kg | S/ 2.50 |
| Muelle | "Muelle 3" |
| Placa carro | "ABC-123" |

### Gastos operativos
Hielo · Personal · Flete · Agua · Clorox · Facturación · Apoyo · Otros

### Cálculos automáticos
- **Ingreso Bruto** = kilos × precio
- **Total Gastos** = suma de todos los gastos
- **Utilidad Neta** = ingreso - gastos

---

## Archivos

| Capa | Archivo | Qué hace |
|---|---|---|
| Presentación | `registro_pantalla.dart` | Pantalla principal |
| Presentación | `registro_controlador.dart` | Estados con [[Riverpod]] |
| Presentación | `historial_lista.dart` | Lista de registros pasados |
| Presentación | `seccion_totales.dart` | Muestra los totales |
| Dominio | `registro_entidad.dart` | [[RegistroEntidad]] |
| Dominio | `registro_repositorio.dart` | Contrato |
| Dominio | `guardar_registro_caso_uso.dart` | Caso de uso: guardar |
| Dominio | `obtener_historial_caso_uso.dart` | Caso de uso: historial |
| Dominio | `sincronizar_pendientes_caso_uso.dart` | Caso de uso: sincronizar |
| Datos | `registro_repositorio_imp.dart` | Implementación |
| Datos | `registro_modelo.dart` | Mapeo SQLite ↔ JSON |
| Datos | `registro_local_datasource.dart` | Habla con [[SQLite]] |
| Datos | `registro_remoto_datasource.dart` | Habla con [[Supabase]] |

---

## Flujo de datos

```
Usuario llena formulario
    ↓
RegistroControlador ([[Riverpod]])
    ↓
GuardarRegistroCasoUso (dominio)
    ↓
RegistroRepositorioImp (datos)
    ↓
┌───────┐  ┌──────────┐
│SQLite │  │ Supabase │
│(local)│  │(remoto)  │
└───────┘  └──────────┘
```

---

## Pendiente ❌
- [ ] Sincronización automática cuando hay internet
- [ ] Filtrar historial por fecha o embarcación
- [ ] Descargar PDF desde la pantalla

---

#brismar #modulo #registro #pesca
