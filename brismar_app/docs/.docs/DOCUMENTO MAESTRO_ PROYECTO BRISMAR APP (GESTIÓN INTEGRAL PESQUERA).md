# DOCUMENTO MAESTRO: PROYECTO BRISMAR APP
### Gestión Integral Pesquera — v2.0
**NEGOCIOS BRISMAR S.R.L.**
_Última actualización: Mayo 2026_

---

> ⚠️ **INSTRUCCIÓN PARA EL AGENTE DE IA (Antigravity / Cursor / Copilot)**
> Este documento es tu **fuente de verdad absoluta** para el proyecto BRISMAR APP.
> Antes de escribir cualquier línea de código:
> - Lee y respeta todas las reglas de negocio aquí definidas.
> - Stack obligatorio: **Flutter + Supabase + SQLite** (arquitectura Offline-First).
> - El vocabulario del muelle es técnico y específico — consulta el glosario (Sección 13).
> - Los campos marcados como `[CONFIGURABLE]` deben implementarse como parámetros editables por el administrador, NO como constantes en el código.
> - Los campos marcados como `[PENDIENTE]` son decisiones de negocio abiertas — genera la arquitectura flexible para soportar cualquier valor futuro.
> - Cuando generes código financiero, **nunca hardcodees porcentajes ni taras**.

---

## 1. IDENTIDAD CORPORATIVA Y VISIÓN ESTRATÉGICA

**NEGOCIOS BRISMAR S.R.L.** es una organización especializada en el sector extractivo y comercial de productos hidrobiológicos. Opera como orquestador logístico crítico que asegura la integridad de la cadena de frío y el cumplimiento normativo desde el muelle hasta la recepción industrial.

**Misión:** Brindar productos hidrobiológicos de alta calidad mediante la pesca marítima responsable, garantizando la sostenibilidad de los recursos marinos y satisfaciendo las necesidades del mercado con eficiencia, trazabilidad y compromiso.

**Visión:** Ser una empresa líder en el sector pesquero a nivel regional, nacional e internacional, reconocida por su responsabilidad ambiental, la calidad de sus productos y la excelencia en sus procesos operativos y comerciales.

### Portafolio de Productos

| Especie | Categoría | Mercado Principal |
|---|---|---|
| Pota (Cefalópodo) | Recurso estratégico | Congelados y conservas — alta demanda global |
| Jurel | Especie pelágica | Seguridad alimentaria y consumo humano directo |
| Caballa | Procesamiento industrial | Conservas |
| Bonito | Temporada | Alta rotación — mercados del norte peruano |

### Cobertura Geográfica
- **Puerto(s) de operación:** `[PENDIENTE — definir antes del Sprint 1]`
- La arquitectura debe soportar **múltiples puntos de desembarque** desde el inicio (diseño multi-sede).

---

## 2. MODELO DE NEGOCIO "ASSET-LIGHT"

BRISMAR opera sin flota propia ni plantas de procesamiento. **La infraestructura digital es el activo primario.**

- **Rol de "Pegamento Logístico":** BRISMAR es la interfaz administrativa y operativa entre armadores artesanales y plantas industriales (ARCOPA, PRODUMART, El Mayor, Corpus Mar, Peru Fres).
- **La App como Núcleo Operativo:** No es una herramienta accesoria. Sustituye la presencia física en planta, gestiona la burocracia sanitaria y la liquidez financiera que los proveedores informales no pueden manejar.

---

## 3. ANÁLISIS DEL ENTORNO ESTRATÉGICO

### Análisis PESTEL

| Factor | Impacto Crítico |
|---|---|
| Político | Regulaciones de PRODUCE e IMARPE; cuotas de captura y vedas temporales |
| Económico | Alta volatilidad de precios; dependencia de terceros para flete y almacenamiento |
| Social | Exigencia creciente de trazabilidad certificada y pesca sostenible |
| Tecnológico | Brecha digital crítica (WhatsApp/Excel) vs necesidad de ERP en tiempo real |
| Ecológico | Impacto del Fenómeno El Niño en biomasa; vedas de SANIPES |
| Legal | Cumplimiento Ley General de Pesca y certificaciones sanitarias internacionales |

