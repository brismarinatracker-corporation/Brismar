# Sistema Central: Supabase

Supabase es el cerebro y la fuente de la verdad para toda la corporación Brismar. Es el punto donde los mundos de la App y la Web colisionan.

## Responsabilidades

1. **Recibir datos móviles:** Recibe todos los envíos asíncronos detallados en `[[FLUJO_02_REGISTRO_PESCA_ALTA_MAR]]`.
2. **Servir a la Web:** Proporciona datos en tiempo real al Dashboard Web (`brismar_web`), permitiendo que el personal en tierra sepa exactamente cuánto pescado viene en camino.
3. **Control de Acceso (RLS):** Mantiene reglas estrictas de Row Level Security para asegurar que un pescador no pueda editar las métricas de otro pescador.

## Convivencia Estricta

Dado que dos aplicaciones diferentes consumen esta base de datos, está estrictamente prohibido realizar cambios estructurales (borrar tablas o columnas) sin asegurar que tanto la App Móvil como la Web están preparadas para el cambio. (Ver `[[01_ARQUITECTURA_Y_REGLAS]]`).

---

## 🔗 Enlaces Relacionados

- Posibles riesgos por sobrecarga o caída del servidor: `[[MAPA_DE_RIESGOS]]`.
