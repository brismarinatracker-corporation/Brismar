# CONTEXTO MAESTRO: ARQUITECTURA Y DIGITALIZACIÓN DE BRISMAR S.R.L.

Este documento unifica el núcleo operativo, técnico y arquitectónico del proyecto BRISMAR. Sirve como "Prompt Maestro" y fuente de verdad para el desarrollo, validando la tecnología contra los procesos manuales (evidenciados en video) que buscamos erradicar.

---

## 1. EL NEGOCIO Y EL PROBLEMA
**BRISMAR** es una logística pesquera tercerizada. El flujo real: 
`Muelle (Bahía) -> Registro de Pesaje/Gastos -> Carga en Cámara (500 cajas) -> Contabilidad/Documentación -> Liquidación final (50/50 con el bahía)`.
* **Dolor actual (El Video):** Todo se hace con Excel, calculadoras y papeles. El administrador cruza datos visualmente entre embarcaciones y cámaras frigoríficas. Si el bahía (Jim o Daniel) se queda sin internet en el muelle, no llega el WhatsApp y toda la contabilidad se detiene.
* **La Solución:** Un sistema **Offline-First** (Funciona sin internet) que centraliza la operación en Supabase (PostgreSQL), donde la matemática se hace sola y las guías de remisión salen en segundos.

---

## 2. ARQUITECTURA DE DATOS (El fin del "Cuadre Visual")
Para evitar que el humano tenga que cruzar papeles para saber qué pescado entró a qué camión, usamos un modelo relacional **Muchos a Muchos (M:N)** con una Tabla Pivote.

**Tablas Principales:**
1. `embarcaciones` y `camaras_frigorificas`
2. `lotes_pesca` (Lo que se extrajo del mar)
3. **`manifiestos_carga` (Tabla Pivote):** Une el `lote_pesca` con la `camara_frigorifica`. 
* *Resultado:* Si un lote gigante se divide en 2 camiones, o si 1 camión lleva pesca de 3 barcos, la tabla pivote lo rastrea. El administrador web hace un solo clic y ve la distribución perfecta. Cero cruces manuales.

---

## 3. OFFLINE-FIRST (Adiós a la latencia de WhatsApp)
Para que el muelle no paralice a la oficina por falta de señal:
1. **Event Sourcing (SQLite):** El bahía ingresa datos en su app. Todo se guarda localmente en su teléfono (`sync_queue = PENDING`).
2. **Worker Reactivo:** El bahía se guarda el teléfono y sigue trabajando. En cuanto el teléfono capta una red 4G, un proceso fantasma despierta, empaqueta los datos y los dispara a Supabase.
* *Resultado:* El administrador en oficina ve la data aparecer en su pantalla en tiempo real sin pedirle nada a nadie por chat.

---

## 4. LÓGICA DE NEGOCIO (Automatización Matemática al 50/50)
En el video, el operador calcula a mano qué porcentaje de flete le toca a cada embarcación y separa la utilidad de la empresa. Lo hemos automatizado mediante **Prorrateo por Peso Neto**, incorporando ahora gastos extra-oficiales del muelle.

**Nuevas Reglas de Negocio Oficiales (Aprobadas por CEO):**
1. **Tara Fija:** La única tara permitida a nivel operativo es **3 kg**. El código usará este valor por defecto (preparado arquitectónicamente para escalar después, pero sin mostrar opciones múltiples al operario ahora).
2. **Adelantos a Proveedor (Fidelización):** El dinero que el Bahía entrega a las lanchas para combustible o víveres sale de su "caja chica". Este adelanto reduce el **Poder de Compra** total del lote y se resta directamente de la Utilidad Bruta de la operación antes del prorrateo final.
3. **Cortesía (Pendiente de Oficialización):** Se prevé registrar pescado regalado ("cortesía") como una salida a S/. 0.00 para cuadrar inventario físico, sujeto a confirmación final.

**Regla Matemática SQL:**
Si un camión cuesta S/. 1,000 en flete, lleva 7,000 kg de la Lancha A (70%) y 3,000 kg de la Lancha B (30%), el motor SQL le cobra S/. 700 de flete al Lote A y S/. 300 al Lote B automáticamente.
```sql
-- 1. Se calcula la utilidad bruta descontando el adelanto al proveedor (embarcación):
Utilidad_Bruta = (Kilos Netos * Precio Pactado) - Adelanto_Proveedor - Comision_Muelle

-- 2. Se resta el flete y hielo prorrateado:
Utilidad_Neta = Utilidad_Bruta - Costos_Prorrateados_Camara - Gastos_Muelle_Directos

-- 3. Repartición Final:
Fondo_Empresa_Brismar = Utilidad_Neta * 0.50
Liquidacion_Neta_Bahia = Utilidad_Neta * 0.50
```
* *Resultado:* El sistema calcula ingresos, descuenta el adelanto que salió de caja chica, asume la tara de 3kg y separa la utilidad limpia al instante. 

### 4.1 Bloqueo de Cámara y Permisos (App Input vs Web Admin)
* **App Móvil (Input Layer):** La aplicación del Bahía se considera una herramienta **principalmente de envío de datos (Input)**. Para proteger la información financiera de BRISMAR (ya que operarios y dueños cuidan sus propios intereses), la App **nunca mostrará** los márgenes de ganancia globales ni la tajada de la corporación. Solo mostrará lo necesario para operar. No se crearán nuevos roles, se usará lógica de protección de vistas.
* **Dashboard Web (Capa Administrativa):** Manejado por BRISMAR en oficina, tiene acceso total a los datos protegidos y a la utilidad corporativa real.
* **Estado CERRADO:** Cuando una cámara alcanza su tope, pasa a estado `CERRADO`. La base de datos bloquea cualquier intento de edición, exigiendo autorización corporativa para cambios post-cierre.

---

## 5. INTEGRACIÓN Y EXPORTACIÓN (Guías Electrónicas)
El objetivo final del doloroso trabajo manual actual es armar la documentación (Guías y PTH) para que la planta (Ej. Arcopa) reciba el pescado.
1. **Edge Functions (Supabase / Deno):** Cuando el bahía cierra el cuadre en su celular, Supabase se da cuenta y dispara una función en la nube.
2. **NubeFact / Migo (API SUNAT):** La función empaqueta los datos, se los manda a SUNAT en milisegundos y nos devuelve el enlace de un PDF legal (Guía de Remisión Electrónica).
* *Resultado:* El chofer recibe un WhatsApp automático con su Guía Electrónica (con Código QR) lista para enseñar en la carretera. El trabajo burocrático manual que se ve en el video deja de existir.