### Análisis Porter (Cinco Fuerzas)

1. **Poder de clientes (Muy Alto):** Plantas como ARCOPA/PRODUMART exigen documentación digital (PTH/Guías) de forma inmediata. Sin trazabilidad auditable, la carga es rechazada.
2. **Poder de proveedores (Medio):** Dependencia de armadores externos; su fuerza aumenta en periodos de escasez.
3. **Rivalidad (Alta):** Competencia directa con proveedores locales en los mismos puntos de desembarque.
4. **Nuevos entrantes (Media):** Las barreras sanitarias son altas; la digitalización de BRISMAR creará ventaja difícil de replicar.
5. **Sustitutos (Baja):** Limitada por la especificidad de líneas de producción de las plantas.

---

## 4. PROBLEMA CENTRAL: EL CUELLO DE BOTELLA DOCUMENTAL

La operatividad sufre una fricción crítica entre la **velocidad física** en muelle y la **lentitud administrativa** en oficina:

- **En bahía:** Los frentes operativos (Bahía Daniel y Bahía Jair) tienen flujos frenéticos de pesaje, encajonado y estiba para evitar aumento de temperatura.
- **La fricción:** Dependencia de WhatsApp para fotos de guías y audios con pesos genera errores de transcripción.
- **Consecuencia crítica:** Si el camión llega a planta sin la Guía de Remisión o el PTH de SANIPES procesados, la cámara no descarga. **El producto (especialmente pota) se pudre** — pérdida financiera total y daño sanitario irreparable.

---

## 5. OBJETIVOS SMART Y MÉTRICAS

| # | Objetivo | Meta | Justificación |
|---|---|---|---|
| 1 | Tiempo de registro de capturas y gastos | ↓ 50% en Q1 | Automatización elimina registros duplicados |
| 2 | Pérdida de registros | < 2% | SQLite ACID garantiza persistencia ante fallos |
| 3 | Errores en cálculo de utilidad neta | ↓ 80% | Digitalización de fórmulas elimina "dedazos" en Excel |
| 4 | Tiempo de emisión de reportes PDF | ↓ 70% | Eliminación del armado manual |
| 5 | Trazabilidad de auditoría | 98% de operaciones con log | Cumplimiento estándar exportación |
| 6 | Adopción digital del personal | 90% en 3 meses | Curva de aprendizaje estimada |
| 7 | Errores en registros de hielo/flete/combustible | ↓ 70% | Listas predefinidas + validaciones de rango |
| 8 | Tasa de éxito sync offline | > 95% | Resiliencia ante nula señal en zonas de muelle |

---

## 6. ARQUITECTURA TECNOLÓGICA

### Stack Tecnológico

| Capa | Tecnología | Justificación |
|---|---|---|
| Frontend móvil | **Flutter** | Multiplataforma (Android prioritario; iOS futuro); alto rendimiento de UI |
| Backend / BaaS | **Supabase** | PostgreSQL gestionado, Auth, Storage, Realtime y Edge Functions sin servidor propio |
| Base de datos local | **SQLite** | Transacciones ACID; persistencia total ante fallos de red o hardware |
| Backend lógica compleja | `[PENDIENTE]` | Evaluar Supabase Edge Functions (Deno) vs servidor dedicado según complejidad financiera |

> **Nota para el agente:** El backend aún no está completamente definido. Diseña la capa de servicios con **interfaces abstractas** (repositorios) para que el cambio de proveedor no requiera reescribir la lógica de negocio. Usa el patrón Repository + Clean Architecture.

### Plataformas

| Fase | Plataforma | Usuarios |
|---|---|---|
| MVP (ahora) | Android | Operadores de bahía (Daniel, Jair) |
| Futuro cercano | iOS | Expansión de cobertura |
| Futuro | Web (Flutter Web o dashboard independiente) | Personal administrativo fuera del muelle |

### Requerimiento No Negociable: Arquitectura Offline-First

La señal en puntos de desembarque es nula o inestable. El sistema **debe operar en modo local completo**:

