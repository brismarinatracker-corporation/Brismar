# 🐟 RegistroEntidad

> Entidad principal de dominio que representa una transacción de descarga de pesca y sus gastos operativos asociados en la bahía de Brismar.
> Usado en: [[MODULO_REGISTRO]]

---

## Estructura de la Entidad
La clase `RegistroEntidad` está definida en `lib/modulos/registro/dominio/entidades/registro_entidad.dart`.

### Atributos principales:
- **`id`** (`String`): Identificador único del registro (UUID).
- **`nombreEmbarcacion`** (`String`): Nombre de la lancha/barco que descarga (ej: *"Don Manuel"*).
- **`producto`** (`String`): Especie hidrobiológica pescada (ej: *"Pota"*, *"Jurel"*).
- **`placaCarro`** (`String?`): Vehículo que transportará la carga de la bahía al almacén (opcional).
- **`kilos`** (`double`): Peso total en kilogramos de la pesca descargada.
- **`precioPorKilo`** (`double`): Precio acordado por kilogramo en soles (S/).
- **`fecha`** / **`hora`** (`String`): Cuándo se efectuó la descarga.
- **`muelleInicio`** (`String`): Nombre del muelle donde se atracó la embarcación.
- **`sincronizado`** (`bool`): Bandera para indicar si el registro ya está subido a la nube en [[Supabase]].

---

## Desglose de Gastos Operativos (en Soles S/)
Para calcular la rentabilidad real de la jornada, cada descarga permite ingresar gastos:
- **`gastoFacturacion`**: Costos de comprobantes y trámites tributarios.
- **`gastoPersonal`**: Pago a estibadores y personal de bahía.
- **`gastoApoyo`**: Gastos por servicios de ayuda en puerto.
- **`gastoAgua`**: Suministro de agua para limpieza y refrigeración.
- **`gastoClorox`**: Desinfectantes para inocuidad del pescado.
- **`gastoFlete`**: Transporte terrestre del producto.
- **`gastoHielo`**: Hielo en escamas para conservar la pesca.
- **`gastoOtros`**: Cualquier otro imprevisto en bahía.

---

## Métodos Calculados en Caliente (Getters)
La entidad cuenta con lógica interna de negocio autocalculada sin dependencias externas:
1. **`ingresoBruto`**: `kilos * precioPorKilo`
2. **`totalGastos`**: Suma todos los gastos listados arriba (`gastoFacturacion + gastoPersonal + ...`)
3. **`utilidadNeta`**: `ingresoBruto - totalGastos`

---

## Almacenamiento y Sincronización
1. **Local**: Se guarda de inmediato en la tabla `registro_embarcaciones` de [[SQLite]] con `sincronizado = false` (0).
2. **Nube**: Se sube en lote a [[Supabase]] cuando la conectividad móvil se restablece. Una vez subido, se marca localmente con `sincronizado = true` (1).

#brismar #entidad #registro
