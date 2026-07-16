-- Modificación para soportar nombres de especies de pescado personalizados en lugar de solo IDs fijos
ALTER TABLE public.cuadres ALTER COLUMN tipo_producto TYPE varchar USING tipo_producto::varchar;