1. Todos los registros se guardan primero en **SQLite local**.
2. Se encolan en una `sync_queue` con timestamp, user_id y tipo de operación.
3. Al detectar conectividad, un proceso en segundo plano sincroniza con **Supabase** automáticamente.
4. Implementar resolución de conflictos: política **"last-write-wins"** con registro en `audit_log`.
5. El usuario debe ver siempre el **estado de sync** (ícono claro: sincronizado / pendiente / error).

---

## 7. REGLAS DE NEGOCIO CRÍTICAS

> ⚠️ Estas reglas deben respetarse en TODA la lógica de negocio. Nunca como constantes hardcodeadas.

### 7.1 Tara de Cajas
- **Estado:** `[CONFIGURABLE por administrador]`
- La tara varía según el tipo de caja utilizada en cada operación.
- El sistema debe permitir definir y editar taras por tipo de caja desde el panel de administración.
- Cada registro de pesaje debe guardar la tara aplicada en el momento del registro (no recalcular retroactivamente).
- **Pregunta abierta para el negocio:** ¿La tara varía también por especie o solo por tipo de caja?

### 7.2 Modelo de Liquidación (Split)
- **Estado:** `[PENDIENTE — decisión de negocio]`
- El documento original menciona un modelo 50/50 como referencia histórica.
- **El sistema debe soportar porcentajes configurables por armador y/o por operación.**
- Preguntas abiertas que el cliente debe responder antes del módulo financiero:
  - ¿El split varía por armador?
  - ¿Varía por especie o temporada?
  - ¿Hay armadores con acuerdos especiales?

### 7.3 Algoritmo de Precio Techo (Rentabilidad)
Fórmula para evitar operaciones deficitarias (caso histórico "TET-TOD"):

```
Precio Máximo de Compra = Precio Venta Planta − Gastos Fijos − Margen BRISMAR
```

- Todos los componentes de esta fórmula son `[CONFIGURABLES]`.
- La app debe mostrar alerta visual si el precio de compra propuesto supera el precio techo calculado.

### 7.4 Control de Merma
- Alerta automática si la diferencia entre **peso en bahía** y **peso en planta** supera el umbral configurado.
- **Umbral actual de referencia:** 3–5% (margen por hielo y manipulación).
- **Estado:** `[CONFIGURABLE por administrador]` — no hardcodear el porcentaje.

### 7.5 Reportes PDF
- Generación en **español e inglés** (requerido para clientes de exportación).
- El idioma del reporte debe seleccionarse al momento de generar, no ser fijo.

---

## 8. FLUJO OPERATIVO: DE LA BAHÍA A LA PLANTA

```
[BAHÍA — Operador Daniel / Jair]
    │
    ├── Registro de embarcación (armador)
    ├── Registro de especie
    ├── Pesaje por caja → aplicar tara configurable
    ├── Generación de ticket de pesaje (offline, SQLite)
    │
[DESPACHO]
    │
    ├── Asignación de cámara/camión
    ├── Control de hielo (cadena de frío)
    ├── Generación de Guía de Remisión
    ├── Generación de PTH (SANIPES) — automatizada
    │
[RECEPCIÓN EN PLANTA — ARCOPA / PRODUMART / Corpus Mar / Peru Fres]
    │
    ├── Validación de documentos (Guía + PTH)
    ├── Pesaje en planta → cálculo de merma
    ├── Alerta si merma > umbral configurado
    ├── Para Corpus Mar / Peru Fres: gestión "Venta sujeta con Guía de Observación"
    │
[LIQUIDACIÓN]
    │
    ├── Aplicación de fórmula precio techo
    ├── Split configurable por armador
    └── Generación de reporte PDF (ES / EN)
```

---

## 9. MÓDULOS DEL SISTEMA

