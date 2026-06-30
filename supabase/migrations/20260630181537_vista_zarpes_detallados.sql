-- 1. Crear índices para optimizar las subconsultas de la vista
CREATE INDEX IF NOT EXISTS idx_compras_cuadre_id ON public.compras(cuadre_id);
CREATE INDEX IF NOT EXISTS idx_gastos_cuadre_id ON public.gastos(cuadre_id);

-- 2. Crear la vista que consolida toda la información
CREATE OR REPLACE VIEW public.vista_zarpes_detallados AS
SELECT 
    z.id,
    z.placa_camara,
    z.chofer,
    z.muelle_partida,
    z.fecha_zarpe,
    z.estado AS estado_transito,
    z.foto_url_evidencia,
    -- Datos de carga y consolidado
    c.peso_total,
    c.cajas_llenas,
    c.cajas_vacias,
    -- Flete extraído de los gastos
    COALESCE((
        SELECT total 
        FROM public.gastos 
        WHERE cuadre_id = z.id AND concepto = 'FLETE' 
        LIMIT 1
    ), 0) AS costo_flete,
    -- Agrupación de embarcaciones (lanchas)
    (
        SELECT string_agg(DISTINCT embarcacion, ', ') 
        FROM public.compras 
        WHERE cuadre_id = z.id
    ) AS embarcaciones_asociadas
FROM public.zarpes z
LEFT JOIN public.cuadres c ON z.id = c.id;
