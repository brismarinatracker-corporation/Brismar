-- Migración para añadir updated_at a la tabla zarpes
-- Fecha: 2026-06-29

-- 1. Añadir la columna updated_at
ALTER TABLE public.zarpes 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- 2. Crear o reemplazar el trigger para setear updated_at automáticamente
DROP TRIGGER IF EXISTS trg_zarpes_updated_at ON public.zarpes;

CREATE TRIGGER trg_zarpes_updated_at
  BEFORE UPDATE ON public.zarpes
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();