| Módulo | Descripción | Prioridad |
|---|---|---|
| **M1 — Registro de Pesaje** | Captura de peso bruto, especie, embarcación, aplicación de tara configurable | MVP |
| **M2 — Gestión de Armadores** | Alta, configuración de split y condiciones por armador | MVP |
| **M3 — Documentación Sanitaria** | Generación automatizada de PTH (SANIPES) y Guías de Remisión | MVP |
| **M4 — Control de Gastos** | Registro de hielo, flete, estiba, combustible con listas predefinidas | MVP |
| **M5 — Liquidación Financiera** | Cálculo de precio techo, split, utilidad neta | Sprint 2 |
| **M6 — Reportes PDF** | Reportes operativos y financieros en ES/EN | Sprint 2 |
| **M7 — Sync Offline** | Cola de sincronización SQLite → Supabase con resolución de conflictos | MVP |
| **M8 — Auditoría** | Log completo de usuario, fecha, hora y acción en operaciones críticas | MVP |
| **M9 — Panel Admin** | Configuración de taras, splits, umbrales de merma, usuarios y roles | Sprint 2 |
| **M10 — Validación Documental** | Certificados de Matrícula y Permisos de Zarpe (PRODUCE/DICAPI) | Sprint 3 |
| **M11 — Dashboard Web** | Vista administrativa para gerencia fuera del muelle | Futuro |

---

## 10. ROLES DE USUARIO

| Rol | Dispositivo | Permisos Principales |
|---|---|---|
| **Operador de Bahía** (Daniel, Jair) | Android (muelle) | Registro de pesaje, despacho, gastos operativos |
| **Administrador** | Android / Web (futuro) | Configuración de taras, splits, armadores, umbrales; edición con trazabilidad |
| **Gerencia** | Web (futuro) | Reportes financieros, auditoría, dashboard de rentabilidad |

---

## 11. MODELO FINANCIERO

### Estructura de Costos Operativos
- Hielo
- Estiba
- Flete
- Combustible
- Otros gastos directos configurables

### Fórmula de Utilidad Neta
```
Utilidad Neta BRISMAR = (Precio Venta Planta × Kg Neto en Planta)
                        − Gastos Operativos Directos
                        − Porción Armador [CONFIGURABLE por armador]
```

### Alertas Financieras Automáticas
- ⚠️ Precio de compra supera el precio techo calculado.
- ⚠️ Merma supera el umbral configurado.
- ⚠️ Operación proyectada como deficitaria antes de confirmar despacho.

---

## 12. MATRIZ DE RIESGOS (PMBOK)

| Código | Riesgo | Prob. | Imp. | Nivel | Mitigación | Contingencia |
|---|---|---|---|---|---|---|
| RT-01 | Conflictos de sync (offline → Supabase) | 3 | 5 | CRÍTICO | sync_logs + política last-write-wins | Reconstrucción vía audit_logs |
| RO-01 | Resistencia al cambio del personal de bahía | 4 | 4 | CRÍTICO | Capacitación presencial en muelle | Respaldo físico (papel) por 30 días |
| RT-02 | Fallo de hardware en campo | 3 | 4 | ALTO | SQLite ACID + backups automáticos | Reingreso manual desde actas físicas |
| RO-02 | Error de ingreso de datos | 4 | 3 | ALTO | Validaciones de rango + listas predefinidas | Edición por admin con trazabilidad completa |
| RT-03 | Backend no definido aún | 4 | 3 | ALTO | Diseño con interfaces abstractas (Repository pattern) | Migración transparente entre proveedores |
| RN-01 | Cambio de normativa SANIPES/PRODUCE | 2 | 5 | ALTO | Módulo de documentación desacoplado y configurable | Actualización de plantillas sin redespliegue |

---

## 13. GLOSARIO DEL MUELLE (Vocabulario para el Agente de IA)

| Término | Definición |
|---|---|
| **Armador** | Propietario de embarcación pesquera que provee el recurso a BRISMAR |
| **Bahía** | Punto físico de desembarque y pesaje (Bahía Daniel, Bahía Jair) |
| **Cámara** | Camión refrigerado que transporta el producto desde muelle hasta planta |
| **Cadena de frío** | Control de temperatura continuo desde captura hasta recepción en planta |
| **Encajonado** | Proceso de colocar el pescado en cajas para pesaje y transporte |
| **Estiba** | Carga y acomodo del producto en el camión/cámara |
| **Guía de Remisión** | Documento legal que acompaña el traslado del producto |
| **Merma** | Diferencia de peso entre bahía y planta (por hielo, manipulación, evaporación) |
| **PTH** | Protocolo Técnico de Habilitación — documento sanitario emitido por SANIPES requerido para que la planta reciba la carga |
| **Planta** | Empresa receptora del producto (ARCOPA, PRODUMART, El Mayor, Corpus Mar, Peru Fres) |
| **Pota** | Cefalópodo (calamar gigante) — recurso estratégico de alta demanda y alta sensibilidad a temperatura |
| **Split** | Porcentaje de división de la liquidación entre BRISMAR y el armador |
| **Tara** | Peso de la caja vacía que se descuenta del peso bruto para obtener el peso neto |
| **TET-TOD** | Caso histórico de operación deficitaria usado como referencia de alerta financiera |
| **Venta sujeta con Guía de Observación** | Modalidad de venta para clientes Corpus Mar / Peru Fres donde la confirmación queda pendiente |
| **Zarpe** | Permiso de salida de la embarcación al mar, emitido por DICAPI |

