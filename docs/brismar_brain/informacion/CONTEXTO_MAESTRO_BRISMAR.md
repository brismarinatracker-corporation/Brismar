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

## 4. LÓGICA DE NEGOCIO (Automatización de la Calculadora al 50/50)
En el video, el operador calcula a mano qué porcentaje de flete le toca a cada embarcación. Lo hemos automatizado mediante **Prorrateo por Peso Neto**.

**Regla Matemática SQL:**
Si un camión cuesta S/. 1,000 y lleva 7,000 kg de la Lancha A (70%) y 3,000 kg de la Lancha B (30%), el motor SQL le cobra S/. 700 de flete al Lote A y S/. 300 al Lote B automáticamente.
```sql
Utilidad_Neta = (Kilos Netos * Precio) - Costos_Prorrateados - Gastos_Muelle_Directos
Liquidacion_Bahia = Utilidad_Neta * 0.50
```
* *Resultado:* Nadie teclea calculadoras. El sistema calcula ingresos, descuenta el hielo y flete proporcional, y separa la mitad para el bahía y la mitad para Brismar al instante.

---

## 5. INTEGRACIÓN Y EXPORTACIÓN (Guías Electrónicas)
El objetivo final del doloroso trabajo manual actual es armar la documentación (Guías y PTH) para que la planta (Ej. Arcopa) reciba el pescado.
1. **Edge Functions (Supabase / Deno):** Cuando el bahía cierra el cuadre en su celular, Supabase se da cuenta y dispara una función en la nube.
2. **NubeFact / Migo (API SUNAT):** La función empaqueta los datos, se los manda a SUNAT en milisegundos y nos devuelve el enlace de un PDF legal (Guía de Remisión Electrónica).
* *Resultado:* El chofer recibe un WhatsApp automático con su Guía Electrónica (con Código QR) lista para enseñar en la carretera. El trabajo burocrático manual que se ve en el video deja de existir.
