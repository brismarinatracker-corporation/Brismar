-- Migration: Índices de optimización de rendimiento para consultas de zarpes, cuadres y compras
-- Fecha: 2026-07-23

-- 1. Índice compuesto en cuadres (usuario_id, estado, fecha_cuadre)
CREATE INDEX IF NOT EXISTS idx_cuadres_usuario_estado_fecha
ON public.cuadres (usuario_id, estado, fecha_cuadre DESC);

-- 2. Índice B-Tree en compras por cuadre_id
CREATE INDEX IF NOT EXISTS idx_compras_cuadre_id
ON public.compras (cuadre_id);

-- 3. Índice B-Tree en gastos por cuadre_id
CREATE INDEX IF NOT EXISTS idx_gastos_cuadre_id
ON public.gastos (cuadre_id);

-- 4. Índice compuesto en zarpes por fecha y estado
CREATE INDEX IF NOT EXISTS idx_zarpes_fecha_estado
ON public.zarpes (fecha_zarpe DESC, estado);