---

## 14. CUMPLIMIENTO LEGAL Y CERTIFICACIONES

### Requisitos Actuales (MVP)
- **SANIPES:** Generación automatizada de PTH.
- **PRODUCE/DICAPI:** Validación de Certificados de Matrícula y Permisos de Zarpe.

### Roadmap de Certificaciones (24 meses)
| Certificación | Alcance | Módulo que lo soporta |
|---|---|---|
| ISO 22000:2018 | Inocuidad alimentaria — control de cadena de frío | M1, M3, M8 |
| ISO 22005:2007 | Trazabilidad origen → destino final | M1, M8 |
| ISO 9001:2015 | Estandarización de procesos de gestión | M4, M9 |
| ISO/IEC 27001:2022 | Seguridad e integridad de datos comerciales | M7, M8, Supabase RLS |

---

## 15. METODOLOGÍA DE DESARROLLO (SCRUM)

### Pipeline RAG — Seshat / Gemini Bridge
El proyecto utiliza un pipeline **RAG (Retrieval-Augmented Generation)** que inyecta el contexto de negocio de BRISMAR directamente en el IDE. Este documento maestro **es el corpus principal del RAG**. El agente debe consultar este documento antes de generar cualquier código relacionado con:
- Reglas de tara y merma
- Fórmulas financieras
- Generación de documentos sanitarios
- Flujos de sincronización offline

### Sprints Propuestos

| Sprint | Duración | Entregables Clave |
|---|---|---|
| **Sprint 0** | 1 semana | Setup: Supabase, Flutter, SQLite, estructura de proyecto, CI/CD básico |
| **Sprint 1** | 2 semanas | M1 (Pesaje) + M7 (Sync offline) + M2 (Armadores básico) |
| **Sprint 2** | 2 semanas | M3 (PTH/Guías) + M4 (Gastos) + M8 (Auditoría) |
| **Sprint 3** | 2 semanas | M5 (Liquidación) + M6 (Reportes PDF ES/EN) + M9 (Panel Admin) |
| **Sprint 4** | 2 semanas | M10 (Validación documental DICAPI) + pruebas en campo con operadores |
| **Futuro** | TBD | M11 (Dashboard Web) + certificaciones ISO |

---

## 16. DECISIONES PENDIENTES (Backlog de Definición)

> Estas decisiones deben resolverse con el cliente antes del sprint correspondiente. El agente de IA debe dejarlas como parámetros configurables hasta que se definan.

| # | Decisión | Impacta | Urgencia |
|---|---|---|---|
| D-01 | ¿La tara varía también por especie o solo por tipo de caja? | M1 — Pesaje | Sprint 1 |
| D-02 | ¿El split es configurable por armador, especie o temporada? | M5 — Liquidación | Sprint 3 |
| D-03 | ¿Cuáles son los puertos de operación iniciales? | Arquitectura multi-sede | Sprint 0 |
| D-04 | ¿Backend propio o solo Supabase Edge Functions para lógica financiera? | M5, M6 | Sprint 2 |
| D-05 | ¿Existen más tipos de "Venta sujeta con Guía de Observación" además de Corpus Mar / Peru Fres? | M3 — Documentación | Sprint 2 |

---

_Documento generado y mantenido como fuente de verdad para el desarrollo de BRISMAR APP._
_Versión 2.0 — Mayo 2026_
