# Guía de Optimización Visual para Diagramas BPMN

Este documento detalla las técnicas y estándares aplicados al archivo `configuracion_impresora_red.bpmn` para asegurar que tenga una estructura ordenada, legible y con aspecto profesional, alineándose con las mejores prácticas arquitectónicas de la documentación de BRISMAR.

## 1. Cálculo de Espaciado y Simetría (Coordenadas X/Y)
Para evitar que el diagrama luzca amontonado, se estableció un **ancho total de 2600 píxeles** para los *Pools* (participantes). Esto permite que cada elemento "respire".

- **Alineación de Centros:** En lugar de poner los elementos "a ojo", se definió un eje `Y` central para cada carril (Lane). 
  - *Ejemplo:* Si el carril de red física tiene un alto de 220px (de Y=320 a Y=540), su centro es Y=430. Se alinearon las tareas y los eventos de inicio exactamente en ese eje para que se vean como una línea recta perfecta.
- **Márgenes de Eventos vs. Tareas:** Los Eventos (círculos) miden 36x36 y las Tareas (cajas) miden 120x80. Para centrar un evento con una tarea horizontalmente, se realizaron cálculos aritméticos para encontrar el píxel central.

## 2. Ángulos Rectos Perfectos (Orthogonal Routing)
Uno de los cambios más importantes fue rediseñar las rutas de las flechas (`<bpmn:sequenceFlow>` y `<bpmn:messageFlow>`).
En lugar de permitir que el software dibuje líneas diagonales automáticas, se forzó un enrutamiento ortogonal (90 grados):

```xml
<!-- Ejemplo de un codo (bend) perfecto a 90 grados -->
<di:waypoint x="1620" y="690"/>
<di:waypoint x="1655" y="690"/> <!-- Movimiento Horizontal -->
<di:waypoint x="1655" y="950"/> <!-- Caída Vertical de 90° -->
<di:waypoint x="1690" y="950"/> <!-- Movimiento Horizontal hacia la Tarea -->
```
Esto garantiza que los flujos no se crucen caóticamente y se mantenga el estilo estructurado que exige una arquitectura limpia en TI.

## 3. Jerarquía Visual y Colores (BIOC)
Para permitir que un visor identifique rápidamente de qué equipo o área es cada responsabilidad, se aplicó la extensión de coloreado de *BPMN.io (bioc)* directamente en la sintaxis XML. Se imitaron las paletas usadas en otros diagramas de BRISMAR:

* **Usuario / Operario:** Azul Claro (`#bbdefb` fondo, `#0d4372` borde).
* **Configuración Física (TI):** Verde (`#c8e6c9` fondo, `#205022` borde).
* **Configuración Lógica (TI):** Morado (`#e1bee7` fondo, `#5b176d` borde).
* **Validación/Soporte (TI):** Naranja/Crema (`#ffe0b2` fondo, `#8a3a00` borde).
* **Eventos de Inicio/Fin:** Se pintaron de verde (inicio) y rojo pastel (fin) para dar un inicio y término visual contundente.

## 4. Agrupación por Subprocesos (Multi-Instancia)
Dado que la configuración lógica de las computadoras requería repetirse 4 veces (una por PC), se encapsuló en un **Subproceso Expandido** (`<bpmn:subProcess>`).
Visualmente, esto crea un "cuadrante" o caja gigante dentro del carril lógico, informando al lector de que todas esas tareas son parte de un bucle (multi-instancia) cerrado, en lugar de replicar las mismas tareas cuatro veces en el espacio de trabajo.

---
Al combinar *simetría matemática en los ejes X/Y, enrutamiento a 90° y colores semánticos*, el código XML del BPMN genera un lienzo limpio, predecible y estandarizado para los procesos de Gestión de TI.
