-- Migración: Trazabilidad de Usuario en Cámaras de Tránsito
-- Fecha: 2026-07-24

DROP VIEW IF EXISTS public.vista_zarpes_detallados CASCADE;

CREATE VIEW public.vista_zarpes_detallados AS
SELECT 
    z.id,
    z.placa_camara,
    z.chofer,
    z.muelle_partida,
    z.fecha_zarpe,
    z.estado AS estado_transito,
    z.foto_url_evidencia,
    z.creado_por,
    c.usuario_id,
    COALESCE(u_cuadre.nombre_real, u_zarpe.nombre_real, 'Usuario no especificado') AS usuario_nombre,
    COALESCE(u_cuadre.correo, u_zarpe.correo, '') AS usuario_correo,
    COALESCE(u_cuadre.rol, u_zarpe.rol, '') AS usuario_rol,
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
LEFT JOIN public.cuadres c ON z.id = c.id
LEFT JOIN public.usuarios u_cuadre ON c.usuario_id = u_cuadre.id
LEFT JOIN public.usuarios u_zarpe ON z.creado_por = u_zarpe.id;
