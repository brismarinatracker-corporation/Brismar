# Sistema Central: Supabase

Supabase es el cerebro y la fuente de la verdad para toda la corporación Brismar. Es el punto donde los mundos de la App y la Web colisionan.

## Responsabilidades

1. **Recibir datos móviles:** Recibe todos los envíos asíncronos detallados en [[FLUJO_02_REGISTRO_PESCA]].
2. **Servir a la Web:** Proporciona datos en tiempo real al Dashboard Web (`brismar_web`), permitiendo que el personal en tierra sepa exactamente cuánto pescado viene en camino.
3. **Control de Acceso (RLS) y Bloqueo:** Mantiene reglas estrictas de Row Level Security para asegurar que un pescador no pueda editar las métricas de otro. Además, aplica un **bloqueo estricto** cuando un lote pasa a estado `CERRADO`, impidiendo cualquier alteración post-descarga sin autorización explícita.
4. **Log de Auditoría:** Mantiene trazabilidad total (Audit Log) de cualquier cambio realizado en el "Precio Pactado" de compra/venta para evitar manipulación financiera.
5. **Doble Contabilidad Transparente:** La base de datos y la API proveen dos capas de visión: el "Resumen Bahía" (donde el operario ve solo su 50% y sus adelantos) y el "Resumen Contable" (donde oficina ve la utilidad global de la corporación).

## Convivencia Estricta

Dado que dos aplicaciones diferentes consumen esta base de datos, está estrictamente prohibido realizar cambios estructurales (borrar tablas o columnas) sin asegurar que tanto la App Móvil como la Web están preparadas para el cambio. (Ver [[ARQUITECTURA_Y_REGLAS]]).

---

## 🔗 Enlaces Relacionados

- Posibles riesgos por sobrecarga o caída del servidor: [[MAPA_DE_RIESGOS]].
